import 'package:drift/drift.dart';
import 'package:meta/meta.dart';
import 'package:vehicle_khata/core/db/app_database.dart';
import 'package:vehicle_khata/core/db/audit.dart';
import 'package:vehicle_khata/core/db/ids.dart';
import 'package:vehicle_khata/core/money/money.dart';
import 'package:vehicle_khata/core/time/calendar_day.dart';
import 'package:vehicle_khata/features/drivers/domain/pay_model.dart';
import 'package:vehicle_khata/features/jama/domain/jama_logic.dart';
import 'package:vehicle_khata/features/reports/data/rollup_service.dart';

enum JamaError {
  amountInvalid,
  nothingDue,
  exceedsDue,
  notFound,
  invalidRange,
  depositExceedsBalance,
}

class JamaException implements Exception {
  const new(this.error);

  final JamaError error;

  @override
  String toString() => 'JamaException($error)';
}

enum GarageMode { pause, waive }

enum DepositKind { received, refund, deduct }

/// One jama entry with what has been paid against it.
@immutable
class JamaEntryView {
  const new({
    required this.id,
    required this.assignmentId,
    required this.state,
  });

  final String id;
  final String assignmentId;
  final JamaEntryState state;
}

@immutable
class GaragePeriod {
  const new({
    required this.id,
    required this.vehicleId,
    required this.start,
    required this.end,
    required this.mode,
  });

  final String id;
  final String vehicleId;
  final CalendarDay start;
  final CalendarDay? end;
  final GarageMode mode;

  bool get isOpen => end == null;
}

/// Everything about jama: generating what is due, collecting, waiving,
/// garage periods and the security deposit.
class JamaRepository {
  new(this._db, this._rollups);

  final AppDatabase _db;
  final RollupService _rollups;

  // --- generation ---------------------------------------------------------

  /// Creates the jama entries that should exist up to [today] and do not yet.
  /// Safe to call as often as you like: the unique key on
  /// (assignment, due day) and an existence check make it idempotent, and it
  /// backfills any days missed while the app was closed. Returns how many
  /// entries were created.
  Future<int> generate(CalendarDay today) => _db.transaction(() async {
    var created = 0;
    final assignments = await (_db.select(
      _db.assignments,
    )..where((t) => t.deletedAt.isNull())).get();
    for (final a in assignments) {
      final model = PayModel.decode(a.payModelJson);
      if (model is! JamaPay) continue;
      final start = CalendarDay(a.startDay);
      var through = today;
      if (a.endDay != null && CalendarDay(a.endDay!).isBefore(through)) {
        through = CalendarDay(a.endDay!);
      }
      final due = scheduledDueDays(pay: model, start: start, through: through);
      if (due.isEmpty) continue;
      final existing = {
        for (final e
            in await (_db.select(_db.jamaEntries)..where(
                  (t) => t.assignmentId.equals(a.id) & t.deletedAt.isNull(),
                ))
                .get())
          e.dueDay,
      };
      final pauses = await _pauses(a.vehicleId);
      for (final d in due) {
        if (existing.contains(d.day.epochDay)) continue;
        final pause = pauses.where((p) => isInRange(d.day, p.start, p.end));
        if (pause.any((p) => p.mode == GarageMode.pause)) continue;
        final waived = pause.isNotEmpty;
        await _db
            .into(_db.jamaEntries)
            .insert(
              JamaEntriesCompanion.insert(
                assignmentId: a.id,
                vehicleId: a.vehicleId,
                driverId: a.driverId,
                dueDay: d.day.epochDay,
                expectedMinor: d.expected.minor,
                waivedMinor: Value(waived ? d.expected.minor : 0),
              ),
              mode: InsertMode.insertOrIgnore,
            );
        created++;
      }
    }
    return created;
  });

  // --- reading -------------------------------------------------------------

  static const _entriesSql = '''
SELECT e.id, e.assignment_id, e.due_day, e.expected_minor, e.waived_minor,
  COALESCE((SELECT SUM(al.amount_minor) FROM jama_allocations al
            JOIN jama_payments p ON p.id = al.payment_id
            WHERE al.entry_id = e.id AND al.deleted_at IS NULL
              AND p.deleted_at IS NULL), 0) AS paid
FROM jama_entries e
WHERE e.deleted_at IS NULL AND e.%s
ORDER BY e.due_day, e.id
''';

  Selectable<JamaEntryView> _entries(String where, List<Variable> vars) => _db
      .customSelect(
        _entriesSql.replaceFirst('%s', where),
        variables: vars,
        readsFrom: {_db.jamaEntries, _db.jamaAllocations, _db.jamaPayments},
      )
      .map(
        (r) => JamaEntryView(
          id: r.read<String>('id'),
          assignmentId: r.read<String>('assignment_id'),
          state: JamaEntryState(
            day: CalendarDay(r.read<int>('due_day')),
            expected: Money(r.read<int>('expected_minor')),
            waived: Money(r.read<int>('waived_minor')),
            paid: Money(r.read<int>('paid')),
          ),
        ),
      );

  /// Entries of a vehicle (any driver) due within [range], oldest first.
  Stream<List<JamaEntryView>> watchForVehicle(
    String vehicleId,
    DayRange range,
  ) => _entries('vehicle_id = ? AND e.due_day BETWEEN ? AND ?', [
    Variable<String>(vehicleId),
    Variable<int>(range.start.epochDay),
    Variable<int>(range.end.epochDay),
  ]).watch();

  Future<List<JamaEntryView>> entriesForVehicle(
    String vehicleId,
    DayRange range,
  ) => _entries('vehicle_id = ? AND e.due_day BETWEEN ? AND ?', [
    Variable<String>(vehicleId),
    Variable<int>(range.start.epochDay),
    Variable<int>(range.end.epochDay),
  ]).get();

  Future<List<JamaEntryView>> entriesForDriver(String driverId) =>
      _entries('driver_id = ?', [Variable<String>(driverId)]).get();

  /// Owed by [driverId] for days up to and including [today] (the baki).
  Future<Money> bakiForDriver(String driverId, CalendarDay today) async {
    final all = await _entries('driver_id = ? AND e.due_day <= ?', [
      Variable<String>(driverId),
      Variable<int>(today.epochDay),
    ]).get();
    return all.map((e) => e.state.due).sum();
  }

  Stream<Money> watchBakiForVehicle(String vehicleId, CalendarDay today) =>
      _entries('vehicle_id = ? AND e.due_day <= ?', [
        Variable<String>(vehicleId),
        Variable<int>(today.epochDay),
      ]).watch().map((l) => l.map((e) => e.state.due).sum());

  // --- collecting ----------------------------------------------------------

  /// Records [amount] handed over on [day] and applies it to the oldest dues
  /// (up to [today]). Returns the payment id.
  Future<String> collect({
    required String assignmentId,
    required Money amount,
    required CalendarDay day,
    required CalendarDay today,
    String? note,
  }) => _db.transaction(() async {
    if (!amount.isPositive) throw const JamaException(JamaError.amountInvalid);
    final a =
        await (_db.select(_db.assignments)
              ..where((t) => t.id.equals(assignmentId) & t.deletedAt.isNull()))
            .getSingleOrNull();
    if (a == null) throw const JamaException(JamaError.notFound);
    final open = [
      for (final e in await _entries('assignment_id = ? AND e.due_day <= ?', [
        Variable<String>(assignmentId),
        Variable<int>(today.epochDay),
      ]).get())
        if (e.state.due.isPositive) OpenEntry(e.id, e.state.day, e.state.due),
    ];
    final totalDue = open.map((e) => e.due).sum();
    if (!totalDue.isPositive) throw const JamaException(JamaError.nothingDue);
    if (amount > totalDue) throw const JamaException(JamaError.exceedsDue);

    final paymentId = newId();
    await _db
        .into(_db.jamaPayments)
        .insert(
          JamaPaymentsCompanion.insert(
            id: Value(paymentId),
            assignmentId: assignmentId,
            vehicleId: a.vehicleId,
            driverId: a.driverId,
            paidDay: day.epochDay,
            amountMinor: amount.minor,
            note: Value(note),
          ),
        );
    for (final al in allocateOldestFirst(amount, open)) {
      await _db
          .into(_db.jamaAllocations)
          .insert(
            JamaAllocationsCompanion.insert(
              paymentId: paymentId,
              entryId: al.entryId,
              amountMinor: al.amount.minor,
            ),
          );
    }
    await _db.logAudit(
      entity: 'jama_payment',
      entityId: paymentId,
      action: 'create',
      diff: {'amount_minor': amount.minor, 'day': day.epochDay},
    );
    await _rollups.refresh(a.vehicleId, [day]);
    return paymentId;
  });

  /// Undoes a payment: the dues it covered become owed again.
  Future<void> voidPayment(String paymentId) => _db.transaction(() async {
    final p =
        await (_db.select(_db.jamaPayments)
              ..where((t) => t.id.equals(paymentId) & t.deletedAt.isNull()))
            .getSingleOrNull();
    if (p == null) throw const JamaException(JamaError.notFound);
    final allocs =
        await (_db.select(_db.jamaAllocations)..where(
              (t) => t.paymentId.equals(paymentId) & t.deletedAt.isNull(),
            ))
            .get();
    for (final al in allocs) {
      await _db.softDelete(_db.jamaAllocations, al.id);
    }
    await _db.softDelete(_db.jamaPayments, paymentId);
    await _db.logAudit(
      entity: 'jama_payment',
      entityId: paymentId,
      action: 'void',
    );
    await _rollups.refresh(p.vehicleId, [CalendarDay(p.paidDay)]);
  });

  /// Latest payment first.
  Future<List<JamaPaymentRow>> paymentsForAssignment(String assignmentId) =>
      (_db.select(_db.jamaPayments)
            ..where(
              (t) => t.assignmentId.equals(assignmentId) & t.deletedAt.isNull(),
            )
            ..orderBy([
              (t) => OrderingTerm.desc(t.paidDay),
              (t) => OrderingTerm.desc(t.id),
            ]))
          .get();

  Stream<List<JamaPaymentRow>> watchPayments(String assignmentId) =>
      (_db.select(_db.jamaPayments)
            ..where(
              (t) => t.assignmentId.equals(assignmentId) & t.deletedAt.isNull(),
            )
            ..orderBy([
              (t) => OrderingTerm.desc(t.paidDay),
              (t) => OrderingTerm.desc(t.id),
            ]))
          .watch();

  /// Forgives whatever is still owed on one entry.
  Future<void> waive(String entryId, {String? note}) =>
      _db.transaction(() async {
        final e = (await _entries('id = ?', [
          Variable<String>(entryId),
        ]).get()).firstOrNull;
        if (e == null) throw const JamaException(JamaError.notFound);
        if (!e.state.due.isPositive) return;
        await (_db.update(
          _db.jamaEntries,
        )..where((t) => t.id.equals(entryId))).write(
          JamaEntriesCompanion(
            waivedMinor: Value(e.state.waived.minor + e.state.due.minor),
            note: Value(note),
          ),
        );
        await _db.touch(_db.jamaEntries, entryId);
        await _db.logAudit(
          entity: 'jama_entry',
          entityId: entryId,
          action: 'waive',
          diff: {'amount_minor': e.state.due.minor},
        );
      });

  // --- garage ---------------------------------------------------------------

  Future<List<GaragePeriod>> _pauses(String vehicleId) async {
    final rows =
        await (_db.select(_db.jamaPauses)..where(
              (t) => t.vehicleId.equals(vehicleId) & t.deletedAt.isNull(),
            ))
            .get();
    return rows.map(_toPeriod).toList();
  }

  GaragePeriod _toPeriod(JamaPauseRow r) => GaragePeriod(
    id: r.id,
    vehicleId: r.vehicleId,
    start: CalendarDay(r.startDay),
    end: r.endDay == null ? null : CalendarDay(r.endDay!),
    mode: GarageMode.values.byName(r.mode),
  );

  Stream<List<GaragePeriod>> watchGarage(String vehicleId) =>
      (_db.select(_db.jamaPauses)
            ..where((t) => t.vehicleId.equals(vehicleId) & t.deletedAt.isNull())
            ..orderBy([(t) => OrderingTerm.desc(t.startDay)]))
          .watch()
          .map((l) => l.map(_toPeriod).toList());

  /// Marks the vehicle off the road from [start] (to [end], or until further
  /// notice). Entries already created for those days are adjusted: with
  /// [GarageMode.pause] unpaid-in-full entries disappear; days that already
  /// have money paid keep only what was paid. With [GarageMode.waive] what is
  /// still owed is forgiven. Days generated later follow the same rule.
  Future<String> startGarage({
    required String vehicleId,
    required CalendarDay start,
    required GarageMode mode,
    CalendarDay? end,
    String? note,
  }) => _db.transaction(() async {
    if (end != null && end.isBefore(start)) {
      throw const JamaException(JamaError.invalidRange);
    }
    final id = newId();
    await _db
        .into(_db.jamaPauses)
        .insert(
          JamaPausesCompanion.insert(
            id: Value(id),
            vehicleId: vehicleId,
            startDay: start.epochDay,
            endDay: Value(end?.epochDay),
            mode: mode.name,
            note: Value(note),
          ),
        );
    await _applyGarage(vehicleId, start, end, mode);
    await _db.logAudit(entity: 'jama_pause', entityId: id, action: 'create');
    return id;
  });

  Future<void> _applyGarage(
    String vehicleId,
    CalendarDay start,
    CalendarDay? end,
    GarageMode mode,
  ) async {
    final last = end ?? const CalendarDay(1 << 30);
    final entries = await _entries(
      'vehicle_id = ? AND e.due_day BETWEEN ? AND ?',
      [
        Variable<String>(vehicleId),
        Variable<int>(start.epochDay),
        Variable<int>(last.epochDay),
      ],
    ).get();
    for (final e in entries) {
      if (!e.state.due.isPositive) continue;
      final untouched = e.state.paid.isZero && e.state.waived.isZero;
      if (mode == GarageMode.pause && untouched) {
        await _db.softDelete(_db.jamaEntries, e.id);
      } else {
        await (_db.update(
          _db.jamaEntries,
        )..where((t) => t.id.equals(e.id))).write(
          JamaEntriesCompanion(
            waivedMinor: Value(e.state.waived.minor + e.state.due.minor),
          ),
        );
        await _db.touch(_db.jamaEntries, e.id);
      }
    }
  }

  /// Ends an open garage period on [end] (the last day off the road).
  Future<void> endGarage(String pauseId, CalendarDay end) =>
      _db.transaction(() async {
        final row =
            await (_db.select(_db.jamaPauses)
                  ..where((t) => t.id.equals(pauseId) & t.deletedAt.isNull()))
                .getSingleOrNull();
        if (row == null) throw const JamaException(JamaError.notFound);
        if (end.epochDay < row.startDay) {
          throw const JamaException(JamaError.invalidRange);
        }
        await (_db.update(_db.jamaPauses)..where((t) => t.id.equals(pauseId)))
            .write(JamaPausesCompanion(endDay: Value(end.epochDay)));
        await _db.touch(_db.jamaPauses, pauseId);
      });

  // --- deposit --------------------------------------------------------------

  Future<String> addDeposit({
    required String assignmentId,
    required DepositKind kind,
    required Money amount,
    required CalendarDay day,
    String? note,
  }) => _db.transaction(() async {
    if (!amount.isPositive) throw const JamaException(JamaError.amountInvalid);
    if (kind != DepositKind.received &&
        amount > await depositBalance(assignmentId)) {
      throw const JamaException(JamaError.depositExceedsBalance);
    }
    final id = newId();
    await _db
        .into(_db.jamaDeposits)
        .insert(
          JamaDepositsCompanion.insert(
            id: Value(id),
            assignmentId: assignmentId,
            kind: kind.name,
            amountMinor: amount.minor,
            day: day.epochDay,
            note: Value(note),
          ),
        );
    await _db.logAudit(
      entity: 'jama_deposit',
      entityId: id,
      action: kind.name,
      diff: {'amount_minor': amount.minor},
    );
    return id;
  });

  Future<Money> depositBalance(String assignmentId) async {
    final rows =
        await (_db.select(_db.jamaDeposits)..where(
              (t) => t.assignmentId.equals(assignmentId) & t.deletedAt.isNull(),
            ))
            .get();
    var m = Money.zero;
    for (final r in rows) {
      final v = Money(r.amountMinor);
      m = r.kind == DepositKind.received.name ? m + v : m - v;
    }
    return m;
  }

  // --- report ---------------------------------------------------------------

  /// Expected vs collected for entries due in [range], per driver.
  Future<JamaReport> report(DayRange range, CalendarDay today) async {
    final rows = await _db
        .customSelect(
          '''
SELECT e.driver_id, e.vehicle_id, e.due_day, e.expected_minor, e.waived_minor,
  COALESCE((SELECT SUM(al.amount_minor) FROM jama_allocations al
            JOIN jama_payments p ON p.id = al.payment_id
            WHERE al.entry_id = e.id AND al.deleted_at IS NULL
              AND p.deleted_at IS NULL), 0) AS paid,
  d.name AS driver_name
FROM jama_entries e JOIN drivers d ON d.id = e.driver_id
WHERE e.deleted_at IS NULL AND e.due_day BETWEEN ? AND ?
''',
          variables: [
            Variable<int>(range.start.epochDay),
            Variable<int>(range.end.epochDay),
          ],
        )
        .get();
    final byDriver = <String, _Acc>{};
    for (final r in rows) {
      final acc = byDriver.putIfAbsent(
        r.read<String>('driver_id'),
        () => _Acc(r.read<String>('driver_name')),
      );
      final state = JamaEntryState(
        day: CalendarDay(r.read<int>('due_day')),
        expected: Money(r.read<int>('expected_minor')),
        waived: Money(r.read<int>('waived_minor')),
        paid: Money(r.read<int>('paid')),
      );
      if (state.day.isAfter(today)) continue;
      acc
        ..expected += state.expected - state.waived
        ..collected += state.paid;
      if (state.due.isPositive) {
        acc.due += state.due;
        acc.missedDays++;
        if (acc.oldest == null || state.day.isBefore(acc.oldest!)) {
          acc.oldest = state.day;
        }
      }
    }
    final drivers = [
      for (final e in byDriver.entries)
        JamaDriverLine(
          driverId: e.key,
          driverName: e.value.name,
          expected: e.value.expected,
          collected: e.value.collected,
          due: e.value.due,
          missedDays: e.value.missedDays,
          oldestDue: e.value.oldest,
        ),
    ]..sort((a, b) => b.due.compareTo(a.due));
    return JamaReport(drivers);
  }
}

class _Acc {
  new(this.name);

  final String name;
  Money expected = Money.zero;
  Money collected = Money.zero;
  Money due = Money.zero;
  int missedDays = 0;
  CalendarDay? oldest;
}

@immutable
class JamaDriverLine {
  const new({
    required this.driverId,
    required this.driverName,
    required this.expected,
    required this.collected,
    required this.due,
    required this.missedDays,
    required this.oldestDue,
  });

  final String driverId;
  final String driverName;
  final Money expected;
  final Money collected;
  final Money due;
  final int missedDays;
  final CalendarDay? oldestDue;
}

@immutable
class JamaReport {
  const new(this.drivers);

  final List<JamaDriverLine> drivers;

  Money get expected => drivers.map((d) => d.expected).sum();
  Money get collected => drivers.map((d) => d.collected).sum();
  Money get due => drivers.map((d) => d.due).sum();
  int get ratePercent => collectionRatePercent(collected, expected);

  /// Drivers who still owe something, biggest first.
  List<JamaDriverLine> get defaulters =>
      drivers.where((d) => d.due.isPositive).toList();
}

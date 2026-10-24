import 'package:drift/drift.dart';
import 'package:meta/meta.dart';
import 'package:vehicle_khata/core/db/app_database.dart';
import 'package:vehicle_khata/core/db/audit.dart';
import 'package:vehicle_khata/core/db/ids.dart';
import 'package:vehicle_khata/core/money/money.dart';
import 'package:vehicle_khata/core/time/calendar_day.dart';
import 'package:vehicle_khata/features/jama/data/jama_repository.dart';
import 'package:vehicle_khata/features/jama/domain/jama_logic.dart';
import 'package:vehicle_khata/features/ledger/domain/ledger_logic.dart';
import 'package:vehicle_khata/features/trips/data/trip_repository.dart';

enum LedgerError {
  amountInvalid,
  nothingOwed,
  exceedsOwed,
  allocationMismatch,
  notReversible,
  notFound,
}

class LedgerException implements Exception {
  const new(this.error);

  final LedgerError error;

  @override
  String toString() => 'LedgerException($error)';
}

@immutable
class PartyBalance {
  const new({required this.party, required this.name, required this.balance});

  final Party party;
  final String name;

  /// Positive: owes the owner. Negative: the owner owes them.
  final Money balance;
}

@immutable
class StatementLine {
  const new({
    required this.day,
    required this.label,
    required this.amount,
    required this.isPayment,
    this.refType,
  });

  final CalendarDay day;
  final RefType? refType;
  final String label;
  final Money amount;
  final bool isPayment;
}

class _Want {
  const new(this.party, this.refType, this.refId, this.day, this.amount);

  final Party party;
  final RefType refType;
  final String refId;
  final int day;
  final int amount;
}

/// The dues ledger.
///
/// What people owe is derived from the records that already exist (jama,
/// advances, trips, reimbursable expenses). [post] compares each record's
/// outstanding amount with what the ledger holds and appends a row for any
/// difference: never an update, never a delete. Row ids are deterministic
/// (`lg:<type>:<ref>:<n>`), so two phones posting the same change write the
/// same row and sync stays idempotent.
class LedgerService {
  new(this._db, this._trips, this._jama);

  final AppDatabase _db;
  final TripRepository _trips;
  final JamaRepository _jama;

  // --- posting --------------------------------------------------------------

  Future<List<_Want>> _wants() async {
    final out = <_Want>[];

    for (final r in await _db.customSelect('''
SELECT e.id, e.driver_id, e.due_day,
  MAX(e.expected_minor - e.waived_minor - COALESCE((
    SELECT SUM(al.amount_minor) FROM jama_allocations al
    JOIN jama_payments p ON p.id = al.payment_id
    WHERE al.entry_id = e.id AND al.deleted_at IS NULL
      AND p.deleted_at IS NULL), 0), 0) AS owed
FROM jama_entries e WHERE e.deleted_at IS NULL
''').get()) {
      out.add(
        _Want(
          Party(PartyType.driver, r.read<String>('driver_id')),
          RefType.jama,
          r.read<String>('id'),
          r.read<int>('due_day'),
          r.read<int>('owed'),
        ),
      );
    }

    for (final r in await _db.customSelect('''
SELECT a.id, a.driver_id, a.given_day,
  MAX(a.amount_minor - COALESCE((
    SELECT SUM(pa.amount_minor) FROM payout_advance_allocations pa
    WHERE pa.advance_id = a.id AND pa.deleted_at IS NULL), 0), 0) AS owed
FROM advances a WHERE a.deleted_at IS NULL
''').get()) {
      out.add(
        _Want(
          Party(PartyType.driver, r.read<String>('driver_id')),
          RefType.advance,
          r.read<String>('id'),
          r.read<int>('given_day'),
          r.read<int>('owed'),
        ),
      );
    }

    for (final r in await _db.customSelect('''
SELECT id, trip_day, MAX(fare_minor - received_minor, 0) AS owed
FROM trips WHERE deleted_at IS NULL
''').get()) {
      out.add(
        _Want(
          const Party(PartyType.customer),
          RefType.trip,
          r.read<String>('id'),
          r.read<int>('trip_day'),
          r.read<int>('owed'),
        ),
      );
    }

    // Driver-paid, reimbursable expenses are owed to the driver (negative).
    for (final r in await _db.customSelect('''
SELECT x.id, x.spent_day,
  COALESCE(t.driver_id, (
    SELECT a.driver_id FROM assignments a
    WHERE a.vehicle_id = x.vehicle_id AND a.deleted_at IS NULL
      AND a.start_day <= x.spent_day
      AND (a.end_day IS NULL OR a.end_day >= x.spent_day)
    ORDER BY a.start_day DESC LIMIT 1)) AS driver_id,
  MAX(x.amount_minor - COALESCE((
    SELECT SUM(la.amount_minor) FROM ledger_allocations la
    WHERE la.ref_type = 'expense' AND la.ref_id = x.id
      AND la.deleted_at IS NULL), 0), 0) AS owed
FROM expenses x LEFT JOIN trips t ON t.id = x.trip_id
WHERE x.deleted_at IS NULL AND x.paid_by = 'driver' AND x.reimbursable = 1
''').get()) {
      final driver = r.read<String?>('driver_id');
      if (driver == null) continue;
      out.add(
        _Want(
          Party(PartyType.driver, driver),
          RefType.expense,
          r.read<String>('id'),
          r.read<int>('spent_day'),
          -r.read<int>('owed'),
        ),
      );
    }
    return out;
  }

  /// Appends a ledger row for every record whose outstanding amount differs
  /// from what the ledger holds. Idempotent. Returns how many rows it added.
  Future<int> post() => _db.transaction(() async {
    final wants = {
      for (final w in await _wants()) '${w.refType.name}/${w.refId}': w,
    };
    final posted = <String, ({int sum, int n, Party party, int day})>{};
    for (final r in await _db.customSelect('''
SELECT ref_type, ref_id, party_type, party_id, SUM(amount_minor) AS s,
  COUNT(*) AS n, MIN(occurred_day) AS d
FROM ledger_entries GROUP BY ref_type, ref_id
''').get()) {
      posted['${r.read<String>('ref_type')}/${r.read<String>('ref_id')}'] = (
        sum: r.read<int>('s'),
        n: r.read<int>('n'),
        party: Party(
          PartyType.values.byName(r.read<String>('party_type')),
          r.read<String>('party_id'),
        ),
        day: r.read<int>('d'),
      );
    }
    var added = 0;
    for (final key in {...wants.keys, ...posted.keys}) {
      final w = wants[key];
      final p = posted[key];
      final posting = postingFor(
        posted: p?.sum ?? 0,
        desired: w?.amount ?? 0,
        existingRows: p?.n ?? 0,
      );
      if (posting == null) continue;
      final party = w?.party ?? p!.party;
      final type = w?.refType.name ?? key.split('/').first;
      final refId = w?.refId ?? key.substring(type.length + 1);
      await _db
          .into(_db.ledgerEntries)
          .insert(
            LedgerEntriesCompanion.insert(
              id: Value('lg:$type:$refId:${p?.n ?? 0}'),
              partyType: party.type.name,
              partyId: Value(party.id),
              refType: type,
              refId: refId,
              kind: posting.kind,
              amountMinor: posting.delta,
              occurredDay: w?.day ?? p!.day,
            ),
            mode: InsertMode.insertOrIgnore,
          );
      added++;
    }
    return added;
  });

  // --- reading --------------------------------------------------------------

  Future<List<PartyBalance>> balances() async {
    await post();
    final rows = await _db.customSelect('''
SELECT l.party_type, l.party_id, SUM(l.amount_minor) AS s, d.name AS name
FROM ledger_entries l LEFT JOIN drivers d
  ON l.party_type = 'driver' AND d.id = l.party_id
GROUP BY l.party_type, l.party_id HAVING s != 0
''').get();
    return [
      for (final r in rows)
        PartyBalance(
          party: Party(
            PartyType.values.byName(r.read<String>('party_type')),
            r.read<String>('party_id'),
          ),
          name: r.read<String?>('name') ?? '',
          balance: Money(r.read<int>('s')),
        ),
    ]..sort((a, b) => b.balance.abs().compareTo(a.balance.abs()));
  }

  /// Everything still owed, per source record, oldest first.
  Future<List<OpenItem>> openItems({Party? party}) async {
    await post();
    final rows = await _db.customSelect('''
SELECT party_type, party_id, ref_type, ref_id, SUM(amount_minor) AS s,
  MIN(occurred_day) AS d
FROM ledger_entries GROUP BY ref_type, ref_id HAVING s != 0
ORDER BY d, ref_id
''').get();
    return [
      for (final r in rows)
        if (party == null ||
            (r.read<String>('party_type') == party.type.name &&
                r.read<String>('party_id') == party.id))
          OpenItem(
            party: Party(
              PartyType.values.byName(r.read<String>('party_type')),
              r.read<String>('party_id'),
            ),
            refType: RefType.values.byName(r.read<String>('ref_type')),
            refId: r.read<String>('ref_id'),
            day: CalendarDay(r.read<int>('d')),
            amount: Money(r.read<int>('s')),
          ),
    ];
  }

  Future<Aging> aging(Party party, CalendarDay today) async => Aging.fromItems(
    (await openItems(party: party)).where((i) => i.isReceivable),
    today,
  );

  /// The party's history: what arose, what was paid.
  Future<List<StatementLine>> statement(Party party) async {
    await post();
    final out = <StatementLine>[];
    for (final r
        in await (_db.select(_db.ledgerEntries)..where(
              (t) =>
                  t.partyType.equals(party.type.name) &
                  t.partyId.equals(party.id),
            ))
            .get()) {
      out.add(
        StatementLine(
          day: CalendarDay(r.occurredDay),
          label: r.refType,
          refType: RefType.values.byName(r.refType),
          amount: Money(r.amountMinor),
          isPayment: false,
        ),
      );
    }
    for (final p
        in await (_db.select(_db.ledgerPayments)..where(
              (t) =>
                  t.partyType.equals(party.type.name) &
                  t.partyId.equals(party.id),
            ))
            .get()) {
      out.add(
        StatementLine(
          day: CalendarDay(p.day),
          label: p.direction,
          amount: Money(p.direction == 'in' ? -p.amountMinor : p.amountMinor),
          isPayment: true,
        ),
      );
    }
    out.sort((a, b) => a.day.compareTo(b.day));
    return out;
  }

  // --- payments -------------------------------------------------------------

  /// Items a payment can be applied to, in or out. Advances are settled
  /// through payouts, so they are not offered here.
  Future<List<OpenItem>> payableItems(
    Party party, {
    required bool incoming,
  }) async => [
    for (final i in await openItems(party: party))
      if (incoming ? i.isReceivable : !i.isReceivable)
        if (i.refType != RefType.advance) i,
  ];

  /// Records money received from (incoming) or paid to a party and applies it
  /// to their open items. By default oldest first; pass `allocations` to
  /// choose (their total must equal [amount]).
  ///
  /// Applying a payment updates the underlying record the normal way: trips
  /// get their received amount raised, jama is collected, and reimbursed
  /// expenses are marked paid in the ledger.
  Future<String> recordPayment({
    required Party party,
    required bool incoming,
    required Money amount,
    required CalendarDay day,
    required CalendarDay today,
    List<Allocation>? allocations,
    String? note,
  }) => _db.transaction(() async {
    if (!amount.isPositive) {
      throw const LedgerException(LedgerError.amountInvalid);
    }
    final items = await payableItems(party, incoming: incoming);
    if (items.isEmpty) throw const LedgerException(LedgerError.nothingOwed);
    final byKey = {for (final i in items) '${i.refType.name}:${i.refId}': i};
    final total = items.map((i) => i.amount.abs()).sum();
    if (amount > total) throw const LedgerException(LedgerError.exceedsOwed);

    final chosen =
        allocations ??
        allocateOldestFirst(amount, [
          for (final i in items)
            OpenEntry('${i.refType.name}:${i.refId}', i.day, i.amount.abs()),
        ]);
    final sum = chosen.map((a) => a.amount).sum();
    if (sum != amount) {
      throw const LedgerException(LedgerError.allocationMismatch);
    }
    for (final a in chosen) {
      final item = byKey[a.entryId];
      if (item == null ||
          a.amount > item.amount.abs() ||
          !a.amount.isPositive) {
        throw const LedgerException(LedgerError.allocationMismatch);
      }
    }

    final paymentId = newId();
    await _db
        .into(_db.ledgerPayments)
        .insert(
          LedgerPaymentsCompanion.insert(
            id: Value(paymentId),
            partyType: party.type.name,
            partyId: Value(party.id),
            direction: incoming ? 'in' : 'out',
            amountMinor: amount.minor,
            day: day.epochDay,
            note: Value(note),
          ),
        );

    final jamaByAssignment = <String, Money>{};
    for (final a in chosen) {
      final item = byKey[a.entryId]!;
      await _db
          .into(_db.ledgerAllocations)
          .insert(
            LedgerAllocationsCompanion.insert(
              paymentId: paymentId,
              refType: item.refType.name,
              refId: item.refId,
              amountMinor: a.amount.minor,
            ),
          );
      switch (item.refType) {
        case RefType.trip:
          await _trips.recordPayment(item.refId, a.amount);
        case RefType.jama:
          final e = await (_db.select(
            _db.jamaEntries,
          )..where((t) => t.id.equals(item.refId))).getSingle();
          jamaByAssignment.update(
            e.assignmentId,
            (m) => m + a.amount,
            ifAbsent: () => a.amount,
          );
        case RefType.expense || RefType.advance:
          break; // settled by the allocation row itself
      }
    }
    for (final e in jamaByAssignment.entries) {
      await _jama.collect(
        assignmentId: e.key,
        amount: e.value,
        day: day,
        today: today,
      );
    }
    await _db.logAudit(
      entity: 'ledger_payment',
      entityId: paymentId,
      action: incoming ? 'in' : 'out',
      diff: {'amount_minor': amount.minor},
    );
    await post();
    return paymentId;
  });

  /// Undoes a payment made to a party (reimbursing an expense) by appending
  /// an opposite one. Money received is undone through its own record (for
  /// example cancelling a jama payment), so those are not reversible here.
  Future<String> reversePayment(String paymentId, CalendarDay day) =>
      _db.transaction(() async {
        final p = await (_db.select(
          _db.ledgerPayments,
        )..where((t) => t.id.equals(paymentId))).getSingleOrNull();
        if (p == null) throw const LedgerException(LedgerError.notFound);
        final already = await (_db.select(
          _db.ledgerPayments,
        )..where((t) => t.reversesId.equals(paymentId))).get();
        if (p.direction != 'out' ||
            p.reversesId != null ||
            already.isNotEmpty) {
          throw const LedgerException(LedgerError.notReversible);
        }
        final id = newId();
        await _db
            .into(_db.ledgerPayments)
            .insert(
              LedgerPaymentsCompanion.insert(
                id: Value(id),
                partyType: p.partyType,
                partyId: Value(p.partyId),
                direction: p.direction,
                amountMinor: -p.amountMinor,
                day: day.epochDay,
                reversesId: Value(paymentId),
              ),
            );
        for (final a in await (_db.select(
          _db.ledgerAllocations,
        )..where((t) => t.paymentId.equals(paymentId))).get()) {
          await _db
              .into(_db.ledgerAllocations)
              .insert(
                LedgerAllocationsCompanion.insert(
                  paymentId: id,
                  refType: a.refType,
                  refId: a.refId,
                  amountMinor: -a.amountMinor,
                ),
              );
        }
        await post();
        return id;
      });

  // --- reconciliation -------------------------------------------------------

  /// Checks the ledger against the records it is derived from and against the
  /// daily rollups. Returns one line per problem; empty means consistent.
  /// Does not post anything.
  Future<List<String>> reconcile() async {
    final problems = <String>[];
    final wants = {
      for (final w in await _wants()) '${w.refType.name}/${w.refId}': w.amount,
    };
    final posted = <String, int>{};
    for (final r
        in await _db
            .customSelect(
              'SELECT ref_type, ref_id, SUM(amount_minor) AS s FROM ledger_entries '
              'GROUP BY ref_type, ref_id',
            )
            .get()) {
      posted['${r.read<String>('ref_type')}/${r.read<String>('ref_id')}'] = r
          .read<int>('s');
    }
    for (final key in {...wants.keys, ...posted.keys}) {
      final w = wants[key] ?? 0;
      final p = posted[key] ?? 0;
      if (w != p) problems.add('$key: ledger $p vs records $w');
    }

    // Unpaid fares per the ledger vs the rollups.
    final ledgerTrips = posted.entries
        .where((e) => e.key.startsWith('trip/'))
        .fold<int>(0, (a, e) => a + e.value);
    final rollup =
        (await _db
                .customSelect(
                  'SELECT COALESCE(SUM(fare_minor - received_minor), 0) AS s '
                  'FROM daily_rollups',
                )
                .getSingle())
            .read<int>('s');
    if (ledgerTrips != rollup) {
      problems.add('unpaid fares: ledger $ledgerTrips vs rollups $rollup');
    }

    // Every payment's allocations add up to the payment.
    for (final r in await _db.customSelect('''
SELECT p.id, p.amount_minor,
  COALESCE((SELECT SUM(a.amount_minor) FROM ledger_allocations a
            WHERE a.payment_id = p.id), 0) AS s
FROM ledger_payments p
''').get()) {
      if (r.read<int>('amount_minor') != r.read<int>('s')) {
        problems.add(
          'payment ${r.read<String>('id')}: allocations ${r.read<int>('s')} '
          'vs amount ${r.read<int>('amount_minor')}',
        );
      }
    }
    return problems;
  }
}

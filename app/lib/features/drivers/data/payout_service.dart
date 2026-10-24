import 'package:drift/drift.dart';
import 'package:meta/meta.dart';
import 'package:vehicle_khata/core/db/app_database.dart';
import 'package:vehicle_khata/core/db/audit.dart';
import 'package:vehicle_khata/core/db/ids.dart';
import 'package:vehicle_khata/core/money/money.dart';
import 'package:vehicle_khata/core/time/calendar_day.dart';
import 'package:vehicle_khata/features/drivers/data/advance_repository.dart';
import 'package:vehicle_khata/features/drivers/data/assignment_repository.dart';
import 'package:vehicle_khata/features/drivers/data/attendance_repository.dart';
import 'package:vehicle_khata/features/drivers/domain/driver.dart';
import 'package:vehicle_khata/features/drivers/domain/pay_calculator.dart';
import 'package:vehicle_khata/features/drivers/domain/pay_model.dart';
import 'package:vehicle_khata/features/drivers/domain/payout_planner.dart';
import 'package:vehicle_khata/features/trips/data/trip_repository.dart';

enum PayoutError {
  assignmentNotFound,
  notThisDriversAssignment,
  notPayable,
  periodOutsideAssignment,
  overlapsExistingPayout,
  nothingToPay,
  payoutNotFound,
}

class PayoutException implements Exception {
  const new(this.error);

  final PayoutError error;

  @override
  String toString() => 'PayoutException($error)';
}

/// What a payout would look like, before it is recorded.
@immutable
class PayoutPreview {
  const new({
    required this.assignment,
    required this.period,
    required this.pay,
    required this.plan,
    required this.requestedPeriod,
  });

  final Assignment assignment;

  /// The requested period limited to the days the assignment covers.
  final DayRange period;
  final DayRange requestedPeriod;
  final PayResult pay;
  final PayoutPlan plan;

  bool get periodWasClipped => period != requestedPeriod;
}

@immutable
class RecordedPayout {
  const new(this.payout, {required this.created});

  final Payout payout;

  /// False when the same period had already been recorded (nothing changed).
  final bool created;
}

/// Calculates and records driver payouts.
///
/// Both [preview] and [record] use the same calculation, and [record] redoes
/// it inside the transaction, so a recorded payout can never disagree with the
/// data it was based on.
class PayoutService {
  new(
    this._db,
    this._assignments,
    this._attendance,
    this._advances, {
    this._trips,
    DateTime Function()? clock,
  }) : // ignore: a private field cannot be a named formal.
       _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final AssignmentRepository _assignments;
  final AttendanceRepository _attendance;
  final AdvanceRepository _advances;
  final TripRepository? _trips;
  final DateTime Function() _clock;

  Stream<List<Payout>> watchForDriver(String driverId) {
    final q = _db.select(_db.payouts)
      ..where((t) => t.driverId.equals(driverId) & t.deletedAt.isNull())
      ..orderBy([
        (t) => OrderingTerm.desc(t.periodEndDay),
        (t) => OrderingTerm.desc(t.id),
      ]);
    return q.watch().map((rows) => rows.map(_toDomain).toList());
  }

  Future<Payout?> get(String id) async {
    final row = await (_db.select(
      _db.payouts,
    )..where((t) => t.id.equals(id) & t.deletedAt.isNull())).getSingleOrNull();
    return row == null ? null : _toDomain(row);
  }

  Future<PayoutPreview> preview({
    required String driverId,
    required String assignmentId,
    required DayRange period,
    Money adjustment = Money.zero,
  }) async {
    final assignment = await _assignments.get(assignmentId);
    if (assignment == null) {
      throw const PayoutException(PayoutError.assignmentNotFound);
    }
    if (assignment.driverId != driverId) {
      throw const PayoutException(PayoutError.notThisDriversAssignment);
    }
    if (assignment.payModel is JamaPay) {
      throw const PayoutException(PayoutError.notPayable);
    }
    // An open-ended assignment covers everything from its start onwards.
    final coveredEnd =
        assignment.end ??
        (period.end.isAfter(assignment.start) ? period.end : assignment.start);
    final covered = DayRange(assignment.start, coveredEnd);
    final clipped = period.intersect(covered);
    if (clipped == null) {
      throw const PayoutException(PayoutError.periodOutsideAssignment);
    }

    final attendance = await _attendance.forRange(driverId, clipped);
    // Trip-based pay comes from the pay worked out on each trip (which
    // includes any amounts the owner overrode).
    final trips = _trips;
    final totals = trips == null
        ? null
        : await trips.totalsForDriver(
            driverId: driverId,
            vehicleId: assignment.vehicleId,
            range: clipped,
          );
    final pay = calculatePay(
      assignment.payModel,
      clipped,
      PayInputs(
        attendance: attendance,
        tripCount: totals?.count ?? 0,
        totalFare: totals?.fare ?? Money.zero,
        totalExpenses: totals?.ownerExpenses ?? Money.zero,
        tripPay: totals?.driverPay,
      ),
    );
    final plan = planPayout(
      earned: pay.earned,
      adjustment: adjustment,
      advances: await _advances.outstanding(driverId),
    );
    return PayoutPreview(
      assignment: assignment,
      period: clipped,
      requestedPeriod: period,
      pay: pay,
      plan: plan,
    );
  }

  /// Records a payout. Recording the same period again returns the existing
  /// payout instead of creating a second one.
  Future<RecordedPayout> record({
    required String driverId,
    required String assignmentId,
    required DayRange period,
    Money adjustment = Money.zero,
    String? adjustmentNote,
    String? note,
  }) {
    return _db.transaction(() async {
      final preview = await this.preview(
        driverId: driverId,
        assignmentId: assignmentId,
        period: period,
        adjustment: adjustment,
      );
      final range = preview.period;
      final key =
          '$driverId|$assignmentId|${range.start.epochDay}|${range.end.epochDay}';

      final same = await (_db.select(
        _db.payouts,
      )..where((t) => t.periodKey.equals(key))).getSingleOrNull();
      if (same != null) return RecordedPayout(_toDomain(same), created: false);

      final overlapping =
          await (_db.select(_db.payouts)
                ..where(
                  (t) =>
                      t.driverId.equals(driverId) &
                      t.assignmentId.equals(assignmentId) &
                      t.deletedAt.isNull() &
                      t.periodStartDay.isSmallerOrEqualValue(
                        range.end.epochDay,
                      ) &
                      t.periodEndDay.isBiggerOrEqualValue(range.start.epochDay),
                )
                ..limit(1))
              .get();
      if (overlapping.isNotEmpty) {
        throw const PayoutException(PayoutError.overlapsExistingPayout);
      }

      final plan = preview.plan;
      if (!plan.gross.isPositive) {
        throw const PayoutException(PayoutError.nothingToPay);
      }

      final id = newId();
      final paidAt = _clock().toUtc().millisecondsSinceEpoch;
      await _db
          .into(_db.payouts)
          .insert(
            PayoutsCompanion.insert(
              id: Value(id),
              driverId: driverId,
              assignmentId: Value(assignmentId),
              periodStartDay: range.start.epochDay,
              periodEndDay: range.end.epochDay,
              earnedMinor: plan.earned.minor,
              adjustmentMinor: Value(plan.adjustment.minor),
              adjustmentNote: Value(_blank(adjustmentNote)),
              deductedMinor: Value(plan.deducted.minor),
              netMinor: plan.net.minor,
              paidAt: paidAt,
              note: Value(_blank(note)),
              periodKey: Value(key),
            ),
          );
      for (final d in plan.deductions) {
        await _db
            .into(_db.payoutAdvanceAllocations)
            .insert(
              PayoutAdvanceAllocationsCompanion.insert(
                payoutId: id,
                advanceId: d.advanceId,
                amountMinor: d.amount.minor,
              ),
            );
      }
      await _db.logAudit(
        entity: 'payout',
        entityId: id,
        action: 'create',
        diff: {
          'driverId': driverId,
          'period': '${range.start.toIso()}..${range.end.toIso()}',
          'earnedMinor': plan.earned.minor,
          'adjustmentMinor': plan.adjustment.minor,
          'deductedMinor': plan.deducted.minor,
          'netMinor': plan.net.minor,
        },
      );
      final row = await (_db.select(
        _db.payouts,
      )..where((t) => t.id.equals(id))).getSingle();
      return RecordedPayout(_toDomain(row), created: true);
    });
  }

  /// Cancels a payout: its advance recoveries are released and the period can
  /// be paid again.
  Future<void> voidPayout(String payoutId) {
    return _db.transaction(() async {
      final row =
          await (_db.select(_db.payouts)
                ..where((t) => t.id.equals(payoutId) & t.deletedAt.isNull()))
              .getSingleOrNull();
      if (row == null) {
        throw const PayoutException(PayoutError.payoutNotFound);
      }
      final allocations =
          await (_db.select(_db.payoutAdvanceAllocations)..where(
                (t) => t.payoutId.equals(payoutId) & t.deletedAt.isNull(),
              ))
              .get();
      for (final a in allocations) {
        await _db.softDelete(_db.payoutAdvanceAllocations, a.id);
      }
      await (_db.update(_db.payouts)..where((t) => t.id.equals(payoutId)))
          .write(const PayoutsCompanion(periodKey: Value(null)));
      await _db.softDelete(_db.payouts, payoutId);
      await _db.logAudit(
        entity: 'payout',
        entityId: payoutId,
        action: 'void',
        diff: {'netMinor': row.netMinor},
      );
    });
  }

  static String? _blank(String? s) {
    final t = s?.trim() ?? '';
    return t.isEmpty ? null : t;
  }

  Payout _toDomain(PayoutRow r) => Payout(
    id: r.id,
    driverId: r.driverId,
    assignmentId: r.assignmentId,
    period: DayRange(
      CalendarDay(r.periodStartDay),
      CalendarDay(r.periodEndDay),
    ),
    earned: Money(r.earnedMinor),
    adjustment: Money(r.adjustmentMinor),
    adjustmentNote: r.adjustmentNote,
    deducted: Money(r.deductedMinor),
    net: Money(r.netMinor),
    paidAt: DateTime.fromMillisecondsSinceEpoch(r.paidAt, isUtc: true),
    note: r.note,
  );
}

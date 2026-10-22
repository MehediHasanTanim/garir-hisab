import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:vehicle_khata/core/money/money.dart';
import 'package:vehicle_khata/core/time/calendar_day.dart';
import 'package:vehicle_khata/features/drivers/data/payout_service.dart';
import 'package:vehicle_khata/features/drivers/domain/attendance.dart';
import 'package:vehicle_khata/features/drivers/domain/pay_model.dart';
import 'package:vehicle_khata/features/vehicles/domain/vehicle_enums.dart';

import '../../helpers/fixtures.dart';

const _salary = SalaryPay(monthly: Money.taka(15000));

Matcher _throwsPayout(PayoutError e) =>
    throwsA(isA<PayoutException>().having((x) => x.error, 'error', e));

void main() {
  late Fixture f;
  late String vehicleId;
  late String driverId;
  late String assignmentId;
  final march = DayRange.month(2026, 3);

  Future<String> assign(
    PayModel model,
    CalendarDay start, {
    String? vehicle,
    BusinessModel? biz,
  }) async {
    final v =
        vehicle ??
        await f.vehicle(
          name: 'V${DateTime.now().microsecondsSinceEpoch}',
          model: biz ?? BusinessModel.salaried,
        );
    return await f.assignments.assign(
      vehicleId: v,
      driverId: driverId,
      payModel: model,
      start: start,
    );
  }

  setUp(() async {
    f = Fixture(clock: () => DateTime.utc(2026, 4, 1, 9));
    vehicleId = await f.vehicle();
    driverId = await f.driver();
    assignmentId = await f.assignments.assign(
      vehicleId: vehicleId,
      driverId: driverId,
      payModel: _salary,
      start: day(2026, 1, 1),
    );
  });
  tearDown(() => f.close());

  Future<RecordedPayout> record({
    DayRange? period,
    Money adjustment = Money.zero,
    String? id,
  }) => f.payouts.record(
    driverId: driverId,
    assignmentId: id ?? assignmentId,
    period: period ?? march,
    adjustment: adjustment,
  );

  group('preview', () {
    test('full month with no marks pays the full salary', () async {
      final p = await f.payouts.preview(
        driverId: driverId,
        assignmentId: assignmentId,
        period: march,
      );
      expect(p.plan.earned, const Money.taka(15000));
      expect(p.plan.net, const Money.taka(15000));
      expect(p.periodWasClipped, isFalse);
    });

    test('uses recorded attendance', () async {
      for (final d in [3, 4, 5]) {
        await f.attendance.mark(
          driverId,
          day(2026, 3, d),
          AttendanceStatus.absent,
        );
      }
      final p = await f.payouts.preview(
        driverId: driverId,
        assignmentId: assignmentId,
        period: march,
      );
      expect(p.plan.earned, const Money(1354839)); // 15000 * 56/62
    });

    test('spec example: 15,000 salary - 4,000 advance = 11,000', () async {
      await f.advances.give(
        driverId: driverId,
        amount: const Money.taka(4000),
        day: day(2026, 3, 5),
      );
      final p = await f.payouts.preview(
        driverId: driverId,
        assignmentId: assignmentId,
        period: march,
      );
      expect(p.plan.net, const Money.taka(11000));
      expect(p.plan.deducted, const Money.taka(4000));
    });

    test('a bonus and a penalty change the net', () async {
      final bonus = await f.payouts.preview(
        driverId: driverId,
        assignmentId: assignmentId,
        period: march,
        adjustment: const Money.taka(1000),
      );
      expect(bonus.plan.net, const Money.taka(16000));
      final penalty = await f.payouts.preview(
        driverId: driverId,
        assignmentId: assignmentId,
        period: march,
        adjustment: const Money.taka(-2000),
      );
      expect(penalty.plan.net, const Money.taka(13000));
    });

    test('does not write anything', () async {
      await f.advances.give(
        driverId: driverId,
        amount: const Money.taka(100),
        day: day(2026, 3, 1),
      );
      await f.payouts.preview(
        driverId: driverId,
        assignmentId: assignmentId,
        period: march,
      );
      expect(await f.db.select(f.db.payouts).get(), isEmpty);
      expect(await f.db.select(f.db.payoutAdvanceAllocations).get(), isEmpty);
    });

    test('the period is limited to the days the assignment covers', () async {
      final late = await assign(_salary, day(2026, 3, 11));
      final p = await f.payouts.preview(
        driverId: driverId,
        assignmentId: late,
        period: march,
      );
      expect(p.period, DayRange(day(2026, 3, 11), day(2026, 3, 31)));
      expect(p.periodWasClipped, isTrue);
      expect(p.plan.earned, const Money.taka(15000).proportion(21 * 2, 31 * 2));
    });

    test('an ended assignment is paid only until it ended', () async {
      final v = await f.vehicle(name: 'Other');
      final a = await f.assignments.assign(
        vehicleId: v,
        driverId: driverId,
        payModel: _salary,
        start: day(2026, 1, 1),
      );
      await f.assignments.end(a, day(2026, 3, 10));
      final p = await f.payouts.preview(
        driverId: driverId,
        assignmentId: a,
        period: march,
      );
      expect(p.period.end, day(2026, 3, 10));
    });

    test('a period outside the assignment is rejected', () async {
      final late = await assign(_salary, day(2026, 6, 1));
      await expectLater(
        f.payouts.preview(
          driverId: driverId,
          assignmentId: late,
          period: march,
        ),
        _throwsPayout(PayoutError.periodOutsideAssignment),
      );
    });

    test('jama assignments are not paid out', () async {
      final v = await f.vehicle(name: 'Jama', model: BusinessModel.jama);
      final a = await f.assignments.assign(
        vehicleId: v,
        driverId: driverId,
        payModel: const JamaPay(amount: Money.taka(600)),
        start: day(2026, 1, 1),
      );
      await expectLater(
        f.payouts.preview(driverId: driverId, assignmentId: a, period: march),
        _throwsPayout(PayoutError.notPayable),
      );
    });

    test('wrong driver or unknown assignment', () async {
      final other = await f.driver(name: 'Other');
      await expectLater(
        f.payouts.preview(
          driverId: other,
          assignmentId: assignmentId,
          period: march,
        ),
        _throwsPayout(PayoutError.notThisDriversAssignment),
      );
      await expectLater(
        f.payouts.preview(
          driverId: driverId,
          assignmentId: 'nope',
          period: march,
        ),
        _throwsPayout(PayoutError.assignmentNotFound),
      );
    });
  });

  group('record', () {
    test('stores the payout, recovers the advance and audits it', () async {
      final adv = await f.advances.give(
        driverId: driverId,
        amount: const Money.taka(4000),
        day: day(2026, 3, 5),
      );
      final r = await record(adjustment: const Money.taka(500));
      expect(r.created, isTrue);
      final p = r.payout;
      expect(p.driverId, driverId);
      expect(p.assignmentId, assignmentId);
      expect(p.period, march);
      expect(p.earned, const Money.taka(15000));
      expect(p.adjustment, const Money.taka(500));
      expect(p.deducted, const Money.taka(4000));
      expect(p.net, const Money.taka(11500));
      expect(p.paidAt, DateTime.utc(2026, 4, 1, 9));

      final advances = await f.advances.watchForDriver(driverId).first;
      expect(advances.single.id, adv);
      expect(advances.single.recovered, const Money.taka(4000));
      expect(advances.single.isSettled, isTrue);
      expect(await f.advances.outstanding(driverId), isEmpty);

      final log = await f.audit('payout', p.id);
      expect(log.single.action, 'create');
      expect((jsonDecode(log.single.diffJson) as Map)['netMinor'], 1150000);
    });

    test(
      'is idempotent: recording the same period again changes nothing',
      () async {
        await f.advances.give(
          driverId: driverId,
          amount: const Money.taka(4000),
          day: day(2026, 3, 5),
        );
        final first = await record();
        final again = await record();
        expect(again.created, isFalse);
        expect(again.payout.id, first.payout.id);
        expect(await f.db.select(f.db.payouts).get(), hasLength(1));
        expect(
          await f.db.select(f.db.payoutAdvanceAllocations).get(),
          hasLength(1),
        );
        expect(
          (await f.advances.watchForDriver(driverId).first).single.recovered,
          const Money.taka(4000),
        );
        expect(await f.audit('payout'), hasLength(1));
      },
    );

    test('overlapping periods are rejected; adjacent ones are fine', () async {
      await record();
      await expectLater(
        record(period: DayRange(day(2026, 3, 15), day(2026, 4, 15))),
        _throwsPayout(PayoutError.overlapsExistingPayout),
      );
      await expectLater(
        record(period: DayRange(day(2026, 2, 20), day(2026, 3, 1))),
        _throwsPayout(PayoutError.overlapsExistingPayout),
      );
      final april = await record(period: DayRange.month(2026, 4));
      expect(april.created, isTrue);
    });

    test(
      'an advance larger than the earnings is recovered over several payouts',
      () async {
        await f.advances.give(
          driverId: driverId,
          amount: const Money.taka(20000),
          day: day(2026, 3, 1),
        );
        final march = await record();
        expect(march.payout.deducted, const Money.taka(15000));
        expect(march.payout.net, Money.zero);
        expect(
          (await f.advances.outstanding(driverId)).single.remaining,
          const Money.taka(5000),
        );

        final april = await record(period: DayRange.month(2026, 4));
        expect(april.payout.deducted, const Money.taka(5000));
        expect(april.payout.net, const Money.taka(10000));
        expect(await f.advances.outstanding(driverId), isEmpty);
      },
    );

    test('recovers the oldest advance first across several advances', () async {
      final old = await f.advances.give(
        driverId: driverId,
        amount: const Money.taka(10000),
        day: day(2026, 2, 1),
      );
      await f.advances.give(
        driverId: driverId,
        amount: const Money.taka(10000),
        day: day(2026, 3, 1),
      );
      await record();
      final list = await f.advances.watchForDriver(driverId).first;
      final byId = {for (final a in list) a.id: a};
      expect(byId[old]!.recovered, const Money.taka(10000));
      expect(
        list.firstWhere((a) => a.id != old).recovered,
        const Money.taka(5000),
      );
    });

    test('nothing to pay is rejected', () async {
      final v = await f.vehicle(name: 'Wage', model: BusinessModel.dailyWage);
      final a = await f.assignments.assign(
        vehicleId: v,
        driverId: driverId,
        payModel: const DailyWagePay(perDay: Money.taka(800)),
        start: day(2026, 1, 1),
      );
      await expectLater(record(id: a), _throwsPayout(PayoutError.nothingToPay));
      // A bonus alone is enough to pay out.
      final r = await record(id: a, adjustment: const Money.taka(300));
      expect(r.payout.net, const Money.taka(300));
    });

    test(
      'trip-based pay is zero until trips exist, so it cannot be paid yet',
      () async {
        final v = await f.vehicle(
          name: 'Pickup',
          model: BusinessModel.contract,
        );
        final a = await f.assignments.assign(
          vehicleId: v,
          driverId: driverId,
          payModel: const PerTripPay(perTrip: Money.taka(250)),
          start: day(2026, 1, 1),
        );
        await expectLater(
          record(id: a),
          _throwsPayout(PayoutError.nothingToPay),
        );
      },
    );

    test('a failed record leaves no partial data', () async {
      await f.advances.give(
        driverId: driverId,
        amount: const Money.taka(100),
        day: day(2026, 3, 1),
      );
      await record();
      await expectLater(
        record(period: DayRange(day(2026, 3, 10), day(2026, 3, 20))),
        throwsA(isA<PayoutException>()),
      );
      expect(await f.db.select(f.db.payouts).get(), hasLength(1));
      expect(
        await f.db.select(f.db.payoutAdvanceAllocations).get(),
        hasLength(1),
      );
    });
  });

  group('void', () {
    test('releases the advance recovery and frees the period', () async {
      await f.advances.give(
        driverId: driverId,
        amount: const Money.taka(4000),
        day: day(2026, 3, 5),
      );
      final first = await record();
      await f.payouts.voidPayout(first.payout.id);

      expect(await f.payouts.get(first.payout.id), isNull);
      expect(await f.payouts.watchForDriver(driverId).first, isEmpty);
      expect(
        (await f.advances.outstanding(driverId)).single.remaining,
        const Money.taka(4000),
      );

      final again = await record();
      expect(again.created, isTrue);
      expect(again.payout.id, isNot(first.payout.id));
      expect(again.payout.net, const Money.taka(11000));
    });

    test('is audited, and a missing payout is an error', () async {
      final r = await record();
      await f.payouts.voidPayout(r.payout.id);
      expect((await f.audit('payout', r.payout.id)).map((e) => e.action), [
        'create',
        'void',
      ]);
      await expectLater(
        f.payouts.voidPayout(r.payout.id),
        _throwsPayout(PayoutError.payoutNotFound),
      );
    });

    test(
      'a recovered advance cannot be deleted until its payout is voided',
      () async {
        final adv = await f.advances.give(
          driverId: driverId,
          amount: const Money.taka(1000),
          day: day(2026, 3, 1),
        );
        final r = await record();
        await expectLater(f.advances.remove(adv), throwsA(anything));
        await f.payouts.voidPayout(r.payout.id);
        await f.advances.remove(adv);
      },
    );
  });

  test('payout history is listed newest period first', () async {
    await record(period: DayRange.month(2026, 2));
    await record();
    final list = await f.payouts.watchForDriver(driverId).first;
    expect(list.map((p) => p.period.start.month), [3, 2]);
  });
}

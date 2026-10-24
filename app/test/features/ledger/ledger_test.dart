import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:vehicle_khata/core/money/money.dart';
import 'package:vehicle_khata/core/time/calendar_day.dart';
import 'package:vehicle_khata/features/drivers/domain/pay_model.dart';
import 'package:vehicle_khata/features/expenses/domain/expense.dart';
import 'package:vehicle_khata/features/jama/domain/jama_logic.dart';
import 'package:vehicle_khata/features/ledger/data/ledger_service.dart';
import 'package:vehicle_khata/features/ledger/domain/ledger_logic.dart';
import 'package:vehicle_khata/features/trips/domain/trip.dart';
import 'package:vehicle_khata/features/vehicles/domain/vehicle_enums.dart';

import '../../helpers/fixtures.dart';

CalendarDay d(int y, int m, int day) => CalendarDay.of(y, m, day);
const customer = Party(PartyType.customer);

void main() {
  group('ageing', () {
    final today = d(2026, 5, 31);
    test('bucket edges: 0-7, 8-30, over 30 days', () {
      expect(ageBucket(today, today), AgeBucket.days0to7);
      expect(ageBucket(today.addDays(-7), today), AgeBucket.days0to7);
      expect(ageBucket(today.addDays(-8), today), AgeBucket.days8to30);
      expect(ageBucket(today.addDays(-30), today), AgeBucket.days8to30);
      expect(ageBucket(today.addDays(-31), today), AgeBucket.over30);
    });

    test('totals by bucket', () {
      OpenItem item(int ago, int taka) => OpenItem(
        party: customer,
        refType: RefType.trip,
        refId: 'x$ago',
        day: today.addDays(-ago),
        amount: Money.taka(taka),
      );
      final a = Aging.fromItems([
        item(1, 100),
        item(9, 200),
        item(40, 400),
        item(5, 50),
      ], today);
      expect(a.days0to7, const Money.taka(150));
      expect(a.days8to30, const Money.taka(200));
      expect(a.over30, const Money.taka(400));
      expect(a.total, const Money.taka(750));
    });
  });

  test('postingFor', () {
    expect(postingFor(posted: 0, desired: 0, existingRows: 0), isNull);
    expect(
      postingFor(posted: 0, desired: 500, existingRows: 0)!.kind,
      'accrual',
    );
    expect(postingFor(posted: 500, desired: 200, existingRows: 1)!.delta, -300);
    expect(
      postingFor(posted: 500, desired: 0, existingRows: 1)!.kind,
      'reversal',
    );
    expect(
      postingFor(posted: 0, desired: 500, existingRows: 2)!.kind,
      'adjust',
    );
  });

  group('ledger', () {
    late Fixture fx;
    late String vehicle;
    late String driver;

    setUp(() async {
      fx = Fixture(clock: () => DateTime.utc(2026, 4, 20, 9));
      vehicle = await fx.vehicle();
      driver = await fx.driver();
      await fx.categories.ensureDefaults();
    });
    tearDown(() => fx.close());

    Future<String> unpaidTrip(int fare, int day, {int received = 0}) =>
        fx.trips.create(
          TripDraft(
            vehicleId: vehicle,
            startedAt: DateTime.utc(2026, 4, day, 8),
            fare: Money.taka(fare),
            received: Money.taka(received),
            driverPay: Money.zero,
          ),
        );

    Future<int> rowCount() async =>
        (await fx.db
                .customSelect('SELECT COUNT(*) c FROM ledger_entries')
                .getSingle())
            .read<int>('c');

    test('unpaid fares post once; posting again adds nothing', () async {
      final t = await unpaidTrip(1000, 10, received: 400);
      expect(await fx.ledger.post(), 1);
      expect(await fx.ledger.post(), 0);
      final b = await fx.ledger.balances();
      expect(b.single.party, customer);
      expect(b.single.balance, const Money.taka(600));
      final e = await fx.db
          .customSelect('SELECT id, kind FROM ledger_entries')
          .getSingle();
      expect(e.read<String>('id'), 'lg:trip:$t:0');
      expect(e.read<String>('kind'), 'accrual');
    });

    test('a change appends a row and never edits an old one', () async {
      final t = await unpaidTrip(1000, 10);
      await fx.ledger.post();
      final first =
          (await fx.db.customSelect('SELECT * FROM ledger_entries').getSingle())
              .data;
      await fx.trips.recordPayment(t, const Money.taka(300));
      await fx.ledger.post();
      await fx.trips.recordPayment(t, const Money.taka(700));
      await fx.ledger.post();
      final rows = await fx.db
          .customSelect('SELECT * FROM ledger_entries ORDER BY id')
          .get();
      expect(
        rows.map((r) => r.read<int>('amount_minor') ~/ 100),
        [100 * -0 + 1000, -300, -700].map((x) => x),
      );
      expect(rows.map((r) => r.read<String>('kind')), [
        'accrual',
        'adjust',
        'reversal',
      ]);
      expect(rows.first.data, first, reason: 'the first row is untouched');
      expect(await fx.ledger.balances(), isEmpty);
    });

    test('deleting a trip reverses what it owed', () async {
      final t = await unpaidTrip(800, 12);
      await fx.ledger.post();
      await fx.trips.delete(t);
      await fx.ledger.post();
      expect(await fx.ledger.balances(), isEmpty);
      expect(await rowCount(), 2);
    });

    test('driver dues: jama baki and unrecovered advances', () async {
      final jv = await fx.vehicle(name: 'Jama', model: BusinessModel.jama);
      final a = await fx.assignments.assign(
        vehicleId: jv,
        driverId: driver,
        payModel: const JamaPay(amount: Money.taka(600)),
        start: d(2026, 4, 18),
      );
      await fx.jama.generate(d(2026, 4, 20));
      await fx.advances.give(
        driverId: driver,
        amount: const Money.taka(1000),
        day: d(2026, 4, 10),
      );
      var b = await fx.ledger.balances();
      expect(b.single.party, Party(PartyType.driver, driver));
      expect(b.single.balance, const Money.taka(1800 + 1000));

      await fx.jama.collect(
        assignmentId: a,
        amount: const Money.taka(600),
        day: d(2026, 4, 20),
        today: d(2026, 4, 20),
      );
      b = await fx.ledger.balances();
      expect(b.single.balance, const Money.taka(1200 + 1000));
    });

    test('reimbursable driver-paid expense is payable to the driver', () async {
      await fx.assignments.assign(
        vehicleId: vehicle,
        driverId: driver,
        payModel: salary15000,
        start: d(2026, 4, 1),
      );
      final x = await fx.expenses.create(
        vehicle,
        ExpenseDraft(
          categoryId: 'default:fuel',
          amount: const Money.taka(500),
          spentAt: DateTime.utc(2026, 4, 12, 6),
          paidBy: PaidBy.driver,
          reimbursable: true,
        ),
      );
      // Driver-paid but not reimbursable: not a debt.
      await fx.expenses.create(
        vehicle,
        ExpenseDraft(
          categoryId: 'default:toll',
          amount: const Money.taka(80),
          spentAt: DateTime.utc(2026, 4, 12, 7),
          paidBy: PaidBy.driver,
        ),
      );
      final party = Party(PartyType.driver, driver);
      final b = await fx.ledger.balances();
      expect(b.single.balance, const Money.taka(-500));

      final pid = await fx.ledger.recordPayment(
        party: party,
        incoming: false,
        amount: const Money.taka(200),
        day: d(2026, 4, 20),
        today: d(2026, 4, 20),
      );
      expect(
        (await fx.ledger.balances()).single.balance,
        const Money.taka(-300),
      );

      // Undo appends an opposite payment; the debt is back.
      await fx.ledger.reversePayment(pid, d(2026, 4, 21));
      expect(
        (await fx.ledger.balances()).single.balance,
        const Money.taka(-500),
      );
      await expectLater(
        fx.ledger.reversePayment(pid, d(2026, 4, 21)),
        throwsA(
          isA<LedgerException>().having(
            (e) => e.error,
            'error',
            LedgerError.notReversible,
          ),
        ),
      );
      expect(await fx.ledger.reconcile(), isEmpty);

      await fx.ledger.recordPayment(
        party: party,
        incoming: false,
        amount: const Money.taka(500),
        day: d(2026, 4, 22),
        today: d(2026, 4, 22),
      );
      expect(await fx.ledger.balances(), isEmpty);
      expect(x, isNotEmpty);
    });

    test('a payment received is applied to the oldest trips first', () async {
      final t1 = await unpaidTrip(1000, 1);
      final t2 = await unpaidTrip(1000, 2);
      final t3 = await unpaidTrip(1000, 3);
      await fx.ledger.recordPayment(
        party: customer,
        incoming: true,
        amount: const Money.taka(1500),
        day: d(2026, 4, 20),
        today: d(2026, 4, 20),
      );
      Future<int> received(String id) async =>
          (await fx.trips.get(id))!.trip.received.minor ~/ 100;
      expect(await received(t1), 1000);
      expect(await received(t2), 500);
      expect(await received(t3), 0);
      expect(
        (await fx.ledger.balances()).single.balance,
        const Money.taka(1500),
      );
      expect(await fx.ledger.reconcile(), isEmpty);
    });

    test('manual allocation overrides oldest-first', () async {
      final t1 = await unpaidTrip(1000, 1);
      final t2 = await unpaidTrip(1000, 2);
      await fx.ledger.recordPayment(
        party: customer,
        incoming: true,
        amount: const Money.taka(700),
        day: d(2026, 4, 20),
        today: d(2026, 4, 20),
        allocations: [Allocation('trip:$t2', const Money.taka(700))],
      );
      expect((await fx.trips.get(t1))!.trip.received, Money.zero);
      expect((await fx.trips.get(t2))!.trip.received, const Money.taka(700));
    });

    test('bad payments are refused', () async {
      final t = await unpaidTrip(1000, 1);
      Future<void> pay(Money m, {List<Allocation>? alloc}) =>
          fx.ledger.recordPayment(
            party: customer,
            incoming: true,
            amount: m,
            day: d(2026, 4, 20),
            today: d(2026, 4, 20),
            allocations: alloc,
          );
      Matcher err(LedgerError e) =>
          throwsA(isA<LedgerException>().having((x) => x.error, 'error', e));
      await expectLater(pay(Money.zero), err(LedgerError.amountInvalid));
      await expectLater(
        pay(const Money.taka(1001)),
        err(LedgerError.exceedsOwed),
      );
      await expectLater(
        pay(
          const Money.taka(500),
          alloc: [Allocation('trip:$t', const Money.taka(400))],
        ),
        err(LedgerError.allocationMismatch),
      );
      await expectLater(
        pay(
          const Money.taka(500),
          alloc: [const Allocation('trip:nope', Money.taka(500))],
        ),
        err(LedgerError.allocationMismatch),
      );
      await fx.ledger.recordPayment(
        party: customer,
        incoming: true,
        amount: const Money.taka(1000),
        day: d(2026, 4, 20),
        today: d(2026, 4, 20),
      );
      await expectLater(pay(const Money.taka(1)), err(LedgerError.nothingOwed));
      // Money received cannot be reversed here.
      final id =
          (await fx.db
                  .customSelect('SELECT id FROM ledger_payments')
                  .getSingle())
              .read<String>('id');
      await expectLater(
        fx.ledger.reversePayment(id, d(2026, 4, 21)),
        err(LedgerError.notReversible),
      );
    });

    test('reconcile finds a stray ledger row and a broken payment', () async {
      await unpaidTrip(1000, 1);
      await fx.ledger.post();
      expect(await fx.ledger.reconcile(), isEmpty);
      await fx.db.customStatement(
        "INSERT INTO ledger_entries (id, owner_id, created_at, updated_at, rev, dirty, party_type, party_id, ref_type, ref_id, kind, amount_minor, occurred_day) VALUES ('bad', 'local', 1, 1, 0, 1, 'customer', '', 'trip', 'ghost', 'accrual', 5000, 1)",
      );
      final problems = await fx.ledger.reconcile();
      expect(problems.any((p) => p.contains('trip/ghost')), isTrue);
      expect(problems.any((p) => p.contains('unpaid fares')), isTrue);
    });

    test(
      'property: random payments keep ledger, trips and rollups in step',
      () async {
        final rnd = Random(7);
        for (var i = 1; i <= 8; i++) {
          await unpaidTrip(500 + rnd.nextInt(1500), i);
        }
        for (var round = 0; round < 10; round++) {
          final owed = (await fx.ledger.balances()).fold(
            Money.zero,
            (a, b) => a + b.balance,
          );
          if (!owed.isPositive) break;
          final pay = Money(1 + rnd.nextInt(owed.minor));
          await fx.ledger.recordPayment(
            party: customer,
            incoming: true,
            amount: pay,
            day: d(2026, 4, 20),
            today: d(2026, 4, 20),
          );
          final after = (await fx.ledger.balances()).fold(
            Money.zero,
            (a, b) => a + b.balance,
          );
          expect(after, owed - pay);
          expect(await fx.ledger.reconcile(), isEmpty);
        }
      },
    );
  });
}

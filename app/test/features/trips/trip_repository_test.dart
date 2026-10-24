import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:vehicle_khata/core/money/money.dart';
import 'package:vehicle_khata/core/time/calendar_day.dart';
import 'package:vehicle_khata/features/expenses/domain/expense.dart';
import 'package:vehicle_khata/features/trips/data/trip_repository.dart';
import 'package:vehicle_khata/features/trips/domain/trip.dart';
import 'package:vehicle_khata/features/vehicles/domain/vehicle_enums.dart';

import '../../helpers/fixtures.dart';

Matcher _throwsTrip(TripError e) =>
    throwsA(isA<TripException>().having((x) => x.error, 'error', e));

ExpenseDraft _exp(
  int taka, {
  String cat = 'default:fuel',
  PaidBy by = PaidBy.owner,
  bool reimb = false,
}) => ExpenseDraft(
  categoryId: cat,
  amount: Money.taka(taka),
  paidBy: by,
  reimbursable: reimb,
);

void main() {
  late Fixture f;
  late String vehicleId;
  late String driverId;

  // Noon UTC avoids day-boundary surprises in any timezone.
  DateTime at(int m, int d) => DateTime.utc(2026, m, d, 6);

  TripDraft draft({
    String? vehicle,
    String? driver,
    DateTime? when,
    int fare = 4500,
    int? received,
    int pay = 0,
    String? from,
    String? to,
    List<ExpenseDraft> expenses = const [],
    int? distanceM,
  }) => TripDraft(
    vehicleId: vehicle ?? vehicleId,
    driverId: driver ?? driverId,
    startedAt: when ?? at(3, 10),
    fare: Money.taka(fare),
    received: Money.taka(received ?? fare),
    driverPay: Money.taka(pay),
    fromPlace: from,
    toPlace: to,
    distanceM: distanceM,
    expenses: expenses,
  );

  Future<List<TripSummary>> list([TripFilter filter = const TripFilter()]) =>
      f.trips.watch(filter).first;

  setUp(() async {
    f = Fixture();
    await f.categories.ensureDefaults();
    vehicleId = await f.vehicle(
      model: BusinessModel.contract,
      type: VehicleType.pickup,
    );
    driverId = await f.driver();
  });
  tearDown(() => f.close());

  group('create and read', () {
    test('stores every field and its expenses', () async {
      final id = await f.trips.create(
        TripDraft(
          vehicleId: vehicleId,
          driverId: driverId,
          startedAt: at(3, 10),
          fromPlace: '  Dhaka ',
          toPlace: 'Chattogram',
          distanceM: 245000,
          fare: const Money.taka(18000),
          received: const Money.taka(8000),
          driverPay: const Money.taka(1500),
          driverPayOverridden: true,
          loadNote: '5 ton rice',
          note: 'Early start',
          expenses: [
            _exp(5500),
            _exp(900, cat: 'default:toll'),
            const ExpenseDraft(
              categoryId: 'default:fuel',
              amount: Money.taka(300),
              paidBy: PaidBy.driver,
              reimbursable: true,
              note: 'Top-up',
              qtyMilli: 3500,
              odometerM: 120000000,
            ),
          ],
        ),
      );

      final d = (await f.trips.get(id))!;
      final t = d.trip;
      expect(t.vehicleId, vehicleId);
      expect(t.driverId, driverId);
      expect(t.startedAt, at(3, 10));
      expect(t.fromPlace, 'Dhaka');
      expect(t.toPlace, 'Chattogram');
      expect(t.distanceM, 245000);
      expect(t.fare, const Money.taka(18000));
      expect(t.received, const Money.taka(8000));
      expect(t.due, const Money.taka(10000));
      expect(t.status, PaymentStatus.partial);
      expect(t.driverPay, const Money.taka(1500));
      expect(t.driverPayOverridden, isTrue);
      expect(t.loadNote, '5 ton rice');
      expect(t.note, 'Early start');
      expect(d.expenses, hasLength(3));
      final top = d.expenses.firstWhere((e) => e.note == 'Top-up');
      expect(top.paidBy, PaidBy.driver);
      expect(top.reimbursable, isTrue);
      expect(top.qtyMilli, 3500);
      expect(top.odometerM, 120000000);
      expect(top.tripId, id);
      expect(top.vehicleId, vehicleId);
      expect(top.spentAt, at(3, 10));
    });

    test('a trip needs no driver, route or expenses', () async {
      final id = await f.trips.create(
        TripDraft(
          vehicleId: vehicleId,
          startedAt: at(3, 1),
          fare: const Money.taka(100),
          received: const Money.taka(100),
          driverPay: Money.zero,
        ),
      );
      final t = (await f.trips.get(id))!.trip;
      expect(t.driverId, isNull);
      expect(t.fromPlace, isNull);
      expect(t.distanceM, isNull);
    });

    test('only a driver-paid expense can be reimbursable', () async {
      final id = await f.trips.create(
        draft(expenses: [_exp(100, reimb: true)]),
      );
      expect((await f.trips.get(id))!.expenses.single.reimbursable, isFalse);
    });

    test('the trip day is the local calendar day', () async {
      final local = DateTime(2026, 3, 10, 23, 30);
      final id = await f.trips.create(draft(when: local.toUtc()));
      expect((await f.trips.get(id))!.trip.day, CalendarDay.of(2026, 3, 10));
    });

    test('unknown trip', () async {
      expect(await f.trips.get('nope'), isNull);
    });
  });

  group('validation', () {
    test('fare must be positive', () async {
      await expectLater(
        f.trips.create(draft(fare: 0, received: 0)),
        _throwsTrip(TripError.fareRequired),
      );
    });

    test('received must be between 0 and the fare', () async {
      await expectLater(
        f.trips.create(draft(fare: 100, received: 101)),
        _throwsTrip(TripError.receivedTooHigh),
      );
      await expectLater(
        f.trips.create(
          TripDraft(
            vehicleId: vehicleId,
            startedAt: at(3, 1),
            fare: const Money.taka(100),
            received: const Money(-1),
            driverPay: Money.zero,
          ),
        ),
        _throwsTrip(TripError.receivedNegative),
      );
    });

    test('distance and driver pay cannot be negative', () async {
      await expectLater(
        f.trips.create(draft(distanceM: -1)),
        _throwsTrip(TripError.distanceInvalid),
      );
      await expectLater(
        f.trips.create(
          TripDraft(
            vehicleId: vehicleId,
            startedAt: at(3, 1),
            fare: const Money.taka(100),
            received: const Money.taka(100),
            driverPay: const Money(-1),
          ),
        ),
        _throwsTrip(TripError.driverPayNegative),
      );
    });

    test('vehicle, driver and categories must exist', () async {
      await expectLater(
        f.trips.create(draft(vehicle: 'nope')),
        _throwsTrip(TripError.vehicleNotFound),
      );
      await expectLater(
        f.trips.create(draft(driver: 'nope')),
        _throwsTrip(TripError.driverNotFound),
      );
      await expectLater(
        f.trips.create(draft(expenses: [_exp(100, cat: 'nope')])),
        _throwsTrip(TripError.categoryNotFound),
      );
    });

    test('expense amounts must be positive', () async {
      await expectLater(
        f.trips.create(draft(expenses: [_exp(0)])),
        _throwsTrip(TripError.expenseAmountInvalid),
      );
    });

    test('a rejected trip leaves nothing behind', () async {
      await expectLater(
        f.trips.create(draft(expenses: [_exp(100), _exp(0)])),
        throwsA(anything),
      );
      expect(await f.db.select(f.db.trips).get(), isEmpty);
      expect(await f.db.select(f.db.expenses).get(), isEmpty);
    });
  });

  group('update', () {
    test('changes the trip and reconciles expenses', () async {
      final id = await f.trips.create(
        draft(
          expenses: [
            _exp(900),
            _exp(200, cat: 'default:toll'),
          ],
        ),
      );
      final before = (await f.trips.get(id))!;
      final fuel = before.expenses.firstWhere(
        (e) => e.categoryId == 'default:fuel',
      );

      await f.trips.update(
        id,
        draft(
          fare: 5000,
          received: 2000,
          from: 'A',
          expenses: [
            ExpenseDraft.fromExpense(fuel)
                .copyWith(amount: const Money.taka(950)), // edited
            _exp(300, cat: 'default:parking'), // added; toll removed
          ],
        ),
      );

      final after = (await f.trips.get(id))!;
      expect(after.trip.fare, const Money.taka(5000));
      expect(after.trip.status, PaymentStatus.partial);
      expect(after.trip.fromPlace, 'A');
      expect(
        after.expenses
            .map((e) => (e.categoryId, e.amount.minor ~/ 100))
            .toSet(),
        {('default:fuel', 950), ('default:parking', 300)},
      );
      // The edited expense kept its identity.
      expect(after.expenses.any((e) => e.id == fuel.id), isTrue);
      // The removed one is only soft-deleted.
      expect(await f.db.select(f.db.expenses).get(), hasLength(3));
    });

    test('moving a trip to another vehicle moves its expenses too', () async {
      final other = await f.vehicle(
        name: 'Other',
        model: BusinessModel.contract,
      );
      final id = await f.trips.create(draft(expenses: [_exp(100)]));
      final e = (await f.trips.get(id))!.expenses.single;
      await f.trips.update(
        id,
        draft(vehicle: other, expenses: [ExpenseDraft.fromExpense(e)]),
      );
      expect((await f.trips.get(id))!.expenses.single.vehicleId, other);
    });

    test('is validated and unknown trips are rejected', () async {
      final id = await f.trips.create(draft());
      await expectLater(
        f.trips.update(id, draft(fare: 100, received: 200)),
        _throwsTrip(TripError.receivedTooHigh),
      );
      await expectLater(
        f.trips.update('nope', draft()),
        _throwsTrip(TripError.tripNotFound),
      );
      expect((await f.trips.get(id))!.trip.fare, const Money.taka(4500));
    });

    test('bumps rev and marks the row dirty', () async {
      final id = await f.trips.create(draft());
      final before = await f.db.select(f.db.trips).getSingle();
      await f.trips.update(id, draft(fare: 4600, received: 4600));
      final after = await f.db.select(f.db.trips).getSingle();
      expect(after.rev, before.rev + 1);
      expect(after.dirty, isTrue);
    });
  });

  group('delete', () {
    test('soft-deletes the trip and its expenses', () async {
      final id = await f.trips.create(draft(expenses: [_exp(100), _exp(200)]));
      await f.trips.delete(id);
      expect(await f.trips.get(id), isNull);
      expect(await list(), isEmpty);
      final rows = await f.db.select(f.db.trips).get();
      expect(rows.single.deletedAt, isNotNull);
      expect(
        (await f.db.select(f.db.expenses).get()).every(
          (e) => e.deletedAt != null,
        ),
        isTrue,
      );
      await expectLater(
        f.trips.delete(id),
        _throwsTrip(TripError.tripNotFound),
      );
    });
  });

  group('payments', () {
    test('records money received until fully paid', () async {
      final id = await f.trips.create(draft(fare: 1000, received: 0));
      expect((await f.trips.get(id))!.trip.status, PaymentStatus.unpaid);
      await f.trips.recordPayment(id, const Money.taka(400));
      expect((await f.trips.get(id))!.trip.status, PaymentStatus.partial);
      await f.trips.recordPayment(id, const Money.taka(600));
      final t = (await f.trips.get(id))!.trip;
      expect(t.status, PaymentStatus.paid);
      expect(t.received, const Money.taka(1000));
    });

    test('cannot overpay or record zero', () async {
      final id = await f.trips.create(draft(fare: 1000, received: 900));
      await expectLater(
        f.trips.recordPayment(id, const Money.taka(101)),
        _throwsTrip(TripError.paymentInvalid),
      );
      await expectLater(
        f.trips.recordPayment(id, Money.zero),
        _throwsTrip(TripError.paymentInvalid),
      );
      await expectLater(
        f.trips.recordPayment('nope', const Money.taka(1)),
        _throwsTrip(TripError.tripNotFound),
      );
    });
  });

  group('list', () {
    test('newest first with owner expenses and profit', () async {
      await f.trips.create(draft(when: at(3, 1), fare: 1000, pay: 100));
      await f.trips.create(
        draft(
          when: at(3, 5),
          pay: 900,
          expenses: [
            _exp(900),
            _exp(200, cat: 'default:toll'),
            _exp(300, cat: 'default:helper'),
            _exp(999, by: PaidBy.client), // not the owner's cost
          ],
        ),
      );
      final rows = await list();
      expect(rows.map((r) => r.trip.fare.minor ~/ 100), [4500, 1000]);
      expect(rows.first.ownerExpenses, const Money.taka(1400));
      expect(rows.first.profit, const Money.taka(2200));
      expect(rows.first.vehicleNickname, 'Rahim CNG');
      expect(rows.first.driverName, 'Karim');
      expect(rows.last.profit, const Money.taka(900));
    });

    test('filters by vehicle, dates and payment status', () async {
      final other = await f.vehicle(
        name: 'Other',
        model: BusinessModel.contract,
      );
      await f.trips.create(
        draft(when: at(3, 1), fare: 100, received: 100),
      ); // paid
      await f.trips.create(
        draft(when: at(3, 5), fare: 200, received: 50),
      ); // partial
      await f.trips.create(
        draft(when: at(3, 9), fare: 300, received: 0, vehicle: other),
      ); // unpaid

      int count(TripFilter x, [List<TripSummary>? l]) => (l ?? []).length;
      expect(count(const TripFilter(), await list()), 3);
      expect(
        (await list(TripFilter(vehicleId: other)))
            .map((r) => r.trip.fare.minor ~/ 100),
        [300],
      );
      expect(
        (await list(const TripFilter(status: PaymentStatus.paid)))
            .single
            .trip
            .fare,
        const Money.taka(100),
      );
      expect(
        (await list(const TripFilter(status: PaymentStatus.partial)))
            .single
            .trip
            .fare,
        const Money.taka(200),
      );
      expect(
        (await list(const TripFilter(status: PaymentStatus.unpaid)))
            .single
            .trip
            .fare,
        const Money.taka(300),
      );
      final range = DayRange(
        CalendarDay.of(2026, 3, 2),
        CalendarDay.of(2026, 3, 9),
      );
      expect(
        (await list(TripFilter(range: range)))
            .map((r) => r.trip.fare.minor ~/ 100),
        [300, 200],
      );
      expect(
        await list(TripFilter(vehicleId: other, status: PaymentStatus.paid)),
        isEmpty,
      );
    });

    test('limit caps the page', () async {
      for (var i = 0; i < 5; i++) {
        await f.trips.create(draft(when: at(3, 1 + i)));
      }
      expect(await list(const TripFilter(limit: 2)), hasLength(2));
    });

    test('updates when a trip is added', () async {
      final seen = <int>[];
      final sub = f.trips
          .watch(const TripFilter())
          .listen((l) => seen.add(l.length));
      await Future<void>.delayed(const Duration(milliseconds: 10));
      await f.trips.create(draft());
      await Future<void>.delayed(const Duration(milliseconds: 30));
      await sub.cancel();
      expect(seen.last, 1);
    });
  });

  group('place suggestions', () {
    setUp(() async {
      await f.trips.create(draft(from: 'Dhaka', to: 'Chattogram'));
      await f.trips.create(draft(from: 'Dhaka', to: 'Sylhet'));
      await f.trips.create(draft(from: 'dhaka', to: 'Chattogram'));
      await f.trips.create(draft(from: 'Savar', to: 'Dhaka'));
    });

    test('most used first, ignoring case, from both ends of a route', () async {
      expect(await f.trips.suggestPlaces(''), [
        'Dhaka',
        'Chattogram',
        'Savar',
        'Sylhet',
      ]);
    });

    test('filters by prefix', () async {
      expect(await f.trips.suggestPlaces('s'), ['Savar', 'Sylhet']);
      expect(await f.trips.suggestPlaces('DH'), ['Dhaka']);
      expect(await f.trips.suggestPlaces('x'), isEmpty);
    });

    test('wildcards are literal and deleted trips are ignored', () async {
      expect(await f.trips.suggestPlaces('%'), isEmpty);
      final id = await f.trips.create(draft(from: 'Rangpur'));
      await f.trips.delete(id);
      expect(await f.trips.suggestPlaces('ran'), isEmpty);
    });
  });

  test('lastTripVehicleId follows the most recent trip', () async {
    expect(await f.trips.lastTripVehicleId(), isNull);
    final other = await f.vehicle(name: 'Other', model: BusinessModel.contract);
    await f.trips.create(draft());
    await Future<void>.delayed(const Duration(milliseconds: 3));
    await f.trips.create(draft(vehicle: other));
    expect(await f.trips.lastTripVehicleId(), other);
  });

  group('totals for a driver', () {
    test('counts only that driver, vehicle, period and live trips', () async {
      final other = await f.vehicle(
        name: 'Other',
        model: BusinessModel.contract,
      );
      final karim2 = await f.driver(name: 'Other driver');
      await f.trips.create(
        draft(when: at(3, 5), fare: 1000, pay: 100, expenses: [_exp(200)]),
      );
      await f.trips.create(
        draft(
          when: at(3, 20),
          fare: 2000,
          pay: 300,
          expenses: [_exp(100, by: PaidBy.client)],
        ),
      );
      await f.trips.create(
        draft(when: at(4, 2), fare: 9999, pay: 999),
      ); // outside
      await f.trips.create(
        draft(when: at(3, 6), fare: 9999, pay: 999, vehicle: other),
      ); // other vehicle
      await f.trips.create(
        draft(when: at(3, 7), fare: 9999, pay: 999, driver: karim2),
      ); // other driver
      final gone = await f.trips.create(
        draft(when: at(3, 8), fare: 9999, pay: 999),
      );
      await f.trips.delete(gone);

      final t = await f.trips.totalsForDriver(
        driverId: driverId,
        vehicleId: vehicleId,
        range: DayRange.month(2026, 3),
      );
      expect(t.count, 2);
      expect(t.fare, const Money.taka(3000));
      expect(t.driverPay, const Money.taka(400));
      expect(t.ownerExpenses, const Money.taka(200));
    });

    test('empty period', () async {
      final t = await f.trips.totalsForDriver(
        driverId: driverId,
        vehicleId: vehicleId,
        range: DayRange.month(2026, 3),
      );
      expect(t.count, 0);
      expect(t.fare, Money.zero);
    });
  });

  group('audit log', () {
    test('records create, update, payment and delete with diffs', () async {
      final id = await f.trips.create(
        draft(fare: 1000, received: 0, expenses: [_exp(100)]),
      );
      await f.trips.update(
        id,
        draft(
          fare: 1200,
          received: 0,
          expenses: [
            ExpenseDraft.fromExpense((await f.trips.get(id))!.expenses.single),
          ],
        ),
      );
      await f.trips.recordPayment(id, const Money.taka(500));
      await f.trips.delete(id);

      final trip = await f.audit('trip', id);
      expect(trip.map((r) => r.action), [
        'create',
        'update',
        'payment',
        'delete',
      ]);
      final diff = jsonDecode(trip[1].diffJson) as Map<String, Object?>;
      expect(diff['fareMinor'], {'from': 100000, 'to': 120000});
      expect(diff.keys, ['fareMinor']);
      expect((await f.audit('expense')).map((r) => r.action), ['create']);
    });

    test('the trip and its audit row commit together', () async {
      final before = (await f.db.select(f.db.auditLogs).get()).length;
      await f.trips.create(draft(expenses: [_exp(100)]));
      // the trip, its expense, and the driver being marked present
      expect((await f.db.select(f.db.auditLogs).get()).length, before + 3);
    });
  });
}

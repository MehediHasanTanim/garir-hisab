import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:vehicle_khata/core/money/money.dart';
import 'package:vehicle_khata/features/expenses/data/expense_repository.dart';
import 'package:vehicle_khata/features/expenses/domain/expense.dart';
import 'package:vehicle_khata/features/trips/domain/trip.dart';

import '../../helpers/fixtures.dart';

Matcher _throwsExpense(ExpenseError e) =>
    throwsA(isA<ExpenseException>().having((x) => x.error, 'error', e));

ExpenseDraft _draft(
  int taka, {
  String cat = 'default:repair',
  DateTime? at,
  int? qty,
  int? odo,
}) => ExpenseDraft(
  categoryId: cat,
  amount: Money.taka(taka),
  spentAt: at,
  qtyMilli: qty,
  odometerM: odo,
);

void main() {
  late Fixture f;
  late String vehicleId;
  setUp(() async {
    f = Fixture();
    await f.categories.ensureDefaults();
    vehicleId = await f.vehicle();
  });
  tearDown(() => f.close());

  Future<List<Expense>> list() => f.expenses.watchForVehicle(vehicleId).first;

  test('creates a vehicle-level expense with every field', () async {
    final id = await f.expenses.create(
      vehicleId,
      ExpenseDraft(
        categoryId: 'default:repair',
        amount: const Money.taka(2500),
        note: ' Brake pads ',
        receiptFile: 'r.jpg',
        spentAt: DateTime.utc(2026, 3, 3),
      ),
    );
    final e = (await f.expenses.get(id))!;
    expect(e.vehicleId, vehicleId);
    expect(e.tripId, isNull);
    expect(e.amount, const Money.taka(2500));
    expect(e.note, 'Brake pads');
    expect(e.receiptFile, 'r.jpg');
    expect(e.spentAt, DateTime.utc(2026, 3, 3));
    expect(e.isOwnerBorne, isTrue);
  });

  test('defaults the date to now', () async {
    final id = await f.expenses.create(vehicleId, _draft(100));
    expect((await f.expenses.get(id))!.spentAt, DateTime.utc(2026, 4, 1, 9));
  });

  test(
    'lists newest first and only vehicle-level expenses of that vehicle',
    () async {
      final other = await f.vehicle(name: 'Other');
      await f.expenses.create(
        vehicleId,
        _draft(100, at: DateTime.utc(2026, 3)),
      );
      await f.expenses.create(
        vehicleId,
        _draft(200, at: DateTime.utc(2026, 3, 5)),
      );
      await f.expenses.create(other, _draft(999));
      // An expense that belongs to a trip is not vehicle-level.
      await f.trips.create(
        TripDraft(
          vehicleId: vehicleId,
          startedAt: DateTime.utc(2026, 3, 2),
          fare: const Money.taka(100),
          received: const Money.taka(100),
          driverPay: Money.zero,
          expenses: [_draft(777)],
        ),
      );
      expect((await list()).map((e) => e.amount.minor ~/ 100), [200, 100]);
    },
  );

  group('validation', () {
    test('amount, quantity and odometer', () async {
      await expectLater(
        f.expenses.create(vehicleId, _draft(0)),
        _throwsExpense(ExpenseError.amountInvalid),
      );
      await expectLater(
        f.expenses.create(vehicleId, _draft(1, qty: 0)),
        _throwsExpense(ExpenseError.quantityInvalid),
      );
      await expectLater(
        f.expenses.create(vehicleId, _draft(1, odo: -1)),
        _throwsExpense(ExpenseError.odometerInvalid),
      );
    });

    test('vehicle and category must exist', () async {
      await expectLater(
        f.expenses.create('nope', _draft(1)),
        _throwsExpense(ExpenseError.vehicleNotFound),
      );
      await expectLater(
        f.expenses.create(vehicleId, _draft(1, cat: 'nope')),
        _throwsExpense(ExpenseError.categoryNotFound),
      );
    });
  });

  test('update and delete', () async {
    final id = await f.expenses.create(
      vehicleId,
      _draft(100, at: DateTime.utc(2026, 3)),
    );
    await f.expenses.update(id, _draft(150, cat: 'default:tyre'));
    final e = (await f.expenses.get(id))!;
    expect(e.amount, const Money.taka(150));
    expect(e.categoryId, 'default:tyre');
    expect(
      e.spentAt,
      DateTime.utc(2026, 3),
      reason: 'date is kept when not given',
    );

    await f.expenses.delete(id);
    expect(await f.expenses.get(id), isNull);
    expect(await list(), isEmpty);
    await expectLater(
      f.expenses.delete(id),
      _throwsExpense(ExpenseError.expenseNotFound),
    );
    await expectLater(
      f.expenses.update(id, _draft(1)),
      _throwsExpense(ExpenseError.expenseNotFound),
    );
  });

  test('trip expenses cannot be edited from here', () async {
    final tripId = await f.trips.create(
      TripDraft(
        vehicleId: vehicleId,
        startedAt: DateTime.utc(2026, 3, 2),
        fare: const Money.taka(100),
        received: const Money.taka(100),
        driverPay: Money.zero,
        expenses: [_draft(50)],
      ),
    );
    final e = (await f.trips.get(tripId))!.expenses.single;
    await expectLater(
      f.expenses.delete(e.id),
      _throwsExpense(ExpenseError.belongsToTrip),
    );
    await expectLater(
      f.expenses.update(e.id, _draft(1)),
      _throwsExpense(ExpenseError.belongsToTrip),
    );
  });

  test('changes are audited, with only the changed fields', () async {
    final id = await f.expenses.create(vehicleId, _draft(100));
    await f.expenses.update(id, _draft(120));
    await f.expenses.delete(id);
    final rows = await f.audit('expense', id);
    expect(rows.map((r) => r.action), ['create', 'update', 'delete']);
    expect(jsonDecode(rows[1].diffJson), {
      'amountMinor': {'from': 10000, 'to': 12000},
    });
  });

  group('fuel fills', () {
    test(
      'only fuel expenses with both quantity and odometer, from trips or not',
      () async {
        await f.expenses.create(
          vehicleId,
          _draft(
            3000,
            cat: 'default:fuel',
            at: DateTime.utc(2026, 3),
            qty: 30000,
            odo: 100000000,
          ),
        );
        await f.expenses.create(
          vehicleId,
          _draft(500, cat: 'default:fuel', at: DateTime.utc(2026, 3, 2)),
        ); // no qty/odo
        await f.expenses.create(
          vehicleId,
          _draft(900, qty: 1000, odo: 1),
        ); // not fuel
        await f.trips.create(
          TripDraft(
            vehicleId: vehicleId,
            startedAt: DateTime.utc(2026, 3, 10),
            fare: const Money.taka(100),
            received: const Money.taka(100),
            driverPay: Money.zero,
            expenses: [
              _draft(2500, cat: 'default:fuel', qty: 25000, odo: 100300000),
            ],
          ),
        );
        final fills = await f.expenses.fuelFills(vehicleId);
        expect(fills.map((x) => x.odometerM), [100000000, 100300000]);
        expect(fills.last.cost, const Money.taka(2500));
      },
    );
  });
}

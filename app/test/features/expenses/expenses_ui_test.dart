import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vehicle_khata/app/providers/feature_providers.dart';
import 'package:vehicle_khata/app/router/app_router.dart';
import 'package:vehicle_khata/core/db/app_database.dart';
import 'package:vehicle_khata/core/money/money.dart';
import 'package:vehicle_khata/features/expenses/domain/expense.dart';
import 'package:vehicle_khata/features/vehicles/domain/vehicle_enums.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/pump_app.dart';

DateTime _clock() => DateTime(2026, 3, 15, 10);

Future<void> _tap(WidgetTester tester, String text) async {
  await tester.tap(find.text(text));
  await tester.pumpAndSettle();
}

Future<void> _keypad(WidgetTester tester, String digits) async {
  for (final d in digits.split('')) {
    await tester.tap(find.widgetWithText(FilledButton, d).first);
    await tester.pump();
  }
  await tester.tap(find.widgetWithText(FilledButton, 'Done'));
  await tester.pumpAndSettle();
}

void main() {
  late TestApp app;
  late String vehicleId;

  Future<void> open(WidgetTester tester, String location) async {
    app = await pumpApp(tester, location: '/more', clock: _clock);
    vehicleId = await app.container
        .read(vehicleRepositoryProvider)
        .create(vehicleFor(BusinessModel.self, name: 'Rahim CNG'));
    await app.container.read(categoryRepositoryProvider).ensureDefaults();
    app.container.read(routerProvider).go(location.replaceAll(':v', vehicleId));
    await tester.pumpAndSettle();
  }

  Future<List<ExpenseRow>> expenses() => app.db.select(app.db.expenses).get();

  group('vehicle expenses', () {
    testWidgets('opens from the vehicle menu on Home', (tester) async {
      await open(tester, '/home');
      await tester.tap(find.byIcon(Icons.more_vert).first);
      await tester.pumpAndSettle();
      await _tap(tester, 'Vehicle expenses');
      expect(find.text('No expenses yet'), findsOneWidget);
    });

    testWidgets('adds, edits and deletes an expense', (tester) async {
      await open(tester, '/vehicles/:v/expenses');
      expect(find.text('No expenses yet'), findsOneWidget);

      await _tap(tester, 'Add expense');
      expect(
        find.text('Repair'),
        findsWidgets,
        reason: 'repair is the default',
      );
      await _tap(tester, 'Tap to enter');
      await _keypad(tester, '2500');
      await tester.enterText(
        find.widgetWithText(TextField, 'Note (optional)'),
        'Brake pads',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Save').last);
      await tester.pumpAndSettle();

      expect(find.text('Expense saved'), findsOneWidget);
      expect(find.text('৳ 2,500'), findsOneWidget);
      expect(find.text('15/03/2026 · Brake pads'), findsOneWidget);
      final saved = (await expenses()).single;
      expect(saved.tripId, isNull);
      expect(saved.categoryId, 'default:repair');

      await _tap(tester, 'Repair');
      expect(find.text('Edit expense'), findsOneWidget);
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Spare parts').last);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Save').last);
      await tester.pumpAndSettle();
      expect(find.text('Spare parts'), findsOneWidget);
      expect((await expenses()).single.categoryId, 'default:parts');

      await _tap(tester, 'Spare parts');
      await _tap(tester, 'Delete');
      expect(find.text('Expense deleted'), findsOneWidget);
      expect(find.text('No expenses yet'), findsOneWidget);
    });

    testWidgets('an amount is required', (tester) async {
      await open(tester, '/vehicles/:v/expenses');
      await _tap(tester, 'Add expense');
      await tester.tap(find.widgetWithText(FilledButton, 'Save').last);
      await tester.pumpAndSettle();
      expect(find.text('Enter an amount greater than zero'), findsOneWidget);
      expect(await expenses(), isEmpty);
    });

    testWidgets("lists newest first and only this vehicle's own expenses", (
      tester,
    ) async {
      await open(tester, '/more');
      final other = await app.container
          .read(vehicleRepositoryProvider)
          .create(vehicleFor(BusinessModel.self, name: 'Other'));
      final repo = app.container.read(expenseRepositoryProvider);
      await repo.create(
        vehicleId,
        ExpenseDraft(
          categoryId: 'default:tyre',
          amount: const Money.taka(100),
          spentAt: DateTime.utc(2026, 3),
        ),
      );
      await repo.create(
        vehicleId,
        ExpenseDraft(
          categoryId: 'default:washing',
          amount: const Money.taka(200),
          spentAt: DateTime.utc(2026, 3, 5),
        ),
      );
      await repo.create(
        other,
        const ExpenseDraft(categoryId: 'default:loan', amount: Money.taka(999)),
      );
      app.container.read(routerProvider).go('/vehicles/$vehicleId/expenses');
      await tester.pumpAndSettle();
      final washing = tester.getTopLeft(find.text('Washing')).dy;
      final tyre = tester.getTopLeft(find.text('Tyre')).dy;
      expect(washing, lessThan(tyre));
      expect(find.text('Loan installment'), findsNothing);
    });

    testWidgets(
      'shows fuel efficiency from fuel entries with quantity and odometer',
      (tester) async {
        await open(tester, '/more');
        final repo = app.container.read(expenseRepositoryProvider);
        Future<void> fill(int day, int taka, int qtyMilli, int odoKm) =>
            repo.create(
              vehicleId,
              ExpenseDraft(
                categoryId: 'default:fuel',
                amount: Money.taka(taka),
                qtyMilli: qtyMilli,
                odometerM: odoKm * 1000,
                spentAt: DateTime.utc(2026, 3, day),
              ),
            );
        app.container.read(routerProvider).go('/vehicles/$vehicleId/expenses');
        await tester.pumpAndSettle();
        expect(
          find.text(
            'Add two fuel entries with quantity and odometer to see efficiency.',
          ),
          findsOneWidget,
        );

        await fill(1, 3000, 30000, 1000);
        await fill(5, 2500, 25000, 1300);
        await tester.pumpAndSettle();
        expect(find.textContaining('12.0 km per litre / m³'), findsOneWidget);
        expect(find.textContaining('৳ 8.33 per km'), findsOneWidget);
      },
    );
  });

  group('categories page', () {
    testWidgets('lists the built-in categories from More', (tester) async {
      await open(tester, '/more');
      await _tap(tester, 'Expense categories');
      expect(find.text('Expense categories'), findsWidgets);
      expect(find.text('Fuel / CNG gas'), findsOneWidget);
      expect(find.text('Toll'), findsOneWidget);
      expect(find.byType(SwitchListTile), findsWidgets);
    });

    testWidgets(
      'archiving hides a category from new expenses but keeps old labels',
      (tester) async {
        await open(tester, '/more');
        final repo = app.container.read(expenseRepositoryProvider);
        await repo.create(
          vehicleId,
          const ExpenseDraft(
            categoryId: 'default:toll',
            amount: Money.taka(100),
          ),
        );

        app.container.read(routerProvider).go('/more/categories');
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(SwitchListTile, 'Toll'));
        await tester.pumpAndSettle();
        expect(find.text('Archived'), findsOneWidget);
        expect(
          (await app.container
                  .read(categoryRepositoryProvider)
                  .get('default:toll'))!
              .archived,
          isTrue,
        );

        // New trips no longer offer a Toll chip...
        app.container.read(routerProvider).go('/trips/new');
        await tester.pumpAndSettle();
        expect(find.widgetWithText(ActionChip, 'Toll'), findsNothing);
        expect(
          find.widgetWithText(ActionChip, 'Fuel / CNG gas'),
          findsOneWidget,
        );

        // ...but the old expense still shows its name.
        app.container.read(routerProvider).go('/vehicles/$vehicleId/expenses');
        await tester.pumpAndSettle();
        expect(find.text('Toll'), findsOneWidget);
      },
    );

    testWidgets('add, rename and reject duplicate custom categories', (
      tester,
    ) async {
      await open(tester, '/more/categories');
      await _tap(tester, 'Add category');
      await tester.enterText(
        find.widgetWithText(TextField, 'Category name'),
        'Car wash',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Car wash'), 200);
      expect(find.text('Car wash'), findsOneWidget);

      await _tap(tester, 'Add category');
      await tester.enterText(
        find.widgetWithText(TextField, 'Category name'),
        'car WASH',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();
      expect(
        find.text('A category with this name already exists'),
        findsOneWidget,
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Category name'),
        '',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();
      expect(find.text('Enter a name'), findsOneWidget);
      await _tap(tester, 'Cancel');

      await tester.tap(find.byTooltip('Rename'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, 'Category name'),
        'Washing bay',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();
      expect(find.text('Washing bay'), findsOneWidget);
      expect(find.text('Car wash'), findsNothing);
    });
  });
}

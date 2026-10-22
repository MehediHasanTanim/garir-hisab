import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vehicle_khata/app/ui/app_theme.dart';
import 'package:vehicle_khata/app/ui/widgets/amount_keypad.dart';
import 'package:vehicle_khata/app/ui/widgets/big_button.dart';
import 'package:vehicle_khata/app/ui/widgets/khata_list_tile.dart';
import 'package:vehicle_khata/app/ui/widgets/quick_chips.dart';
import 'package:vehicle_khata/core/money/money.dart';
import 'package:vehicle_khata/core/money/number_formatter.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: AppTheme.light(),
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

void main() {
  const latin = NumberFormatter(numerals: NumeralStyle.latin);

  group('AmountKeypad', () {
    Future<List<Money>> pump(WidgetTester tester) async {
      final changes = <Money>[];
      await tester.pumpWidget(
        _wrap(
          AmountKeypad(
            formatter: latin,
            doneLabel: 'Done',
            deleteLabel: 'Delete',
            onChanged: changes.add,
            onDone: changes.add,
          ),
        ),
      );
      return changes;
    }

    testWidgets('types digits, 00, backspace and reports whole taka', (
      tester,
    ) async {
      final changes = await pump(tester);
      await tester.tap(find.text('2'));
      await tester.tap(find.text('8'));
      await tester.tap(find.text('00'));
      await tester.pump();
      expect(changes.last, const Money.taka(2800));
      expect(find.text('৳ 2,800'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.backspace_outlined));
      expect(changes.last, const Money.taka(280));

      await tester.tap(find.text('Done'));
      expect(changes.last, const Money.taka(280));
    });

    testWidgets('ignores leading zeros and caps at 9 digits', (tester) async {
      final changes = await pump(tester);
      await tester.tap(find.text('0'));
      await tester.tap(find.text('00'));
      expect(changes.last, Money.zero);
      for (var i = 0; i < 12; i++) {
        await tester.tap(find.text('9'));
      }
      expect(changes.last, const Money.taka(999999999));
    });

    testWidgets('keys meet the 48dp minimum touch target', (tester) async {
      await pump(tester);
      for (final key in ['1', '5', '9', '0', '00']) {
        final size = tester.getSize(
          find
              .ancestor(of: find.text(key), matching: find.byType(FilledButton))
              .first,
        );
        expect(size.height, greaterThanOrEqualTo(48), reason: key);
      }
    });

    testWidgets('shows Bangla digits when configured', (tester) async {
      await tester.pumpWidget(
        _wrap(
          AmountKeypad(
            formatter: const NumberFormatter(),
            doneLabel: 'ঠিক আছে',
            deleteLabel: 'মুছুন',
            onChanged: (_) {},
          ),
        ),
      );
      expect(find.text('৫'), findsOneWidget);
      await tester.tap(find.text('৫'));
      await tester.pump();
      expect(find.text('৳ ৫'), findsOneWidget);
    });
  });

  testWidgets('BigButton is at least 56dp tall and fires onPressed', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      _wrap(BigButton(label: 'Add', onPressed: () => taps++)),
    );
    expect(tester.getSize(find.byType(FilledButton)).height, 56);
    await tester.tap(find.text('Add'));
    expect(taps, 1);
  });

  testWidgets('QuickChips reports the tapped value', (tester) async {
    String? picked;
    await tester.pumpWidget(
      _wrap(
        QuickChips<String>(
          onSelected: (v) => picked = v,
          chips: const [
            QuickChipData(value: 'fuel', label: 'Fuel', icon: Icons.add),
            QuickChipData(value: 'toll', label: 'Toll', icon: Icons.add),
          ],
        ),
      ),
    );
    await tester.tap(find.text('Toll'));
    expect(picked, 'toll');
  });

  testWidgets('AmountText colours income green and expense red', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const Column(
          children: [
            AmountText(amount: Money.taka(5), formatter: latin),
            AmountText(amount: Money.taka(-5), formatter: latin),
          ],
        ),
      ),
    );
    Color? colorOf(String text) =>
        tester.widget<Text>(find.text(text)).style?.color;
    expect(colorOf('৳ 5'), const Color(0xFF1B7F4B));
    expect(colorOf('-৳ 5'), const Color(0xFFB3261E));
  });
}

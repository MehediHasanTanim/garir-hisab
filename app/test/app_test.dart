import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vehicle_khata/app/providers/providers.dart';
import 'package:vehicle_khata/app/router/app_router.dart';

import 'helpers/pump_app.dart';

void main() {
  testWidgets('boots to the empty Home shell in Bangla by default', (
    tester,
  ) async {
    await pumpApp(tester);
    expect(find.text('এখনো কোনো গাড়ি নেই'), findsOneWidget);
    expect(find.text('হোম'), findsWidgets);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('boots in English when saved', (tester) async {
    await pumpApp(tester, prefs: {'settings.language': 'en'});
    expect(find.text('No vehicles yet'), findsOneWidget);
    expect(find.text('Reports'), findsOneWidget);
  });

  testWidgets('bottom navigation switches between the four tabs', (
    tester,
  ) async {
    await pumpApp(tester, prefs: {'settings.language': 'en'});
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Entries'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('No entries yet'), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Reports'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('No reports yet'), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('More'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('deep link opens a nested route', (tester) async {
    await pumpApp(
      tester,
      prefs: {'settings.language': 'en'},
      location: Routes.settings,
    );
    expect(find.text('Profit view'), findsOneWidget);
  });

  testWidgets('switching language in settings updates UI and persists', (
    tester,
  ) async {
    final container = await pumpApp(
      tester,
      prefs: {'settings.language': 'en'},
      location: Routes.settings,
    );
    await tester.tap(find.text('বাংলা'));
    await tester.pumpAndSettle();

    expect(find.text('সেটিংস'), findsOneWidget);
    expect(container.read(settingsProvider).languageCode, 'bn');
    expect(
      container.read(sharedPreferencesProvider).getString('settings.language'),
      'bn',
    );
  });

  testWidgets('200% text scale does not overflow any screen', (tester) async {
    for (final route in [
      Routes.home,
      Routes.entries,
      Routes.reports,
      Routes.more,
      Routes.settings,
      Routes.gallery,
    ]) {
      await pumpApp(tester, location: route, textScale: 2);
      expect(tester.takeException(), isNull, reason: route);
    }
  });
}

@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vehicle_khata/app/router/app_router.dart';

import '../helpers/pump_app.dart';

/// Golden images of the UI gallery in both languages. Excluded from the
/// default run because glyph rendering differs across OSes; regenerate and
/// verify locally with:
///   flutter test --tags golden [--update-goldens]
void main() {
  for (final lang in ['bn', 'en']) {
    testWidgets('gallery ($lang)', (tester) async {
      await pumpApp(
        tester,
        prefs: {'settings.language': lang},
        location: Routes.gallery,
      );
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/gallery_$lang.png'),
      );
    });
  }

  testWidgets('home shell (bn)', (tester) async {
    await pumpApp(tester);
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/home_bn.png'),
    );
  });
}

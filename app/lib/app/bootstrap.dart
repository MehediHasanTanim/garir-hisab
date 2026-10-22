import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vehicle_khata/app/app.dart';
import 'package:vehicle_khata/app/flavor.dart';
import 'package:vehicle_khata/app/providers/providers.dart';

/// Shared entrypoint body for all flavors. Sentry is enabled only when a
/// DSN is supplied (`--dart-define=SENTRY_DSN=...`).
Future<void> bootstrap(AppConfig config) async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final app = ProviderScope(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    child: KhataApp(config: config),
  );

  if (config.sentryDsn.isEmpty) {
    runApp(app);
    return;
  }
  await SentryFlutter.init((options) {
    options
      ..dsn = config.sentryDsn
      ..environment = config.name;
  }, appRunner: () => runApp(app));
}

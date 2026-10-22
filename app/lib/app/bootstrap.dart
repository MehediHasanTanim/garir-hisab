import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'app.dart';
import 'flavor.dart';

/// Shared entrypoint body for all flavors. Sentry is enabled only when a
/// DSN is supplied (`--dart-define=SENTRY_DSN=...`).
Future<void> bootstrap(AppConfig config) async {
  WidgetsFlutterBinding.ensureInitialized();
  final app = ProviderScope(child: KhataApp(config: config));

  if (config.sentryDsn.isEmpty) {
    runApp(app);
    return;
  }
  await SentryFlutter.init((options) {
    options.dsn = config.sentryDsn;
    options.environment = config.name;
  }, appRunner: () => runApp(app));
}

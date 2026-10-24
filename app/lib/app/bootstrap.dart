import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;
import 'package:vehicle_khata/app/app.dart';
import 'package:vehicle_khata/app/flavor.dart';
import 'package:vehicle_khata/app/providers/feature_providers.dart';
import 'package:vehicle_khata/app/providers/providers.dart';
import 'package:vehicle_khata/core/sync/supabase_sync_server.dart';
import 'package:vehicle_khata/features/auth/data/supabase_auth_repository.dart';

/// Shared entrypoint body for all flavors. Sentry is enabled only when a
/// DSN is supplied (`--dart-define=SENTRY_DSN=...`).
Future<void> bootstrap(AppConfig config) async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  // Null (local-only mode) when SUPABASE_URL / SUPABASE_ANON_KEY are absent.
  final auth = await SupabaseAuthRepository.initialize(
    BackendConfig.fromEnvironment,
  );
  final app = ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      flavorProvider.overrideWithValue(config.flavor),
      if (auth != null) ...[
        authRepositoryProvider.overrideWithValue(auth),
        syncServerProvider.overrideWithValue(
          SupabaseSyncServer(Supabase.instance.client),
        ),
      ],
    ],
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

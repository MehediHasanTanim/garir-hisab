import 'app/bootstrap.dart';
import 'app/flavor.dart';

Future<void> main() => bootstrap(
  const AppConfig(
    flavor: Flavor.staging,
    sentryDsn: String.fromEnvironment('SENTRY_DSN'),
  ),
);

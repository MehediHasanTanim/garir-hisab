import 'app/bootstrap.dart';
import 'app/flavor.dart';

Future<void> main() => bootstrap(
  const AppConfig(
    flavor: Flavor.dev,
    sentryDsn: String.fromEnvironment('SENTRY_DSN'),
  ),
);

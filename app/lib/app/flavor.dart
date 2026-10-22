enum Flavor { dev, staging, prod }

class AppConfig {
  const AppConfig({required this.flavor, this.sentryDsn = ''});

  final Flavor flavor;
  final String sentryDsn;

  String get name => flavor.name;
}

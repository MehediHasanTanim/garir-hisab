import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vehicle_khata/app/flavor.dart';
import 'package:vehicle_khata/app/providers/providers.dart';
import 'package:vehicle_khata/app/router/app_router.dart';
import 'package:vehicle_khata/app/ui/app_theme.dart';
import 'package:vehicle_khata/l10n/gen/app_localizations.dart';

class KhataApp extends ConsumerStatefulWidget {
  const new({required this.config, this.router, super.key});

  final AppConfig config;

  /// Override for tests (e.g. to start on a deep link).
  final GoRouter? router;

  @override
  ConsumerState<KhataApp> createState() => _KhataAppState();
}

class _KhataAppState extends ConsumerState<KhataApp> {
  late final GoRouter _router = widget.router ?? createRouter();

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      debugShowCheckedModeBanner: widget.config.flavor != Flavor.prod,
      theme: AppTheme.light(),
      locale: Locale(settings.languageCode),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: _router,
      builder: (context, child) =>
          MediaQuery.withClampedTextScaling(maxScaleFactor: 2, child: child!),
    );
  }
}

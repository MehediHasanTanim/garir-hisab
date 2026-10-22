import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vehicle_khata/app/shell/app_shell.dart';
import 'package:vehicle_khata/features/entries/presentation/entries_page.dart';
import 'package:vehicle_khata/features/gallery/presentation/gallery_page.dart';
import 'package:vehicle_khata/features/home/presentation/home_page.dart';
import 'package:vehicle_khata/features/more/presentation/more_page.dart';
import 'package:vehicle_khata/features/reports/presentation/reports_page.dart';
import 'package:vehicle_khata/features/settings/presentation/settings_page.dart';

/// Route paths. Deep links (e.g. from notifications) use these directly.
abstract final class Routes {
  static const home = '/home';
  static const entries = '/entries';
  static const reports = '/reports';
  static const more = '/more';
  static const settings = '/more/settings';
  static const gallery = '/more/gallery';
}

GoRouter createRouter({
  String initialLocation = Routes.home,
  GlobalKey<NavigatorState>? navigatorKey,
}) {
  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: initialLocation,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: Routes.home, builder: (_, _) => const HomePage()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.entries,
                builder: (_, _) => const EntriesPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.reports,
                builder: (_, _) => const ReportsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.more,
                builder: (_, _) => const MorePage(),
                routes: [
                  GoRoute(
                    path: 'settings',
                    builder: (_, _) => const SettingsPage(),
                  ),
                  GoRoute(
                    path: 'gallery',
                    builder: (_, _) => const GalleryPage(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

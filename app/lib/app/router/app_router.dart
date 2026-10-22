import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vehicle_khata/app/providers/feature_providers.dart';
import 'package:vehicle_khata/app/shell/app_shell.dart';
import 'package:vehicle_khata/features/app_lock/presentation/app_lock_controller.dart';
import 'package:vehicle_khata/features/app_lock/presentation/lock_page.dart';
import 'package:vehicle_khata/features/app_lock/presentation/pin_setup_page.dart';
import 'package:vehicle_khata/features/auth/presentation/account_page.dart';
import 'package:vehicle_khata/features/entries/presentation/entries_page.dart';
import 'package:vehicle_khata/features/gallery/presentation/gallery_page.dart';
import 'package:vehicle_khata/features/home/presentation/home_page.dart';
import 'package:vehicle_khata/features/more/presentation/more_page.dart';
import 'package:vehicle_khata/features/onboarding/presentation/onboarding_page.dart';
import 'package:vehicle_khata/features/reports/presentation/reports_page.dart';
import 'package:vehicle_khata/features/settings/presentation/settings_page.dart';
import 'package:vehicle_khata/features/vehicles/presentation/vehicle_form_page.dart';

/// Route paths. Deep links (e.g. from notifications) use these directly.
abstract final class Routes {
  static const home = '/home';
  static const entries = '/entries';
  static const reports = '/reports';
  static const more = '/more';
  static const settings = '/more/settings';
  static const gallery = '/more/gallery';
  static const account = '/more/account';
  static const onboarding = '/onboarding';
  static const lock = '/lock';
  static const newVehicle = '/vehicles/new';
  static String editVehicle(String id) => '/vehicles/$id/edit';
}

/// Where the router starts. Tests override this to open a deep link.
final initialLocationProvider = Provider<String>((_) => Routes.home);

/// Re-runs the router redirect whenever gate state changes.
class _GateRefresh extends ChangeNotifier {
  void poke() => notifyListeners();
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _GateRefresh();
  ref
    // Only the gate inputs: refreshing on any settings change would rebuild
    // (and reset) the page the user is currently on.
    ..listen(
      onboardingProvider.select((s) => s.isDone),
      (_, _) => refresh.poke(),
    )
    ..listen(appLockProvider.select((s) => s.locked), (_, _) => refresh.poke())
    ..onDispose(refresh.dispose);

  final router = GoRouter(
    initialLocation: ref.read(initialLocationProvider),
    refreshListenable: refresh,
    redirect: (context, state) {
      final path = state.matchedLocation;
      final locked = ref.read(appLockProvider).locked;
      if (locked) return path == Routes.lock ? null : Routes.lock;
      if (path == Routes.lock) return Routes.home;

      final onboarded = ref.read(onboardingProvider).isDone;
      if (!onboarded) {
        return path == Routes.onboarding ? null : Routes.onboarding;
      }
      if (path == Routes.onboarding) return Routes.home;
      return null;
    },
    routes: [
      GoRoute(
        path: Routes.onboarding,
        builder: (_, _) => const OnboardingPage(),
      ),
      GoRoute(path: Routes.lock, builder: (_, _) => const LockPage()),
      GoRoute(
        path: Routes.newVehicle,
        builder: (_, _) => const VehicleFormPage(),
      ),
      GoRoute(
        path: '/vehicles/:id/edit',
        builder: (_, state) =>
            VehicleFormPage(vehicleId: state.pathParameters['id']),
      ),
      GoRoute(
        path: '/pin/:mode',
        builder: (_, state) => PinSetupPage(
          mode: PinSetupMode.values.firstWhere(
            (m) => m.name == state.pathParameters['mode'],
            orElse: () => PinSetupMode.enable,
          ),
        ),
      ),
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
                    path: 'account',
                    builder: (_, _) => const AccountPage(),
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
  ref.onDispose(router.dispose);
  return router;
});

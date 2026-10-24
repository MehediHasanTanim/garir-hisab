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
import 'package:vehicle_khata/features/daylog/presentation/close_day_page.dart';
import 'package:vehicle_khata/features/drivers/presentation/assignment_form_page.dart';
import 'package:vehicle_khata/features/drivers/presentation/driver_detail_page.dart';
import 'package:vehicle_khata/features/drivers/presentation/driver_form_page.dart';
import 'package:vehicle_khata/features/drivers/presentation/drivers_page.dart';
import 'package:vehicle_khata/features/drivers/presentation/payout_page.dart';
import 'package:vehicle_khata/features/drivers/presentation/vehicle_driver_page.dart';
import 'package:vehicle_khata/features/entries/presentation/entries_page.dart';
import 'package:vehicle_khata/features/expenses/presentation/categories_page.dart';
import 'package:vehicle_khata/features/expenses/presentation/vehicle_expenses_page.dart';
import 'package:vehicle_khata/features/export/presentation/export_page.dart';
import 'package:vehicle_khata/features/gallery/presentation/gallery_page.dart';
import 'package:vehicle_khata/features/home/presentation/home_page.dart';
import 'package:vehicle_khata/features/jama/presentation/jama_page.dart';
import 'package:vehicle_khata/features/jama/presentation/jama_report_page.dart';
import 'package:vehicle_khata/features/ledger/domain/ledger_logic.dart';
import 'package:vehicle_khata/features/ledger/presentation/dues_page.dart';
import 'package:vehicle_khata/features/more/presentation/more_page.dart';
import 'package:vehicle_khata/features/onboarding/presentation/onboarding_page.dart';
import 'package:vehicle_khata/features/reports/presentation/reports_page.dart';
import 'package:vehicle_khata/features/settings/presentation/settings_page.dart';
import 'package:vehicle_khata/features/statement/presentation/statement_page.dart';
import 'package:vehicle_khata/features/sync/presentation/sync_page.dart';
import 'package:vehicle_khata/features/trips/presentation/trip_detail_page.dart';
import 'package:vehicle_khata/features/trips/presentation/trip_form_page.dart';
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
  static const categories = '/more/categories';
  static const newTrip = '/trips/new';
  static String trip(String id) => '/trips/$id';
  static String editTrip(String id) => '/trips/$id/edit';
  static String vehicleExpenses(String vehicleId) =>
      '/vehicles/$vehicleId/expenses';
  static const drivers = '/drivers';
  static const newDriver = '/drivers/new';
  static String driver(String id) => '/drivers/$id';
  static String editDriver(String id) => '/drivers/$id/edit';
  static String newPayout(String driverId) => '/drivers/$driverId/payout/new';
  static String vehicleDriver(String vehicleId) =>
      '/vehicles/$vehicleId/driver';
  static String assignDriver(String vehicleId) => '/vehicles/$vehicleId/assign';
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
        path: '/trips/new',
        builder: (_, state) => TripFormPage(
          vehicleId: state.uri.queryParameters['vehicle'],
          repeatFrom: state.uri.queryParameters['repeat'],
          returnOf: state.uri.queryParameters['returnOf'],
        ),
      ),
      GoRoute(
        path: '/trips/:id',
        builder: (_, state) =>
            TripDetailPage(tripId: state.pathParameters['id']!),
        routes: [
          GoRoute(
            path: 'edit',
            builder: (_, state) =>
                TripFormPage(tripId: state.pathParameters['id']),
          ),
        ],
      ),
      GoRoute(
        path: '/vehicles/:id/expenses',
        builder: (_, state) =>
            VehicleExpensesPage(vehicleId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/vehicles/:id/close-day',
        builder: (_, state) =>
            CloseDayPage(vehicleId: state.pathParameters['id']!),
      ),
      GoRoute(path: Routes.drivers, builder: (_, _) => const DriversPage()),
      GoRoute(
        path: Routes.newDriver,
        builder: (_, _) => const DriverFormPage(),
      ),
      GoRoute(
        path: '/drivers/:id',
        builder: (_, state) =>
            DriverDetailPage(driverId: state.pathParameters['id']!),
        routes: [
          GoRoute(
            path: 'edit',
            builder: (_, state) =>
                DriverFormPage(driverId: state.pathParameters['id']),
          ),
          GoRoute(
            path: 'statement',
            builder: (_, state) =>
                StatementPage(driverId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: 'payout/new',
            builder: (_, state) =>
                PayoutPage(driverId: state.pathParameters['id']!),
          ),
        ],
      ),
      GoRoute(
        path: '/vehicles/:id/jama',
        builder: (_, state) => JamaPage(vehicleId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/vehicles/:id/driver',
        builder: (_, state) =>
            VehicleDriverPage(vehicleId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/vehicles/:id/assign',
        builder: (_, state) =>
            AssignmentFormPage(vehicleId: state.pathParameters['id']!),
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
                    path: 'categories',
                    builder: (_, _) => const CategoriesPage(),
                  ),
                  GoRoute(
                    path: 'account',
                    builder: (_, _) => const AccountPage(),
                  ),
                  GoRoute(path: 'sync', builder: (_, _) => const SyncPage()),
                  GoRoute(
                    path: 'dues',
                    builder: (_, _) => const DuesPage(),
                    routes: [
                      GoRoute(
                        path: 'party',
                        builder: (_, state) => PartyPage(
                          party: Party(
                            PartyType.values.byName(
                              state.uri.queryParameters['type']!,
                            ),
                            state.uri.queryParameters['id'] ?? '',
                          ),
                          name: state.uri.queryParameters['name'] ?? '',
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'jama-report',
                    builder: (_, _) => const JamaReportPage(),
                  ),
                  GoRoute(
                    path: 'export',
                    builder: (_, _) => const ExportPage(),
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

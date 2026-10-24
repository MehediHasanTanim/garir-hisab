import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vehicle_khata/app/providers/providers.dart';
import 'package:vehicle_khata/core/db/field_cipher.dart';
import 'package:vehicle_khata/core/money/money.dart';
import 'package:vehicle_khata/core/settings/app_settings.dart';
import 'package:vehicle_khata/core/sync/sync_engine.dart';
import 'package:vehicle_khata/core/sync/sync_server.dart';
import 'package:vehicle_khata/core/sync/sync_store.dart';
import 'package:vehicle_khata/core/time/calendar_day.dart';
import 'package:vehicle_khata/features/app_lock/presentation/app_lock_controller.dart';
import 'package:vehicle_khata/features/auth/data/local_only_auth_repository.dart';
import 'package:vehicle_khata/features/auth/domain/auth_repository.dart';
import 'package:vehicle_khata/features/daylog/data/day_log_repository.dart';
import 'package:vehicle_khata/features/drivers/data/advance_repository.dart';
import 'package:vehicle_khata/features/drivers/data/assignment_repository.dart';
import 'package:vehicle_khata/features/drivers/data/attendance_repository.dart';
import 'package:vehicle_khata/features/drivers/data/driver_repository.dart';
import 'package:vehicle_khata/features/drivers/data/payout_service.dart';
import 'package:vehicle_khata/features/drivers/domain/attendance.dart';
import 'package:vehicle_khata/features/drivers/domain/driver.dart';
import 'package:vehicle_khata/features/expenses/data/category_repository.dart';
import 'package:vehicle_khata/features/expenses/data/expense_repository.dart';
import 'package:vehicle_khata/features/expenses/domain/expense.dart';
import 'package:vehicle_khata/features/onboarding/data/onboarding_repository.dart';
import 'package:vehicle_khata/features/onboarding/domain/onboarding_state.dart';
import 'package:vehicle_khata/features/reports/data/report_service.dart';
import 'package:vehicle_khata/features/reports/domain/profit_engine.dart';
import 'package:vehicle_khata/features/trips/data/trip_repository.dart';
import 'package:vehicle_khata/features/trips/domain/trip.dart';
import 'package:vehicle_khata/features/vehicles/data/photo_store.dart';
import 'package:vehicle_khata/features/vehicles/data/vehicle_repository.dart';
import 'package:vehicle_khata/features/vehicles/domain/vehicle.dart';
import 'package:vehicle_khata/features/vehicles/domain/vehicle_enums.dart';
import 'package:vehicle_khata/features/vehicles/domain/vehicle_rules.dart';

// ---- Auth ----------------------------------------------------------------

/// Overridden at startup with the Supabase implementation when configured.
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => const LocalOnlyAuthRepository(),
);

/// Emits the signed-in user (or null) and follows sign-in/out.
final authUserProvider = StreamProvider<AuthUser?>((ref) async* {
  final auth = ref.watch(authRepositoryProvider);
  yield auth.currentUser;
  yield* auth.authChanges();
});

// ---- Sync ----------------------------------------------------------------

/// The server to sync with; null in local-only builds. Overridden at startup
/// with the Supabase implementation when a backend is configured.
final syncServerProvider = Provider<SyncServer?>((ref) => null);

/// Runs for as long as the app is open. Null when there is no server.
final syncEngineProvider = Provider<SyncEngine?>((ref) {
  final server = ref.watch(syncServerProvider);
  if (server == null) return null;
  final db = ref.watch(appDatabaseProvider);
  final auth = ref.watch(authRepositoryProvider);
  final engine = SyncEngine(
    db: db,
    store: SyncStore(db),
    server: server,
    userId: () => auth.currentUser?.id,
  );
  // Signing in or out changes what may be synced.
  ref
    ..listen(authUserProvider, (_, _) => engine.syncNow())
    ..onDispose(engine.dispose);
  engine.start();
  return engine;
});

final syncStatusProvider = StreamProvider<SyncStatus>((ref) async* {
  final engine = ref.watch(syncEngineProvider);
  if (engine == null) {
    yield const SyncStatus();
    return;
  }
  yield engine.status;
  yield* engine.changes;
});

// ---- Vehicles ------------------------------------------------------------

final vehicleRepositoryProvider = Provider<VehicleRepository>(
  (ref) => VehicleRepository(ref.watch(appDatabaseProvider)),
);

final photoStoreProvider = Provider<PhotoStore>(
  (ref) => PhotoStore.appStorage(),
);

final photoPickerProvider = Provider<PhotoPicker>(
  (ref) => ImagePickerPhotoPicker(),
);

final vehicleListProvider = StreamProvider.autoDispose
    .family<List<Vehicle>, VehicleFilter>(
      (ref, filter) => ref.watch(vehicleRepositoryProvider).watch(filter),
    );

final vehicleProvider = StreamProvider.autoDispose.family<Vehicle?, String>(
  (ref, id) => ref.watch(vehicleRepositoryProvider).watchOne(id),
);

// ---- Trips and expenses --------------------------------------------------

final categoryRepositoryProvider = Provider<CategoryRepository>(
  (ref) => CategoryRepository(ref.watch(appDatabaseProvider)),
);

final tripRepositoryProvider = Provider<TripRepository>(
  (ref) => TripRepository(ref.watch(appDatabaseProvider)),
);

final expenseRepositoryProvider = Provider<ExpenseRepository>(
  (ref) => ExpenseRepository(
    ref.watch(appDatabaseProvider),
    clock: ref.watch(clockProvider),
  ),
);

/// Active categories, in display order.
final categoriesProvider = StreamProvider.autoDispose<List<ExpenseCategory>>(
  (ref) => ref.watch(categoryRepositoryProvider).watch(),
);

/// Every category including archived ones, to label old expenses.
final allCategoriesProvider = StreamProvider.autoDispose<List<ExpenseCategory>>(
  (ref) => ref.watch(categoryRepositoryProvider).watch(includeArchived: true),
);

final tripListProvider = StreamProvider.autoDispose
    .family<List<TripSummary>, TripFilter>(
      (ref, filter) => ref.watch(tripRepositoryProvider).watch(filter),
    );

final tripDetailProvider = StreamProvider.autoDispose
    .family<TripDetail?, String>(
      (ref, id) => ref.watch(tripRepositoryProvider).watchOne(id),
    );

final activeAssignmentProvider = StreamProvider.autoDispose
    .family<AssignmentView?, String>(
      (ref, vehicleId) => ref
          .watch(assignmentRepositoryProvider)
          .watchActiveForVehicle(vehicleId),
    );

final vehicleExpensesProvider = StreamProvider.autoDispose
    .family<List<Expense>, String>(
      (ref, vehicleId) =>
          ref.watch(expenseRepositoryProvider).watchForVehicle(vehicleId),
    );

// ---- Day log and reports -------------------------------------------------

final dayLogRepositoryProvider = Provider<DayLogRepository>(
  (ref) => DayLogRepository(ref.watch(appDatabaseProvider)),
);

final reportServiceProvider = Provider<ReportService>(
  (ref) => ReportService(
    ref.watch(appDatabaseProvider),
    clock: ref.watch(clockProvider),
  ),
);

/// Today's calendar day (changes only when the app is rebuilt after midnight).
final todayProvider = Provider<CalendarDay>(
  (ref) => CalendarDay.today(ref.watch(clockProvider)),
);

/// The vehicle shown on the Today card; null means "the first one".
class TodayVehicleNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  // A plain setter keeps call sites short.
  // ignore: use_setters_to_change_properties
  void select(String? id) => state = id;
}

final todayVehicleProvider = NotifierProvider<TodayVehicleNotifier, String?>(
  TodayVehicleNotifier.new,
);

typedef DashboardArgs = ({
  int startDay,
  int endDay,
  String? vehicleId,
  bool accrual,
  bool amortize,
});

final dashboardProvider = StreamProvider.autoDispose
    .family<Dashboard, DashboardArgs>(
      (ref, a) => ref
          .watch(reportServiceProvider)
          .watchDashboard(
            DayRange(CalendarDay(a.startDay), CalendarDay(a.endDay)),
            ProfitOptions(
              view: a.accrual ? ProfitView.accrual : ProfitView.cash,
              amortizeFixed: a.amortize,
            ),
            vehicleId: a.vehicleId,
          ),
    );

// ---- Drivers -------------------------------------------------------------

final fieldCipherProvider = Provider<FieldCipher>(
  (ref) => AesGcmFieldCipher(ref.watch(secretStoreProvider)),
);

final driverRepositoryProvider = Provider<DriverRepository>(
  (ref) => DriverRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(fieldCipherProvider),
  ),
);

final assignmentRepositoryProvider = Provider<AssignmentRepository>(
  (ref) => AssignmentRepository(ref.watch(appDatabaseProvider)),
);

final attendanceRepositoryProvider = Provider<AttendanceRepository>(
  (ref) => AttendanceRepository(ref.watch(appDatabaseProvider)),
);

final advanceRepositoryProvider = Provider<AdvanceRepository>(
  (ref) => AdvanceRepository(ref.watch(appDatabaseProvider)),
);

final payoutServiceProvider = Provider<PayoutService>(
  (ref) => PayoutService(
    ref.watch(appDatabaseProvider),
    ref.watch(assignmentRepositoryProvider),
    ref.watch(attendanceRepositoryProvider),
    ref.watch(advanceRepositoryProvider),
    trips: ref.watch(tripRepositoryProvider),
    clock: ref.watch(clockProvider),
  ),
);

final driverListProvider = StreamProvider.autoDispose
    .family<List<Driver>, DriverFilter>(
      (ref, filter) => ref.watch(driverRepositoryProvider).watch(filter),
    );

final driverProvider = StreamProvider.autoDispose.family<Driver?, String>(
  (ref, id) => ref.watch(driverRepositoryProvider).watchOne(id),
);

final driverAssignmentsProvider = StreamProvider.autoDispose
    .family<List<AssignmentView>, String>(
      (ref, driverId) =>
          ref.watch(assignmentRepositoryProvider).watchForDriver(driverId),
    );

final vehicleAssignmentsProvider = StreamProvider.autoDispose
    .family<List<AssignmentView>, String>(
      (ref, vehicleId) =>
          ref.watch(assignmentRepositoryProvider).watchForVehicle(vehicleId),
    );

typedef AttendanceMonth = ({String driverId, int year, int month});

final attendanceMonthProvider = StreamProvider.autoDispose
    .family<Map<CalendarDay, AttendanceStatus>, AttendanceMonth>(
      (ref, key) => ref
          .watch(attendanceRepositoryProvider)
          .watchRange(key.driverId, DayRange.month(key.year, key.month)),
    );

final driverAdvancesProvider = StreamProvider.autoDispose
    .family<List<Advance>, String>(
      (ref, driverId) =>
          ref.watch(advanceRepositoryProvider).watchForDriver(driverId),
    );

final driverOutstandingProvider = StreamProvider.autoDispose
    .family<Money, String>(
      (ref, driverId) =>
          ref.watch(advanceRepositoryProvider).watchOutstandingTotal(driverId),
    );

final driverPayoutsProvider = StreamProvider.autoDispose
    .family<List<Payout>, String>(
      (ref, driverId) =>
          ref.watch(payoutServiceProvider).watchForDriver(driverId),
    );

typedef PayoutPreviewArgs = ({
  String driverId,
  String assignmentId,
  int startDay,
  int endDay,
  int adjustmentMinor,
});

final payoutPreviewProvider = FutureProvider.autoDispose
    .family<PayoutPreview, PayoutPreviewArgs>(
      (ref, a) => ref
          .watch(payoutServiceProvider)
          .preview(
            driverId: a.driverId,
            assignmentId: a.assignmentId,
            period: DayRange(CalendarDay(a.startDay), CalendarDay(a.endDay)),
            adjustment: Money(a.adjustmentMinor),
          ),
    );

// ---- Onboarding ----------------------------------------------------------

final onboardingRepositoryProvider = Provider<OnboardingRepository>(
  (ref) => OnboardingRepository(ref.watch(sharedPreferencesProvider)),
);

class OnboardingNotifier extends Notifier<OnboardingState> {
  @override
  OnboardingState build() => ref.watch(onboardingRepositoryProvider).load();

  Future<void> _set(OnboardingState next) async {
    state = next;
    await ref.read(onboardingRepositoryProvider).save(next);
  }

  Future<void> _goTo(OnboardingStep step) => _set(state.copyWith(step: step));

  /// Language chosen (the choice itself lives in settings).
  Future<void> languageDone() => _goTo(OnboardingStep.account);

  /// Account step finished (signed in) or skipped (local-only).
  Future<void> accountDone() => _goTo(OnboardingStep.role);

  Future<void> chooseRole(UserRole role) =>
      _set(state.copyWith(role: role, step: OnboardingStep.vehicle));

  Future<void> saveVehicleBasics({
    required String nickname,
    required VehicleType type,
  }) => _set(
    state.copyWith(
      vehicleNickname: VehicleRules.cleanText(nickname),
      vehicleType: type,
      step: OnboardingStep.model,
    ),
  );

  /// Creates the first vehicle with the chosen model and ends onboarding.
  Future<String> finish(BusinessModel model) async {
    final id = await ref
        .read(vehicleRepositoryProvider)
        .create(
          VehicleDraft(
            nickname: state.vehicleNickname,
            type: state.vehicleType,
            fuelType: state.vehicleType.defaultFuel,
            businessModel: model,
          ),
        );
    await _goTo(OnboardingStep.done);
    return id;
  }

  /// Skip creating a vehicle for now.
  Future<void> skipVehicle() => _goTo(OnboardingStep.done);

  Future<void> back() async {
    final previous = switch (state.step) {
      OnboardingStep.account => OnboardingStep.language,
      OnboardingStep.role => OnboardingStep.account,
      OnboardingStep.vehicle => OnboardingStep.role,
      OnboardingStep.model => OnboardingStep.vehicle,
      _ => null,
    };
    if (previous != null) await _goTo(previous);
  }
}

final onboardingProvider =
    NotifierProvider<OnboardingNotifier, OnboardingState>(
      OnboardingNotifier.new,
    );

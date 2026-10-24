import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vehicle_khata/app/l10n_labels.dart';
import 'package:vehicle_khata/app/providers/feature_providers.dart';
import 'package:vehicle_khata/app/providers/providers.dart';
import 'package:vehicle_khata/app/ui/format.dart';
import 'package:vehicle_khata/app/ui/tokens.dart';
import 'package:vehicle_khata/app/ui/widgets/empty_state.dart';
import 'package:vehicle_khata/app/ui/widgets/khata_list_tile.dart';
import 'package:vehicle_khata/core/time/calendar_day.dart';
import 'package:vehicle_khata/features/app_lock/presentation/app_lock_controller.dart';
import 'package:vehicle_khata/features/drivers/domain/driver.dart';
import 'package:vehicle_khata/features/drivers/presentation/advances_tab.dart';
import 'package:vehicle_khata/features/drivers/presentation/attendance_tab.dart';
import 'package:vehicle_khata/features/drivers/presentation/driver_avatar.dart';
import 'package:vehicle_khata/features/drivers/presentation/payouts_tab.dart';
import 'package:vehicle_khata/l10n/gen/app_localizations.dart';

class DriverDetailPage extends ConsumerWidget {
  const new({required this.driverId, super.key});

  final String driverId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final driver = ref.watch(driverProvider(driverId));

    return driver.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, _) => Scaffold(
        appBar: AppBar(),
        body: EmptyState(icon: Icons.error_outline, title: l10n.errUnknown),
      ),
      data: (d) {
        if (d == null) {
          return Scaffold(
            appBar: AppBar(),
            body: EmptyState(
              icon: Icons.search_off,
              title: l10n.driverNotFound,
            ),
          );
        }
        return DefaultTabController(
          length: 4,
          child: Scaffold(
            appBar: AppBar(
              title: Text(d.name),
              actions: [
                IconButton(
                  tooltip: l10n.editDriver,
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => context.push('/drivers/$driverId/edit'),
                ),
                PopupMenuButton<_MenuAction>(
                  onSelected: (a) => _onMenu(context, ref, d, a),
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: _MenuAction.statement,
                      child: Text(l10n.stmtMenu),
                    ),
                    PopupMenuItem(
                      value: d.isActive
                          ? _MenuAction.markLeft
                          : _MenuAction.reactivate,
                      child: Text(
                        d.isActive ? l10n.markAsLeft : l10n.reactivate,
                      ),
                    ),
                  ],
                ),
              ],
              bottom: TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                tabs: [
                  Tab(text: l10n.tabOverview),
                  Tab(text: l10n.tabAttendance),
                  Tab(text: l10n.tabAdvances),
                  Tab(text: l10n.tabPayouts),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                _OverviewTab(driver: d),
                AttendanceTab(driverId: driverId),
                AdvancesTab(driverId: driverId, canGive: d.isActive),
                PayoutsTab(driverId: driverId),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _onMenu(
    BuildContext context,
    WidgetRef ref,
    Driver driver,
    _MenuAction action,
  ) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final repo = ref.read(driverRepositoryProvider);
    switch (action) {
      case _MenuAction.statement:
        await context.push('/drivers/${driver.id}/statement');
      case _MenuAction.markLeft:
        final ok = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.markLeftTitle(driver.name)),
            content: Text(l10n.markLeftBody),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(l10n.markAsLeft),
              ),
            ],
          ),
        );
        if (ok ?? false) {
          await ref
              .read(assignmentRepositoryProvider)
              .endAllForDriver(
                driver.id,
                CalendarDay.today(ref.read(clockProvider)),
              );
          await repo.setStatus(driver.id, DriverStatus.left);
          messenger
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(l10n.driverMarkedLeft)));
        }
      case _MenuAction.reactivate:
        await repo.setStatus(driver.id, DriverStatus.active);
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(l10n.driverReactivated)));
    }
  }
}

enum _MenuAction { statement, markLeft, reactivate }

class _OverviewTab extends ConsumerWidget {
  const new({required this.driver});

  final Driver driver;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final formatter = ref.watch(numberFormatterProvider);
    final today = CalendarDay.today(ref.watch(clockProvider));
    final assignments = ref.watch(driverAssignmentsProvider(driver.id));
    final owed = ref.watch(driverOutstandingProvider(driver.id)).value;
    final expiry = driver.licenseExpiry;

    String licenseText() {
      if (expiry == null) return '';
      if (expiry.isBefore(today)) return l10n.licenseExpired;
      return l10n.licenseValidUntil(formatDay(formatter, expiry));
    }

    Widget row(IconData icon, String title, String value, {Color? color}) =>
        ListTile(
          leading: Icon(icon),
          title: Text(title),
          subtitle: Text(value, style: TextStyle(color: color)),
        );

    return ListView(
      padding: const EdgeInsets.only(bottom: Spacing.xl),
      children: [
        Padding(
          padding: const EdgeInsets.all(Spacing.gutter),
          child: Row(
            children: [
              DriverAvatar(
                name: driver.name,
                photoFile: driver.photoFile,
                size: 72,
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(driver.name, style: theme.textTheme.titleLarge),
                    Text(
                      l10n.driverStatusName(driver.status),
                      style: TextStyle(
                        color: driver.isActive
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SectionHeader(l10n.workingOn),
        assignments.when(
          loading: () => const SizedBox.shrink(),
          error: (_, _) => Text(l10n.errUnknown),
          data: (list) {
            final active = list.where((v) => v.assignment.isActive).toList();
            if (active.isEmpty) {
              return ListTile(
                leading: const Icon(Icons.directions_car_outlined),
                title: Text(l10n.notAssigned),
              );
            }
            return Column(
              children: [
                for (final v in active)
                  KhataListTile(
                    icon: Icons.directions_car_outlined,
                    title: v.vehicleNickname,
                    subtitle:
                        '${payModelSummary(l10n, formatter, v.assignment.payModel)}\n'
                        '${l10n.sinceDate(formatDay(formatter, v.assignment.start))}',
                    onTap: () => context.push(
                      '/vehicles/${v.assignment.vehicleId}/driver',
                    ),
                  ),
              ],
            );
          },
        ),
        if (owed != null && owed.isPositive) ...[
          SectionHeader(l10n.advancesOwed),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet_outlined),
            title: AmountText(amount: owed, formatter: formatter),
          ),
        ],
        SectionHeader(l10n.contactDetails),
        if (driver.phone != null)
          row(
            Icons.phone_outlined,
            l10n.phoneLabel,
            formatter.digits(driver.phone!),
          ),
        if (driver.licenseNo != null || expiry != null)
          row(
            Icons.badge_outlined,
            l10n.licenseNo,
            [
              if (driver.licenseNo != null) driver.licenseNo!,
              if (expiry != null) licenseText(),
            ].join(' · '),
            color: expiry != null && expiry.isBefore(today)
                ? theme.colorScheme.error
                : null,
          ),
        if (driver.hasNid) row(Icons.lock_outline, l10n.nid, l10n.nidOnFile),
        if (driver.address != null)
          row(Icons.home_outlined, l10n.address, driver.address!),
        if (driver.emergencyContact != null)
          row(
            Icons.contact_phone_outlined,
            l10n.emergencyContact,
            formatter.digits(driver.emergencyContact!),
          ),
        if (driver.joinDate != null)
          row(
            Icons.event_outlined,
            l10n.joinDate,
            formatDay(formatter, driver.joinDate!),
          ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vehicle_khata/app/providers/feature_providers.dart';
import 'package:vehicle_khata/app/providers/providers.dart';
import 'package:vehicle_khata/app/ui/format.dart';
import 'package:vehicle_khata/app/ui/tokens.dart';
import 'package:vehicle_khata/app/ui/widgets/big_button.dart';
import 'package:vehicle_khata/app/ui/widgets/empty_state.dart';
import 'package:vehicle_khata/app/ui/widgets/khata_list_tile.dart';
import 'package:vehicle_khata/core/time/calendar_day.dart';
import 'package:vehicle_khata/features/app_lock/presentation/app_lock_controller.dart';
import 'package:vehicle_khata/features/drivers/domain/driver.dart';
import 'package:vehicle_khata/features/drivers/presentation/driver_avatar.dart';
import 'package:vehicle_khata/features/vehicles/domain/vehicle_enums.dart';
import 'package:vehicle_khata/l10n/gen/app_localizations.dart';

/// Who drives a vehicle, how they are paid, and who drove it before.
class VehicleDriverPage extends ConsumerWidget {
  const new({required this.vehicleId, super.key});

  final String vehicleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final formatter = ref.watch(numberFormatterProvider);
    final vehicle = ref.watch(vehicleProvider(vehicleId)).value;
    final assignments = ref.watch(vehicleAssignmentsProvider(vehicleId));

    if (vehicle == null) {
      return Scaffold(
        appBar: AppBar(),
        body: EmptyState(icon: Icons.search_off, title: l10n.vehicleNotFound),
      );
    }

    final title = '${l10n.driverAndPay} · ${vehicle.nickname}';
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: assignments.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(child: Text(l10n.errUnknown)),
        data: (list) {
          final current = list.where((v) => v.assignment.isActive).firstOrNull;
          final past = list.where((v) => !v.assignment.isActive).toList();
          final selfDriven = vehicle.businessModel == BusinessModel.self;

          return ListView(
            padding: const EdgeInsets.only(bottom: Spacing.xl),
            children: [
              if (selfDriven && current == null)
                SizedBox(
                  height: 320,
                  child: EmptyState(
                    icon: Icons.person_outline,
                    title: l10n.noDriverAssigned,
                    message: l10n.selfDrivenNoDriver,
                  ),
                )
              else if (current == null)
                SizedBox(
                  height: 320,
                  child: EmptyState(
                    icon: Icons.badge_outlined,
                    title: l10n.noDriverAssigned,
                    message: l10n.noDriverAssignedHint,
                    action: BigButton(
                      label: l10n.assignDriver,
                      icon: Icons.person_add_alt,
                      onPressed: () =>
                          context.push('/vehicles/$vehicleId/assign'),
                    ),
                  ),
                )
              else ...[
                SectionHeader(l10n.currentDriver),
                ListTile(
                  minTileHeight: 80,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: Spacing.gutter,
                  ),
                  leading: DriverAvatar(
                    name: current.driverName,
                    photoFile: null,
                  ),
                  title: Text(current.driverName),
                  subtitle: Text(
                    '${payModelSummary(l10n, formatter, current.assignment.payModel)}\n'
                    '${l10n.sinceDate(formatDay(formatter, current.assignment.start))}',
                  ),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () =>
                      context.push('/drivers/${current.assignment.driverId}'),
                ),
                Padding(
                  padding: const EdgeInsets.all(Spacing.gutter),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      BigButton(
                        label: l10n.changeDriver,
                        icon: Icons.swap_horiz,
                        onPressed: () =>
                            context.push('/vehicles/$vehicleId/assign'),
                      ),
                      const SizedBox(height: Spacing.sm),
                      BigButton(
                        label: l10n.endAssignment,
                        style: BigButtonStyle.outlined,
                        icon: Icons.person_remove_outlined,
                        onPressed: () => _end(context, ref, current),
                      ),
                    ],
                  ),
                ),
              ],
              if (past.isNotEmpty) ...[
                SectionHeader(l10n.assignmentHistory),
                for (final v in past)
                  KhataListTile(
                    icon: Icons.history,
                    title: v.driverName,
                    subtitle:
                        '${l10n.dateRange(formatDay(formatter, v.assignment.start), formatDay(formatter, v.assignment.end!))}\n'
                        '${payModelSummary(l10n, formatter, v.assignment.payModel)}',
                    onTap: () =>
                        context.push('/drivers/${v.assignment.driverId}'),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }

  Future<void> _end(
    BuildContext context,
    WidgetRef ref,
    AssignmentView current,
  ) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.endAssignmentTitle),
        content: Text(
          l10n.endAssignmentBody(current.driverName, current.vehicleNickname),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.endAssignment),
          ),
        ],
      ),
    );
    if (!(ok ?? false)) return;
    final today = CalendarDay.today(ref.read(clockProvider));
    // Cannot end before the assignment started (e.g. one dated in the future).
    final endDay = today.isBefore(current.assignment.start)
        ? current.assignment.start
        : today;
    await ref
        .read(assignmentRepositoryProvider)
        .end(current.assignment.id, endDay);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.assignmentEnded)));
  }
}

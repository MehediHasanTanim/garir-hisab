import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vehicle_khata/app/l10n_labels.dart';
import 'package:vehicle_khata/app/providers/feature_providers.dart';
import 'package:vehicle_khata/app/providers/providers.dart';
import 'package:vehicle_khata/app/ui/format.dart';
import 'package:vehicle_khata/app/ui/tokens.dart';
import 'package:vehicle_khata/app/ui/widgets/big_button.dart';
import 'package:vehicle_khata/app/ui/widgets/empty_state.dart';
import 'package:vehicle_khata/core/time/calendar_day.dart';
import 'package:vehicle_khata/features/app_lock/presentation/app_lock_controller.dart';
import 'package:vehicle_khata/features/drivers/data/assignment_repository.dart';
import 'package:vehicle_khata/features/drivers/data/driver_repository.dart';
import 'package:vehicle_khata/features/drivers/domain/driver.dart';
import 'package:vehicle_khata/features/drivers/domain/pay_model.dart';
import 'package:vehicle_khata/features/drivers/presentation/pay_model_editor.dart';
import 'package:vehicle_khata/l10n/gen/app_localizations.dart';

/// Assign a driver to a vehicle (or switch / change pay terms).
class AssignmentFormPage extends ConsumerStatefulWidget {
  const new({required this.vehicleId, super.key});

  final String vehicleId;

  @override
  ConsumerState<AssignmentFormPage> createState() => _AssignmentFormPageState();
}

class _AssignmentFormPageState extends ConsumerState<AssignmentFormPage> {
  final _editorKey = GlobalKey<PayModelEditorState>();
  String? _driverId;
  CalendarDay? _start;
  String? _error;
  bool _saving = false;
  bool _prefilled = false;

  Future<void> _pickStart(CalendarDay current) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: current.toDate(),
      firstDate: DateTime(2000),
      lastDate: DateTime(DateTime.now().year + 2),
    );
    if (picked != null) setState(() => _start = CalendarDay.fromDate(picked));
  }

  Future<void> _save(CalendarDay start) async {
    final l10n = AppLocalizations.of(context);
    final driverId = _driverId;
    final model = _editorKey.currentState?.submit();
    if (driverId == null) {
      setState(() => _error = l10n.errSelectDriver);
      return;
    }
    if (model == null) return;

    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref
          .read(assignmentRepositoryProvider)
          .assign(
            vehicleId: widget.vehicleId,
            driverId: driverId,
            payModel: model,
            start: start,
          );
    } on AssignmentException catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = l10n.assignmentError(e.error);
      });
      return;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.assignmentSaved)));
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/vehicles/${widget.vehicleId}/driver');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final formatter = ref.watch(numberFormatterProvider);
    final vehicle = ref.watch(vehicleProvider(widget.vehicleId)).value;
    final drivers = ref.watch(
      driverListProvider(
        const DriverFilter(status: DriverStatus.active, limit: 500),
      ),
    );
    final assignments = ref.watch(vehicleAssignmentsProvider(widget.vehicleId));
    final today = CalendarDay.today(ref.watch(clockProvider));
    final start = _start ?? today;

    if (vehicle == null) {
      return Scaffold(
        appBar: AppBar(),
        body: EmptyState(icon: Icons.search_off, title: l10n.vehicleNotFound),
      );
    }
    if (!assignments.hasValue) {
      // Wait so the editor can start from the current pay terms.
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final allowed = allowedPayTypes(vehicle.businessModel);
    final current = assignments.value
        ?.where((a) => a.assignment.isActive)
        .firstOrNull;

    // Start from the current terms when changing an existing assignment.
    if (!_prefilled && current != null) {
      _prefilled = true;
      _driverId = current.assignment.driverId;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(current == null ? l10n.assignDriver : l10n.changeDriver),
      ),
      body: allowed.isEmpty
          ? EmptyState(
              icon: Icons.person_outline,
              title: l10n.noDriverAssigned,
              message: l10n.selfDrivenNoDriver,
            )
          : drivers.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => Center(child: Text(l10n.errUnknown)),
              data: (driverList) {
                if (driverList.isEmpty) {
                  return EmptyState(
                    icon: Icons.badge_outlined,
                    title: l10n.noActiveDrivers,
                    action: BigButton(
                      label: l10n.addDriver,
                      icon: Icons.person_add_alt,
                      onPressed: () => context.push('/drivers/new'),
                    ),
                  );
                }
                return SafeArea(
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(Spacing.gutter),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              DropdownButtonFormField<String>(
                                initialValue:
                                    driverList.any((d) => d.id == _driverId)
                                    ? _driverId
                                    : null,
                                isExpanded: true,
                                decoration: InputDecoration(
                                  labelText: l10n.selectDriver,
                                  border: const OutlineInputBorder(),
                                ),
                                items: [
                                  for (final d in driverList)
                                    DropdownMenuItem(
                                      value: d.id,
                                      child: Text(d.name),
                                    ),
                                ],
                                onChanged: (id) => setState(() {
                                  _driverId = id;
                                  _error = null;
                                }),
                              ),
                              const SizedBox(height: Spacing.md),
                              InkWell(
                                onTap: () => _pickStart(start),
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: l10n.startDate,
                                    border: const OutlineInputBorder(),
                                    suffixIcon: const Icon(
                                      Icons.calendar_today_outlined,
                                    ),
                                  ),
                                  child: Text(formatDay(formatter, start)),
                                ),
                              ),
                              if (current != null)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: Spacing.sm,
                                  ),
                                  child: Text(
                                    l10n.replacesNote(
                                      current.driverName,
                                      formatDay(formatter, start.addDays(-1)),
                                    ),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall,
                                  ),
                                ),
                              const SizedBox(height: Spacing.lg),
                              PayModelEditor(
                                key: _editorKey,
                                allowedTypes: allowed,
                                initial: current?.assignment.payModel,
                              ),
                              if (_error != null)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: Spacing.md,
                                  ),
                                  child: Text(
                                    _error!,
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .error,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          Spacing.gutter,
                          Spacing.sm,
                          Spacing.gutter,
                          Spacing.md,
                        ),
                        child: BigButton(
                          label: l10n.save,
                          icon: Icons.check,
                          onPressed: _saving ? null : () => _save(start),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

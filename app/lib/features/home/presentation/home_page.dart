import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vehicle_khata/app/l10n_labels.dart';
import 'package:vehicle_khata/app/providers/feature_providers.dart';
import 'package:vehicle_khata/app/ui/tokens.dart';
import 'package:vehicle_khata/app/ui/widgets/big_button.dart';
import 'package:vehicle_khata/app/ui/widgets/empty_state.dart';
import 'package:vehicle_khata/features/daylog/presentation/today_card.dart';
import 'package:vehicle_khata/features/vehicles/data/vehicle_repository.dart';
import 'package:vehicle_khata/features/vehicles/domain/vehicle.dart';
import 'package:vehicle_khata/features/vehicles/domain/vehicle_enums.dart';
import 'package:vehicle_khata/features/vehicles/presentation/vehicle_photo.dart';
import 'package:vehicle_khata/l10n/gen/app_localizations.dart';

const _pageSize = 30;

class HomePage extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final _scroll = ScrollController();
  final _search = TextEditingController();
  Timer? _debounce;
  VehicleFilter _filter = const VehicleFilter();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_maybeLoadMore);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scroll.dispose();
    _search.dispose();
    super.dispose();
  }

  void _maybeLoadMore() {
    if (!_scroll.hasClients) return;
    final nearEnd = _scroll.position.extentAfter < 300;
    final current = ref.read(vehicleListProvider(_filter)).value;
    if (nearEnd && current != null && current.length >= _filter.limit) {
      setState(
        () => _filter = _filter.copyWith(limit: _filter.limit + _pageSize),
      );
    }
  }

  void _onSearch(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      if (mounted) {
        setState(
          () => _filter = _filter.copyWith(query: text, limit: _pageSize),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final vehicles = ref.watch(vehicleListProvider(_filter));
    final isFiltering =
        _filter.query.trim().isNotEmpty ||
        _filter.status != null ||
        _filter.includeArchived;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.vehiclesTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/vehicles/new'),
        icon: const Icon(Icons.add),
        label: Text(l10n.addVehicle),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Spacing.gutter,
              Spacing.sm,
              Spacing.gutter,
              0,
            ),
            child: SearchBar(
              controller: _search,
              hintText: l10n.searchVehicles,
              leading: const Icon(Icons.search),
              onChanged: _onSearch,
              elevation: const WidgetStatePropertyAll(0),
            ),
          ),
          SizedBox(
            height: 56,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.gutter,
                vertical: Spacing.sm,
              ),
              child: Row(
                children: [
                  _chip(
                    l10n.filterAll,
                    selected: _filter.status == null,
                    onTap: () => setState(
                      () => _filter = _filter.copyWith(
                        status: () => null,
                        limit: _pageSize,
                      ),
                    ),
                  ),
                  for (final s in VehicleStatus.values)
                    _chip(
                      l10n.statusName(s),
                      selected: _filter.status == s,
                      onTap: () => setState(
                        () => _filter = _filter.copyWith(
                          status: () => s,
                          limit: _pageSize,
                        ),
                      ),
                    ),
                  _chip(
                    l10n.showArchived,
                    selected: _filter.includeArchived,
                    onTap: () => setState(
                      () => _filter = _filter.copyWith(
                        includeArchived: !_filter.includeArchived,
                        limit: _pageSize,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: vehicles.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => Center(child: Text(l10n.errUnknown)),
              data: (list) {
                if (list.isEmpty) {
                  return isFiltering
                      ? EmptyState(
                          icon: Icons.search_off,
                          title: l10n.noResults,
                        )
                      : EmptyState(
                          icon: Icons.directions_car_outlined,
                          title: l10n.homeEmptyTitle,
                          message: l10n.homeEmptyMessage,
                          action: BigButton(
                            label: l10n.homeEmptyAction,
                            icon: Icons.add,
                            onPressed: () => context.push('/vehicles/new'),
                          ),
                        );
                }
                return ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.only(bottom: 96),
                  itemCount: list.length + 1,
                  itemBuilder: (context, i) => i == 0
                      ? const TodayCard()
                      : _VehicleTile(vehicle: list[i - 1]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(
    String label, {
    required bool selected,
    required VoidCallback onTap,
  }) => Padding(
    padding: const EdgeInsets.only(right: Spacing.sm),
    child: FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    ),
  );
}

class _VehicleTile extends ConsumerWidget {
  const new({required this.vehicle});

  final Vehicle vehicle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final details = [
      l10n.vehicleTypeName(vehicle.type),
      if (vehicle.regNo != null) vehicle.regNo!,
      if (vehicle.model != null) vehicle.model!,
    ].join(' · ');

    return ListTile(
      minTileHeight: 72,
      contentPadding: const EdgeInsets.only(
        left: Spacing.gutter,
        right: Spacing.xs,
      ),
      leading: VehiclePhoto(type: vehicle.type, photoFile: vehicle.photoFile),
      title: Text(vehicle.nickname),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(details),
          const SizedBox(height: Spacing.xs),
          Wrap(
            spacing: Spacing.sm,
            children: [
              _StatusLabel(
                text: l10n.statusName(vehicle.status),
                color: switch (vehicle.status) {
                  VehicleStatus.active => scheme.primary,
                  VehicleStatus.inGarage => scheme.tertiary,
                  VehicleStatus.sold => scheme.outline,
                },
              ),
              if (vehicle.archived)
                _StatusLabel(text: l10n.statusArchived, color: scheme.outline),
            ],
          ),
        ],
      ),
      onTap: () => context.push('/vehicles/${vehicle.id}/edit'),
      trailing: PopupMenuButton<_Action>(
        onSelected: (a) => _onAction(context, ref, a),
        itemBuilder: (_) => [
          PopupMenuItem(value: _Action.edit, child: Text(l10n.editVehicle)),
          PopupMenuItem(value: _Action.driver, child: Text(l10n.driverAndPay)),
          if (vehicle.businessModel == BusinessModel.jama)
            PopupMenuItem(value: _Action.jama, child: Text(l10n.jamaTitle)),
          PopupMenuItem(
            value: _Action.expenses,
            child: Text(l10n.vehicleExpenses),
          ),
          PopupMenuItem(value: _Action.status, child: Text(l10n.changeStatus)),
          PopupMenuItem(
            value: vehicle.archived ? _Action.restore : _Action.archive,
            child: Text(vehicle.archived ? l10n.restore : l10n.archive),
          ),
        ],
      ),
    );
  }

  Future<void> _onAction(
    BuildContext context,
    WidgetRef ref,
    _Action action,
  ) async {
    final l10n = AppLocalizations.of(context);
    final repo = ref.read(vehicleRepositoryProvider);
    final messenger = ScaffoldMessenger.of(context);
    switch (action) {
      case _Action.edit:
        await context.push('/vehicles/${vehicle.id}/edit');
      case _Action.expenses:
        await context.push('/vehicles/${vehicle.id}/expenses');
      case _Action.driver:
        await context.push('/vehicles/${vehicle.id}/driver');
      case _Action.jama:
        await context.push('/vehicles/${vehicle.id}/jama');
      case _Action.status:
        final picked = await showDialog<VehicleStatus>(
          context: context,
          builder: (context) => SimpleDialog(
            title: Text(l10n.changeStatus),
            children: [
              for (final s in VehicleStatus.values)
                SimpleDialogOption(
                  onPressed: () => Navigator.pop(context, s),
                  child: Row(
                    children: [
                      Icon(
                        s == vehicle.status
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                      ),
                      const SizedBox(width: Spacing.md),
                      Text(l10n.statusName(s)),
                    ],
                  ),
                ),
            ],
          ),
        );
        if (picked != null) await repo.setStatus(vehicle.id, picked);
      case _Action.archive:
        final ok = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.archiveConfirmTitle),
            content: Text(l10n.archiveConfirmBody),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(l10n.archive),
              ),
            ],
          ),
        );
        if (ok ?? false) {
          await repo.setArchived(vehicle.id, archived: true);
          messenger
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(l10n.vehicleArchived)));
        }
      case _Action.restore:
        await repo.setArchived(vehicle.id, archived: false);
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(l10n.vehicleRestored)));
    }
  }
}

enum _Action { edit, driver, jama, expenses, status, archive, restore }

class _StatusLabel extends StatelessWidget {
  const new({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: Theme.of(context).textTheme.labelMedium
        ?.copyWith(color: color, fontWeight: FontWeight.w600),
  );
}

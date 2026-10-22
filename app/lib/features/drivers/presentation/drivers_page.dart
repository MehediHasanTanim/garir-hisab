import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vehicle_khata/app/providers/feature_providers.dart';
import 'package:vehicle_khata/app/providers/providers.dart';
import 'package:vehicle_khata/app/ui/format.dart';
import 'package:vehicle_khata/app/ui/tokens.dart';
import 'package:vehicle_khata/app/ui/widgets/big_button.dart';
import 'package:vehicle_khata/app/ui/widgets/empty_state.dart';
import 'package:vehicle_khata/core/time/calendar_day.dart';
import 'package:vehicle_khata/features/app_lock/presentation/app_lock_controller.dart';
import 'package:vehicle_khata/features/drivers/data/driver_repository.dart';
import 'package:vehicle_khata/features/drivers/domain/driver.dart';
import 'package:vehicle_khata/features/drivers/presentation/driver_avatar.dart';
import 'package:vehicle_khata/l10n/gen/app_localizations.dart';

const _pageSize = 30;

class DriversPage extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<DriversPage> createState() => _DriversPageState();
}

class _DriversPageState extends ConsumerState<DriversPage> {
  final _scroll = ScrollController();
  final _search = TextEditingController();
  Timer? _debounce;
  DriverFilter _filter = const DriverFilter(status: DriverStatus.active);

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
    final current = ref.read(driverListProvider(_filter)).value;
    if (_scroll.position.extentAfter < 300 &&
        current != null &&
        current.length >= _filter.limit) {
      setState(
        () => _filter = _filter.copyWith(limit: _filter.limit + _pageSize),
      );
    }
  }

  void _setStatus(DriverStatus? status) => setState(
    () => _filter = _filter.copyWith(status: () => status, limit: _pageSize),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final drivers = ref.watch(driverListProvider(_filter));
    final isFiltering =
        _filter.query.trim().isNotEmpty ||
        _filter.status != DriverStatus.active;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.driversTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/drivers/new'),
        icon: const Icon(Icons.person_add_alt),
        label: Text(l10n.addDriver),
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
              hintText: l10n.searchDrivers,
              leading: const Icon(Icons.search),
              elevation: const WidgetStatePropertyAll(0),
              onChanged: (text) {
                _debounce?.cancel();
                _debounce = Timer(const Duration(milliseconds: 250), () {
                  if (mounted) {
                    setState(
                      () => _filter = _filter.copyWith(
                        query: text,
                        limit: _pageSize,
                      ),
                    );
                  }
                });
              },
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.gutter,
              vertical: Spacing.sm,
            ),
            child: Row(
              children: [
                for (final (label, status) in [
                  (l10n.driverStatusActive, DriverStatus.active),
                  (l10n.driverStatusLeft, DriverStatus.left),
                  (l10n.filterAll, null),
                ])
                  Padding(
                    padding: const EdgeInsets.only(right: Spacing.sm),
                    child: FilterChip(
                      label: Text(label),
                      selected: _filter.status == status,
                      onSelected: (_) => _setStatus(status),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: drivers.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => Center(child: Text(l10n.errUnknown)),
              data: (list) {
                if (list.isEmpty) {
                  return isFiltering
                      ? EmptyState(
                          icon: Icons.search_off,
                          title: l10n.driversNoResults,
                        )
                      : EmptyState(
                          icon: Icons.badge_outlined,
                          title: l10n.driversEmptyTitle,
                          message: l10n.driversEmptyMessage,
                          action: BigButton(
                            label: l10n.addDriver,
                            icon: Icons.person_add_alt,
                            onPressed: () => context.push('/drivers/new'),
                          ),
                        );
                }
                return ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.only(bottom: 96),
                  itemCount: list.length,
                  itemBuilder: (context, i) => _DriverTile(driver: list[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DriverTile extends ConsumerWidget {
  const new({required this.driver});

  final Driver driver;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final formatter = ref.watch(numberFormatterProvider);
    final today = CalendarDay.today(ref.watch(clockProvider));
    final expiry = driver.licenseExpiry;
    final expired = expiry != null && expiry.isBefore(today);
    final soon = expiry != null && !expired && today.daysUntil(expiry) <= 30;

    return ListTile(
      minTileHeight: 72,
      contentPadding: const EdgeInsets.symmetric(horizontal: Spacing.gutter),
      leading: DriverAvatar(name: driver.name, photoFile: driver.photoFile),
      title: Text(driver.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (driver.phone != null) Text(formatter.digits(driver.phone!)),
          if (!driver.isActive)
            Text(
              l10n.driverStatusLeft,
              style: TextStyle(color: scheme.outline),
            ),
          if (expired || soon)
            Text(
              expired
                  ? l10n.licenseExpired
                  : l10n.licenseExpiresSoon(formatDay(formatter, expiry)),
              style: TextStyle(color: scheme.error),
            ),
        ],
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.push('/drivers/${driver.id}'),
    );
  }
}

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
import 'package:vehicle_khata/features/trips/data/trip_repository.dart';
import 'package:vehicle_khata/features/trips/domain/trip.dart';
import 'package:vehicle_khata/features/vehicles/data/vehicle_repository.dart';
import 'package:vehicle_khata/l10n/gen/app_localizations.dart';

const _pageSize = 30;

const _allVehicles = '__all__';

enum _Period { all, today, thisMonth, lastMonth }

/// The Entries tab: every trip, newest first.
class EntriesPage extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<EntriesPage> createState() => _EntriesPageState();
}

class _EntriesPageState extends ConsumerState<EntriesPage> {
  final _scroll = ScrollController();
  TripFilter _filter = const TripFilter();
  _Period _period = _Period.all;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (!_scroll.hasClients) return;
      final current = ref.read(tripListProvider(_filter)).value;
      if (_scroll.position.extentAfter < 300 &&
          current != null &&
          current.length >= _filter.limit) {
        setState(
          () => _filter = _filter.copyWith(limit: _filter.limit + _pageSize),
        );
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  DayRange? _rangeFor(_Period p) {
    final today = CalendarDay.today(ref.read(clockProvider));
    return switch (p) {
      _Period.all => null,
      _Period.today => DayRange(today, today),
      _Period.thisMonth => DayRange.month(today.year, today.month),
      _Period.lastMonth => () {
        final first = CalendarDay.of(today.year, today.month - 1, 1);
        return DayRange.month(first.year, first.month);
      }(),
    };
  }

  void _setPeriod(_Period p) {
    setState(() {
      _period = p;
      _filter = _filter.copyWith(range: () => _rangeFor(p), limit: _pageSize);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final formatter = ref.watch(numberFormatterProvider);
    final trips = ref.watch(tripListProvider(_filter));
    final vehicles =
        ref.watch(vehicleListProvider(const VehicleFilter(limit: 500))).value ??
        const [];
    final isFiltering =
        _filter.vehicleId != null ||
        _filter.range != null ||
        _filter.status != null;

    String periodLabel(_Period p) => switch (p) {
      _Period.all => l10n.filterPeriodAll,
      _Period.today => l10n.filterToday,
      _Period.thisMonth => l10n.filterThisMonth,
      _Period.lastMonth => l10n.filterLastMonth,
    };

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navEntries)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/trips/new'),
        icon: const Icon(Icons.add),
        label: Text(l10n.addTrip),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.gutter,
              vertical: Spacing.sm,
            ),
            child: Row(
              children: [
                for (final (label, status) in [
                  (l10n.filterAll, null),
                  (l10n.payPaid, PaymentStatus.paid),
                  (l10n.payPartial, PaymentStatus.partial),
                  (l10n.payUnpaid, PaymentStatus.unpaid),
                ])
                  Padding(
                    padding: const EdgeInsets.only(right: Spacing.sm),
                    child: FilterChip(
                      label: Text(label),
                      selected: _filter.status == status,
                      onSelected: (_) => setState(
                        () => _filter = _filter.copyWith(
                          status: () => status,
                          limit: _pageSize,
                        ),
                      ),
                    ),
                  ),
                // A menu item with a null value is never "selected", so "all vehicles"
                // uses a sentinel value.
                PopupMenuButton<String>(
                  tooltip: l10n.payVehicle,
                  onSelected: (id) => setState(
                    () => _filter = _filter.copyWith(
                      vehicleId: () => id == _allVehicles ? null : id,
                      limit: _pageSize,
                    ),
                  ),
                  itemBuilder: (_) => [
                    PopupMenuItem<String>(
                      value: _allVehicles,
                      child: Text(l10n.filterVehicleAll),
                    ),
                    for (final v in vehicles)
                      PopupMenuItem<String>(
                        value: v.id,
                        child: Text(v.nickname),
                      ),
                  ],
                  child: Chip(
                    avatar: const Icon(Icons.directions_car_outlined, size: 18),
                    label: Text(
                      vehicles
                              .where((v) => v.id == _filter.vehicleId)
                              .firstOrNull
                              ?.nickname ??
                          l10n.filterVehicleAll,
                    ),
                  ),
                ),
                const SizedBox(width: Spacing.sm),
                PopupMenuButton<_Period>(
                  tooltip: l10n.payPeriod,
                  onSelected: _setPeriod,
                  itemBuilder: (_) => [
                    for (final p in _Period.values)
                      PopupMenuItem(value: p, child: Text(periodLabel(p))),
                  ],
                  child: Chip(
                    avatar: const Icon(Icons.date_range_outlined, size: 18),
                    label: Text(periodLabel(_period)),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: trips.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => Center(child: Text(l10n.errUnknown)),
              data: (list) {
                if (list.isEmpty) {
                  return isFiltering
                      ? EmptyState(
                          icon: Icons.search_off,
                          title: l10n.noTripsMatch,
                        )
                      : EmptyState(
                          icon: Icons.receipt_long_outlined,
                          title: l10n.entriesEmptyTitle,
                          message: l10n.entriesEmptyMessage,
                          action: BigButton(
                            label: l10n.addTrip,
                            icon: Icons.add,
                            onPressed: () => context.push('/trips/new'),
                          ),
                        );
                }
                final items = <Widget>[];
                CalendarDay? lastDay;
                for (final s in list) {
                  if (s.trip.day != lastDay) {
                    lastDay = s.trip.day;
                    items.add(SectionHeader(formatDay(formatter, s.trip.day)));
                  }
                  items.add(_TripTile(summary: s));
                }
                return ListView(
                  controller: _scroll,
                  padding: const EdgeInsets.only(bottom: 96),
                  children: items,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TripTile extends ConsumerWidget {
  const new({required this.summary});

  final TripSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final formatter = ref.watch(numberFormatterProvider);
    final scheme = Theme.of(context).colorScheme;
    final t = summary.trip;
    final route = [t.fromPlace, t.toPlace].whereType<String>().join(' → ');
    final status = switch (t.status) {
      PaymentStatus.paid => l10n.payPaid,
      PaymentStatus.partial => l10n.dueAmount(formatter.money(t.due)),
      PaymentStatus.unpaid => l10n.dueAmount(formatter.money(t.due)),
    };

    final subtitle = [
      summary.vehicleNickname,
      if (summary.driverName != null) summary.driverName!,
      '${l10n.tripFare} ${formatter.money(t.fare)}',
    ].join(' · ');
    final textTheme = Theme.of(context).textTheme;

    // Laid out by hand (not a ListTile) so it grows with large text sizes.
    return InkWell(
      onTap: () => context.push('/trips/${t.id}'),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 72),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.gutter,
            vertical: Spacing.sm,
          ),
          child: Row(
            children: [
              const CircleAvatar(child: Icon(Icons.local_shipping_outlined)),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      route.isEmpty ? l10n.tripTitle : route,
                      style: textTheme.bodyLarge,
                    ),
                    Text(
                      subtitle,
                      style: textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AmountText(amount: summary.profit, formatter: formatter),
                  Text(
                    status,
                    style: textTheme.labelSmall?.copyWith(
                      color: t.status == PaymentStatus.paid
                          ? scheme.outline
                          : scheme.error,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

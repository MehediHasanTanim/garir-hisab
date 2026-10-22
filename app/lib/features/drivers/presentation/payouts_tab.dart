import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vehicle_khata/app/providers/feature_providers.dart';
import 'package:vehicle_khata/app/providers/providers.dart';
import 'package:vehicle_khata/app/ui/format.dart';
import 'package:vehicle_khata/app/ui/tokens.dart';
import 'package:vehicle_khata/app/ui/widgets/empty_state.dart';
import 'package:vehicle_khata/core/time/calendar_day.dart';
import 'package:vehicle_khata/features/drivers/data/payout_service.dart';
import 'package:vehicle_khata/features/drivers/domain/driver.dart';
import 'package:vehicle_khata/l10n/gen/app_localizations.dart';

class PayoutsTab extends ConsumerWidget {
  const new({required this.driverId, super.key});

  final String driverId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final formatter = ref.watch(numberFormatterProvider);
    final payouts = ref.watch(driverPayoutsProvider(driverId));

    return payouts.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => Center(child: Text(l10n.errUnknown)),
      data: (list) => ListView(
        padding: const EdgeInsets.only(bottom: Spacing.xl),
        children: [
          Padding(
            padding: const EdgeInsets.all(Spacing.gutter),
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(Sizes.bigButtonHeight),
              ),
              onPressed: () => context.push('/drivers/$driverId/payout/new'),
              icon: const Icon(Icons.payments_outlined),
              label: Text(l10n.newPayout),
            ),
          ),
          if (list.isEmpty)
            SizedBox(
              height: 320,
              child: EmptyState(
                icon: Icons.receipt_long_outlined,
                title: l10n.payoutsEmptyTitle,
                message: l10n.payoutsEmptyMessage,
              ),
            ),
          for (final p in list)
            ListTile(
              minTileHeight: 72,
              leading: const CircleAvatar(child: Icon(Icons.payments_outlined)),
              title: Text(formatter.money(p.net)),
              subtitle: Text(
                '${l10n.dateRange(formatDay(formatter, p.period.start), formatDay(formatter, p.period.end))}\n'
                '${l10n.paidOn(formatDay(formatter, CalendarDay.fromDate(p.paidAt.toLocal())))}',
              ),
              isThreeLine: true,
              onTap: () => _showDetail(context, ref, p),
            ),
        ],
      ),
    );
  }

  Future<void> _showDetail(BuildContext context, WidgetRef ref, Payout payout) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => _PayoutDetail(payout: payout),
    );
  }
}

class _PayoutDetail extends ConsumerWidget {
  const new({required this.payout});

  final Payout payout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final formatter = ref.watch(numberFormatterProvider);
    final theme = Theme.of(context);

    Widget line(String label, String value, {bool bold = false}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: bold ? theme.textTheme.titleMedium : null,
            ),
          ),
          Text(
            value,
            style: bold
                ? theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  )
                : null,
          ),
        ],
      ),
    );

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          Spacing.gutter,
          0,
          Spacing.gutter,
          Spacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.dateRange(
                formatDay(formatter, payout.period.start),
                formatDay(formatter, payout.period.end),
              ),
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: Spacing.md),
            line(l10n.payEarned, formatter.money(payout.earned)),
            if (!payout.adjustment.isZero)
              line(
                payout.adjustmentNote == null
                    ? l10n.payAdjustment
                    : '${l10n.payAdjustment} · ${payout.adjustmentNote}',
                formatter.money(payout.adjustment),
              ),
            if (payout.deducted.isPositive)
              line(l10n.payAdvancesDeducted, formatter.money(-payout.deducted)),
            const Divider(),
            line(l10n.payNet, formatter.money(payout.net), bold: true),
            if (payout.note != null) ...[
              const SizedBox(height: Spacing.sm),
              Text(payout.note!),
            ],
            const SizedBox(height: Spacing.lg),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(Sizes.bigButtonHeight),
                foregroundColor: theme.colorScheme.error,
              ),
              onPressed: () => _void(context, ref),
              icon: const Icon(Icons.block),
              label: Text(l10n.payoutVoid),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _void(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.payoutVoidTitle),
        content: Text(l10n.payoutVoidBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.payoutVoid),
          ),
        ],
      ),
    );
    if (!(ok ?? false)) return;
    try {
      await ref.read(payoutServiceProvider).voidPayout(payout.id);
      navigator.pop();
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.payoutVoided)));
    } on PayoutException {
      navigator.pop();
    }
  }
}

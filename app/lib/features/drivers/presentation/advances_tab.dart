import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vehicle_khata/app/providers/feature_providers.dart';
import 'package:vehicle_khata/app/providers/providers.dart';
import 'package:vehicle_khata/app/ui/format.dart';
import 'package:vehicle_khata/app/ui/tokens.dart';
import 'package:vehicle_khata/app/ui/widgets/empty_state.dart';
import 'package:vehicle_khata/app/ui/widgets/khata_list_tile.dart';
import 'package:vehicle_khata/core/money/money_parser.dart';
import 'package:vehicle_khata/core/time/calendar_day.dart';
import 'package:vehicle_khata/features/app_lock/presentation/app_lock_controller.dart';
import 'package:vehicle_khata/features/drivers/data/advance_repository.dart';
import 'package:vehicle_khata/features/drivers/domain/driver.dart';
import 'package:vehicle_khata/l10n/gen/app_localizations.dart';

class AdvancesTab extends ConsumerWidget {
  const new({required this.driverId, required this.canGive, super.key});

  final String driverId;
  final bool canGive;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final formatter = ref.watch(numberFormatterProvider);
    final advances = ref.watch(driverAdvancesProvider(driverId));
    final owed = ref.watch(driverOutstandingProvider(driverId)).value;

    return advances.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => Center(child: Text(l10n.errUnknown)),
      data: (list) => ListView(
        padding: const EdgeInsets.only(bottom: Spacing.xl),
        children: [
          if (canGive)
            Padding(
              padding: const EdgeInsets.all(Spacing.gutter),
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(Sizes.bigButtonHeight),
                ),
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => _GiveAdvanceDialog(driverId: driverId),
                ),
                icon: const Icon(Icons.add),
                label: Text(l10n.giveAdvance),
              ),
            ),
          if (owed != null && owed.isPositive)
            ListTile(
              title: Text(l10n.advancesOwed),
              trailing: AmountText(amount: owed, formatter: formatter),
            ),
          if (list.isEmpty)
            SizedBox(
              height: 320,
              child: EmptyState(
                icon: Icons.account_balance_wallet_outlined,
                title: l10n.advancesEmptyTitle,
                message: l10n.advancesEmptyMessage,
              ),
            ),
          for (final a in list) _AdvanceTile(advance: a),
        ],
      ),
    );
  }
}

class _AdvanceTile extends ConsumerWidget {
  const new({required this.advance});

  final Advance advance;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final formatter = ref.watch(numberFormatterProvider);
    final status = advance.isSettled
        ? l10n.advanceSettled
        : advance.recovered.isPositive
        ? '${l10n.advanceRecovered(formatter.money(advance.recovered))} · '
              '${l10n.advanceRemaining(formatter.money(advance.remaining))}'
        : l10n.advanceRemaining(formatter.money(advance.remaining));

    return ListTile(
      minTileHeight: 64,
      leading: const CircleAvatar(child: Icon(Icons.payments_outlined)),
      title: Text(formatter.money(advance.amount)),
      subtitle: Text(
        [
          formatDay(formatter, advance.givenOn),
          status,
          if (advance.note != null) advance.note!,
        ].join('\n'),
      ),
      isThreeLine: true,
      trailing: advance.recovered.isPositive
          ? null
          : IconButton(
              tooltip: l10n.deleteLabel,
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _confirmDelete(context, ref),
            ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteAdvanceTitle),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.deleteLabel),
          ),
        ],
      ),
    );
    if (!(ok ?? false)) return;
    try {
      await ref.read(advanceRepositoryProvider).remove(advance.id);
    } on AdvanceException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.error == AdvanceError.alreadyRecovered
                ? l10n.errAdvanceRecovered
                : l10n.errUnknown,
          ),
        ),
      );
    }
  }
}

class _GiveAdvanceDialog extends ConsumerStatefulWidget {
  const new({required this.driverId});

  final String driverId;

  @override
  ConsumerState<_GiveAdvanceDialog> createState() => _GiveAdvanceDialogState();
}

class _GiveAdvanceDialogState extends ConsumerState<_GiveAdvanceDialog> {
  final _amount = TextEditingController();
  final _note = TextEditingController();
  late CalendarDay _day = CalendarDay.today(ref.read(clockProvider));
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickDay() async {
    final today = CalendarDay.today(ref.read(clockProvider));
    final picked = await showDatePicker(
      context: context,
      initialDate: _day.toDate(),
      firstDate: DateTime(2000),
      lastDate: today.toDate(),
    );
    if (picked != null) setState(() => _day = CalendarDay.fromDate(picked));
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final amount = MoneyParser.parseTaka(_amount.text);
    if (amount == null || !amount.isPositive) {
      setState(() => _error = l10n.errAmountInvalid);
      return;
    }
    setState(() => _saving = true);
    await ref
        .read(advanceRepositoryProvider)
        .give(
          driverId: widget.driverId,
          amount: amount,
          day: _day,
          note: _note.text,
        );
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.advanceSaved)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final formatter = ref.watch(numberFormatterProvider);
    return AlertDialog(
      title: Text(l10n.giveAdvance),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _amount,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[0-9০-৯.,]')),
                LengthLimitingTextInputFormatter(14),
              ],
              decoration: InputDecoration(
                labelText: l10n.advanceAmount,
                errorText: _error,
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) {
                if (_error != null) setState(() => _error = null);
              },
            ),
            const SizedBox(height: Spacing.md),
            InkWell(
              onTap: _pickDay,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: l10n.advanceDate,
                  border: const OutlineInputBorder(),
                  suffixIcon: const Icon(Icons.calendar_today_outlined),
                ),
                child: Text(formatDay(formatter, _day)),
              ),
            ),
            const SizedBox(height: Spacing.md),
            TextField(
              controller: _note,
              decoration: InputDecoration(
                labelText: l10n.advanceNote,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(onPressed: _saving ? null : _save, child: Text(l10n.save)),
      ],
    );
  }
}

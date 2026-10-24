import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vehicle_khata/app/providers/feature_providers.dart';
import 'package:vehicle_khata/app/providers/providers.dart';
import 'package:vehicle_khata/app/ui/tokens.dart';
import 'package:vehicle_khata/app/ui/widgets/amount_sheet.dart';
import 'package:vehicle_khata/app/ui/widgets/big_button.dart';
import 'package:vehicle_khata/app/ui/widgets/empty_state.dart';
import 'package:vehicle_khata/core/money/money.dart';
import 'package:vehicle_khata/core/money/number_formatter.dart';
import 'package:vehicle_khata/features/jama/presentation/jama_page.dart';
import 'package:vehicle_khata/features/ledger/data/ledger_service.dart';
import 'package:vehicle_khata/features/ledger/domain/ledger_logic.dart';
import 'package:vehicle_khata/l10n/gen/app_localizations.dart';

final duesProvider = FutureProvider.autoDispose<List<PartyBalance>>(
  (ref) => ref.watch(ledgerServiceProvider).balances(),
);

class _PartyData {
  const new(this.items, this.aging, this.statement);

  final List<OpenItemLine> items;
  final Aging aging;
  final List<StatementLine> statement;
}

class OpenItemLine {
  const new(this.item);

  final OpenItem item;
}

final _partyProvider = FutureProvider.autoDispose.family<_PartyData, Party>((
  ref,
  party,
) async {
  final svc = ref.watch(ledgerServiceProvider);
  final today = ref.watch(todayProvider);
  final items = await svc.openItems(party: party);
  return _PartyData(
    [for (final i in items) OpenItemLine(i)],
    await svc.aging(party, today),
    await svc.statement(party),
  );
});

String partyName(AppLocalizations l10n, PartyBalance b) =>
    b.party.type == PartyType.customer ? l10n.duesCustomers : b.name;

String duesErrorText(AppLocalizations l10n, Object e) => switch (e) {
  LedgerException(error: LedgerError.exceedsOwed) => l10n.duesErrExceeds,
  LedgerException(error: LedgerError.nothingOwed) => l10n.duesErrNothing,
  _ => l10n.duesErrGeneric,
};

/// More → Dues: everyone who owes you, and everyone you owe.
class DuesPage extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final f = ref.watch(numberFormatterProvider);
    final dues = ref.watch(duesProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.duesTitle)),
      body: SafeArea(
        child: dues.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) =>
              EmptyState(icon: Icons.error_outline, title: l10n.errUnknown),
          data: (list) {
            if (list.isEmpty) {
              return EmptyState(
                icon: Icons.account_balance_wallet_outlined,
                title: l10n.duesEmpty,
              );
            }
            return ListView(
              children: [
                for (final b in list)
                  ListTile(
                    minTileHeight: 64,
                    leading: Icon(
                      b.party.type == PartyType.customer
                          ? Icons.groups_outlined
                          : Icons.badge_outlined,
                    ),
                    title: Text(partyName(l10n, b)),
                    subtitle: Text(
                      b.balance.isPositive
                          ? l10n.duesOwesYou(f.money(b.balance))
                          : l10n.duesYouOwe(f.money(b.balance.abs())),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      await context.push(
                        '/more/dues/party?type=${b.party.type.name}'
                        '&id=${b.party.id}&name=${Uri.encodeComponent(b.name)}',
                      );
                      ref.invalidate(duesProvider);
                    },
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// One party: balance, ageing, what is open, and the actions.
class PartyPage extends ConsumerWidget {
  const new({required this.party, required this.name, super.key});

  final Party party;
  final String name;

  String _typeLabel(AppLocalizations l10n, RefType t) => switch (t) {
    RefType.jama => l10n.duesTypeJama,
    RefType.advance => l10n.duesTypeAdvance,
    RefType.trip => l10n.duesTypeTrip,
    RefType.expense => l10n.duesTypeExpense,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final f = ref.watch(numberFormatterProvider);
    final data = ref.watch(_partyProvider(party));
    final display = party.type == PartyType.customer
        ? l10n.duesCustomers
        : name;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(display)),
      body: SafeArea(
        child: data.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) =>
              EmptyState(icon: Icons.error_outline, title: l10n.errUnknown),
          data: (d) {
            final balance = d.items.fold(
              Money.zero,
              (a, b) => a + b.item.amount,
            );
            final owedToYou = balance.isPositive;
            final payable = d.items
                .where(
                  (i) =>
                      i.item.refType != RefType.advance &&
                      i.item.isReceivable == owedToYou,
                )
                .isNotEmpty;
            return ListView(
              padding: const EdgeInsets.all(Spacing.gutter),
              children: [
                Text(
                  balance.isPositive
                      ? l10n.duesOwesYou(f.money(balance))
                      : l10n.duesYouOwe(f.money(balance.abs())),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: balance.isPositive
                        ? AppColors.income
                        : AppColors.expense,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: Spacing.md),
                if (balance.isPositive) _AgingRow(aging: d.aging, f: f),
                const SizedBox(height: Spacing.md),
                if (payable)
                  BigButton(
                    label: owedToYou ? l10n.duesReceive : l10n.duesPay,
                    icon: Icons.payments_outlined,
                    onPressed: () => _pay(context, ref, owedToYou),
                  ),
                if (owedToYou && balance.isPositive) ...[
                  const SizedBox(height: Spacing.sm),
                  BigButton(
                    label: l10n.duesRemind,
                    style: BigButtonStyle.outlined,
                    icon: Icons.sms_outlined,
                    onPressed: () => ref
                        .read(fileSharerProvider)
                        .shareText(
                          l10n.duesReminderText(
                            display,
                            f.money(balance, symbol: false),
                          ),
                        ),
                  ),
                ],
                const SizedBox(height: Spacing.sm),
                BigButton(
                  label: l10n.duesStatement,
                  style: BigButtonStyle.outlined,
                  icon: Icons.ios_share,
                  onPressed: () => ref
                      .read(fileSharerProvider)
                      .shareText(_statementText(l10n, f, display, d, balance)),
                ),
                const SizedBox(height: Spacing.lg),
                Text(l10n.duesOpenItems, style: theme.textTheme.titleMedium),
                for (final i in d.items)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(_typeLabel(l10n, i.item.refType)),
                    subtitle: Text(jamaDate(f, i.item.day)),
                    trailing: Text(
                      f.money(i.item.amount.abs()),
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                if (d.items.any((i) => i.item.refType == RefType.advance))
                  Padding(
                    padding: const EdgeInsets.only(top: Spacing.sm),
                    child: Text(
                      l10n.duesAdvanceNote,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _statementText(
    AppLocalizations l10n,
    NumberFormatter f,
    String display,
    _PartyData d,
    Money balance,
  ) {
    final b = StringBuffer(l10n.duesStatementHeader(display))..writeln();
    for (final i in d.items) {
      b.writeln(
        '${jamaDate(f, i.item.day)}  ${_typeLabel(l10n, i.item.refType)}  '
        '${f.money(i.item.amount.abs())}',
      );
    }
    b.write(l10n.duesStatementBalance(f.money(balance.abs())));
    return b.toString();
  }

  Future<void> _pay(BuildContext context, WidgetRef ref, bool incoming) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final amount = await showAmountSheet(context, title: l10n.duesPayTitle);
    if (amount == null || !amount.isPositive) return;
    final today = ref.read(todayProvider);
    try {
      await ref
          .read(ledgerServiceProvider)
          .recordPayment(
            party: party,
            incoming: incoming,
            amount: amount,
            day: today,
            today: today,
          );
      ref.invalidate(_partyProvider(party));
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('${l10n.duesPaymentDone}. ${l10n.duesAppliedOldest}'),
            persist: false,
          ),
        );
    } on Object catch (e) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(duesErrorText(l10n, e)), persist: false),
        );
    }
  }
}

class _AgingRow extends StatelessWidget {
  const new({required this.aging, required this.f});

  final Aging aging;
  final NumberFormatter f;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    Widget cell(String label, Money m) => Expanded(
      child: Column(
        children: [
          Text(f.money(m), style: Theme.of(context).textTheme.titleMedium),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        cell(l10n.duesAge07, aging.days0to7),
        cell(l10n.duesAge830, aging.days8to30),
        cell(l10n.duesAge30, aging.over30),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vehicle_khata/app/providers/feature_providers.dart';
import 'package:vehicle_khata/app/providers/providers.dart';
import 'package:vehicle_khata/app/ui/tokens.dart';
import 'package:vehicle_khata/app/ui/widgets/big_button.dart';
import 'package:vehicle_khata/core/money/number_formatter.dart';
import 'package:vehicle_khata/core/sync/sync_engine.dart';
import 'package:vehicle_khata/l10n/gen/app_localizations.dart';

/// Short, plain description of where syncing stands.
String syncPhaseText(AppLocalizations l10n, SyncStatus s) => switch (s.phase) {
  SyncPhase.disabled => l10n.syncDisabled,
  SyncPhase.idle => l10n.syncUpToDate,
  SyncPhase.syncing => l10n.syncSyncing,
  SyncPhase.offline => l10n.syncOffline,
  SyncPhase.signedOut => l10n.syncSignedOut,
  SyncPhase.wrongAccount => l10n.syncWrongAccount,
  SyncPhase.error => l10n.syncError,
};

String formatSyncTime(NumberFormatter formatter, int epochMs) {
  final d = DateTime.fromMillisecondsSinceEpoch(epochMs, isUtc: true).toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return formatter.digits(
    '${two(d.day)}/${two(d.month)}/${d.year} ${two(d.hour)}:${two(d.minute)}',
  );
}

/// More → Sync & backup: what is saved online, and the buttons to sync,
/// retry stuck items, or fetch everything again on a new phone.
class SyncPage extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final formatter = ref.watch(numberFormatterProvider);
    final engine = ref.watch(syncEngineProvider);
    final status =
        ref.watch(syncStatusProvider).value ??
        engine?.status ??
        const SyncStatus();
    final theme = Theme.of(context);
    final busy = status.phase == SyncPhase.syncing;
    final canSync =
        engine != null &&
        !busy &&
        status.phase != SyncPhase.disabled &&
        status.phase != SyncPhase.wrongAccount;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.syncTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(Spacing.gutter),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(Spacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(_icon(status.phase), size: 28),
                        const SizedBox(width: Spacing.md),
                        Expanded(
                          child: Text(
                            syncPhaseText(l10n, status),
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                      ],
                    ),
                    if (status.phase != SyncPhase.disabled) ...[
                      const SizedBox(height: Spacing.sm),
                      Text(
                        status.lastSyncedAt == null
                            ? l10n.syncNever
                            : l10n.syncLast(
                                formatSyncTime(formatter, status.lastSyncedAt!),
                              ),
                        style: theme.textTheme.bodyMedium,
                      ),
                      if (status.pending > 0)
                        Text(
                          l10n.syncWaiting(
                            formatter.digits('${status.pending}'),
                          ),
                          style: theme.textTheme.bodyMedium,
                        ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: Spacing.lg),
            BigButton(
              label: l10n.syncNow,
              icon: Icons.sync,
              onPressed: canSync ? engine.syncNow : null,
            ),
            if (status.issues > 0) ...[
              const SizedBox(height: Spacing.lg),
              _Issues(count: status.issues, engine: engine, canRetry: canSync),
            ],
            const SizedBox(height: Spacing.xl),
            Text(l10n.syncRestoreHelp, style: theme.textTheme.bodyMedium),
            const SizedBox(height: Spacing.md),
            BigButton(
              label: l10n.syncRestore,
              icon: Icons.cloud_download_outlined,
              style: BigButtonStyle.outlined,
              onPressed: canSync
                  ? () => _confirmRestore(context, engine)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  static IconData _icon(SyncPhase p) => switch (p) {
    SyncPhase.disabled => Icons.cloud_off_outlined,
    SyncPhase.idle => Icons.cloud_done_outlined,
    SyncPhase.syncing => Icons.cloud_sync_outlined,
    SyncPhase.offline => Icons.wifi_off,
    SyncPhase.signedOut => Icons.lock_outline,
    SyncPhase.wrongAccount => Icons.person_off_outlined,
    SyncPhase.error => Icons.error_outline,
  };

  Future<void> _confirmRestore(BuildContext context, SyncEngine engine) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.syncRestoreConfirmTitle),
        content: Text(l10n.syncRestoreConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.syncRestoreAction),
          ),
        ],
      ),
    );
    if (ok ?? false) await engine.restoreFromServer();
  }
}

class _Issues extends ConsumerWidget {
  const new({
    required this.count,
    required this.engine,
    required this.canRetry,
  });

  final int count;
  final SyncEngine? engine;
  final bool canRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final formatter = ref.watch(numberFormatterProvider);
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.syncIssuesTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
            const SizedBox(height: Spacing.xs),
            Text(
              l10n.syncIssuesBody(formatter.digits('$count')),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
            const SizedBox(height: Spacing.md),
            OutlinedButton(
              onPressed: canRetry ? engine!.retryStuck : null,
              child: Text(l10n.syncRetry),
            ),
          ],
        ),
      ),
    );
  }
}

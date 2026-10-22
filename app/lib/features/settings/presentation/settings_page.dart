import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vehicle_khata/app/providers/providers.dart';
import 'package:vehicle_khata/app/ui/tokens.dart';
import 'package:vehicle_khata/app/ui/widgets/khata_list_tile.dart';
import 'package:vehicle_khata/core/money/number_formatter.dart';
import 'package:vehicle_khata/core/settings/app_settings.dart';
import 'package:vehicle_khata/features/app_lock/domain/lock_policy.dart';
import 'package:vehicle_khata/features/app_lock/presentation/app_lock_controller.dart';
import 'package:vehicle_khata/l10n/gen/app_localizations.dart';

class SettingsPage extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: Spacing.xl),
        children: [
          SectionHeader(l10n.language),
          _Segmented<String>(
            value: settings.languageCode,
            onChanged: notifier.setLanguage,
            options: {'bn': l10n.languageBangla, 'en': l10n.languageEnglish},
          ),
          SectionHeader(l10n.numerals),
          _Segmented<NumeralStyle>(
            value: settings.numerals,
            onChanged: notifier.setNumerals,
            options: {
              NumeralStyle.bangla: l10n.numeralsBangla,
              NumeralStyle.latin: l10n.numeralsLatin,
            },
          ),
          SectionHeader(l10n.grouping),
          _Segmented<GroupingStyle>(
            value: settings.grouping,
            onChanged: notifier.setGrouping,
            options: {
              GroupingStyle.southAsian: l10n.groupingSouthAsian,
              GroupingStyle.international: l10n.groupingInternational,
            },
          ),
          SectionHeader(l10n.profitView),
          _Segmented<ProfitView>(
            value: settings.profitView,
            onChanged: notifier.setProfitView,
            options: {
              ProfitView.cash: l10n.profitCash,
              ProfitView.accrual: l10n.profitAccrual,
            },
          ),
          SectionHeader(l10n.security),
          const _SecuritySection(),
        ],
      ),
    );
  }
}

class _Segmented<T> extends StatelessWidget {
  const new({
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final T value;
  final Map<T, String> options;
  final Future<void> Function(T) onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.gutter),
      child: SegmentedButton<T>(
        showSelectedIcon: false,
        segments: [
          for (final e in options.entries)
            ButtonSegment(value: e.key, label: Text(e.value)),
        ],
        selected: {value},
        onSelectionChanged: (s) => onChanged(s.first),
      ),
    );
  }
}

final _biometricAvailableProvider = FutureProvider<bool>(
  (ref) => ref.watch(biometricAuthProvider).isAvailable(),
);

class _SecuritySection extends ConsumerWidget {
  const new();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final lock = ref.watch(appLockProvider);
    final controller = ref.read(appLockProvider.notifier);
    final biometricAvailable =
        ref.watch(_biometricAvailableProvider).value ?? false;

    if (!lock.enabled) {
      return ListTile(
        minTileHeight: 64,
        leading: const Icon(Icons.lock_outline),
        title: Text(l10n.appLock),
        subtitle: Text(l10n.appLockOff),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push('/pin/enable'),
      );
    }

    String timeoutLabel(LockTimeout t) => switch (t) {
      LockTimeout.immediately => l10n.timeoutImmediately,
      LockTimeout.seconds30 => l10n.timeout30,
      LockTimeout.minute1 => l10n.timeout1m,
      LockTimeout.minutes5 => l10n.timeout5m,
    };

    return Column(
      children: [
        ListTile(
          minTileHeight: 64,
          leading: const Icon(Icons.lock),
          title: Text(l10n.appLock),
          subtitle: Text(l10n.appLockOn),
        ),
        SwitchListTile(
          secondary: const Icon(Icons.fingerprint),
          title: Text(l10n.useBiometric),
          subtitle: biometricAvailable ? null : Text(l10n.biometricUnavailable),
          value: lock.biometricEnabled,
          onChanged: biometricAvailable
              ? (on) async {
                  if (on) {
                    final ok = await ref
                        .read(biometricAuthProvider)
                        .authenticate(l10n.biometricReason);
                    if (!ok) return;
                  }
                  await controller.setBiometric(enabled: on);
                }
              : null,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.gutter),
          child: DropdownButtonFormField<LockTimeout>(
            initialValue: lock.timeout,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: l10n.lockTimeout,
              border: const OutlineInputBorder(),
            ),
            items: [
              for (final t in LockTimeout.values)
                DropdownMenuItem(value: t, child: Text(timeoutLabel(t))),
            ],
            onChanged: (t) {
              if (t != null) unawaited(controller.setTimeout(t));
            },
          ),
        ),
        ListTile(
          minTileHeight: 56,
          leading: const Icon(Icons.pin_outlined),
          title: Text(l10n.changePin),
          onTap: () => context.push('/pin/change'),
        ),
        ListTile(
          minTileHeight: 56,
          leading: const Icon(Icons.lock_open_outlined),
          title: Text(l10n.turnOffLock),
          onTap: () => context.push('/pin/disable'),
        ),
      ],
    );
  }
}

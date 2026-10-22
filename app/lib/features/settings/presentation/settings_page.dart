import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vehicle_khata/app/providers/providers.dart';
import 'package:vehicle_khata/app/ui/tokens.dart';
import 'package:vehicle_khata/app/ui/widgets/khata_list_tile.dart';
import 'package:vehicle_khata/core/money/number_formatter.dart';
import 'package:vehicle_khata/core/settings/app_settings.dart';
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

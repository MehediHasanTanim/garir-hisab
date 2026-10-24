import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vehicle_khata/app/providers/feature_providers.dart';
import 'package:vehicle_khata/app/ui/tokens.dart';
import 'package:vehicle_khata/app/ui/widgets/big_button.dart';
import 'package:vehicle_khata/l10n/gen/app_localizations.dart';

/// More → Export my data: one zip with everything, to keep or open in Excel.
class ExportPage extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<ExportPage> createState() => _ExportPageState();
}

class _ExportPageState extends ConsumerState<ExportPage> {
  bool _busy = false;
  bool _failed = false;

  Future<void> _export() async {
    setState(() {
      _busy = true;
      _failed = false;
    });
    try {
      final bytes = await ref.read(dataExportServiceProvider).build();
      final now = DateTime.now();
      String two(int n) => n.toString().padLeft(2, '0');
      await ref
          .read(fileSharerProvider)
          .shareBytes(
            bytes: bytes,
            fileName:
                'khata-export-${now.year}${two(now.month)}${two(now.day)}.zip',
            mimeType: 'application/zip',
          );
    } on Object {
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.exportTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(Spacing.gutter),
          children: [
            Text(l10n.exportExplain, style: theme.textTheme.bodyLarge),
            const SizedBox(height: Spacing.md),
            Text(l10n.exportNidNote, style: theme.textTheme.bodyMedium),
            const SizedBox(height: Spacing.lg),
            BigButton(
              label: _busy ? l10n.exportPreparing : l10n.exportAction,
              icon: Icons.ios_share,
              onPressed: _busy ? null : _export,
            ),
            if (_failed) ...[
              const SizedBox(height: Spacing.md),
              Text(
                l10n.exportFailed,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

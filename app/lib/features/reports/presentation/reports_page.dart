import 'package:flutter/material.dart';
import 'package:vehicle_khata/app/ui/widgets/empty_state.dart';
import 'package:vehicle_khata/l10n/gen/app_localizations.dart';

class ReportsPage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navReports)),
      body: EmptyState(
        icon: Icons.bar_chart_outlined,
        title: l10n.reportsEmptyTitle,
        message: l10n.reportsEmptyMessage,
      ),
    );
  }
}

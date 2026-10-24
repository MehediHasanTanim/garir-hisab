import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vehicle_khata/app/providers/feature_providers.dart';
import 'package:vehicle_khata/app/providers/providers.dart';
import 'package:vehicle_khata/app/ui/tokens.dart';
import 'package:vehicle_khata/app/ui/widgets/big_button.dart';
import 'package:vehicle_khata/core/time/calendar_day.dart';
import 'package:vehicle_khata/features/app_lock/presentation/app_lock_controller.dart';
import 'package:vehicle_khata/features/statement/data/driver_statement.dart';
import 'package:vehicle_khata/features/statement/data/statement_pdf.dart';
import 'package:vehicle_khata/features/statement/presentation/statement_view.dart';
import 'package:vehicle_khata/l10n/gen/app_localizations.dart';

enum _Preset { thisMonth, lastMonth, last3, all }

/// Driver → Statement: pick a period, preview, share as a PDF (WhatsApp...).
class StatementPage extends ConsumerStatefulWidget {
  const new({required this.driverId, super.key});

  final String driverId;

  @override
  ConsumerState<StatementPage> createState() => _StatementPageState();
}

class _StatementPageState extends ConsumerState<StatementPage> {
  final _boundary = GlobalKey();
  _Preset _preset = _Preset.thisMonth;
  DriverStatement? _statement;
  bool _busy = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  DayRange? _range() {
    final today = ref.read(todayProvider);
    return switch (_preset) {
      _Preset.thisMonth => DayRange(today.firstOfMonth, today.lastOfMonth),
      _Preset.lastMonth => () {
        final last = today.firstOfMonth.addDays(-1);
        return DayRange(last.firstOfMonth, last);
      }(),
      _Preset.last3 => DayRange(
        CalendarDay.of(today.year, today.month - 2, 1),
        today.lastOfMonth,
      ),
      _Preset.all => null,
    };
  }

  Future<void> _load() async {
    final s = await ref
        .read(statementServiceProvider)
        .build(widget.driverId, _range());
    if (mounted) setState(() => _statement = s);
  }

  Future<void> _share() async {
    final s = _statement;
    if (s == null) return;
    final l10n = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _failed = false;
    });
    try {
      final boundary =
          _boundary.currentContext!.findRenderObject()!
              as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      final pdf = await imageToPdf(
        png: data!.buffer.asUint8List(),
        widthPx: image.width,
        heightPx: image.height,
        title: l10n.stmtShareText(s.driverName),
      );
      await ref
          .read(fileSharerProvider)
          .shareBytes(
            bytes: pdf,
            fileName:
                'statement-${CalendarDay.today(ref.read(clockProvider)).toIso()}.pdf',
            mimeType: 'application/pdf',
            text: l10n.stmtShareText(s.driverName),
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
    final formatter = ref.watch(numberFormatterProvider);
    final labels = {
      _Preset.thisMonth: l10n.stmtThisMonth,
      _Preset.lastMonth: l10n.stmtLastMonth,
      _Preset.last3: l10n.stmtLast3,
      _Preset.all: l10n.stmtAllTime,
    };
    return Scaffold(
      appBar: AppBar(title: Text(l10n.stmtTitle)),
      body: SafeArea(
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.gutter,
                vertical: Spacing.sm,
              ),
              child: Row(
                children: [
                  for (final e in labels.entries)
                    Padding(
                      padding: const EdgeInsets.only(right: Spacing.sm),
                      child: ChoiceChip(
                        label: Text(e.value),
                        selected: _preset == e.key,
                        onSelected: (_) {
                          setState(() => _preset = e.key);
                          unawaited(_load());
                        },
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: _statement == null
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(Spacing.gutter),
                      child: Center(
                        child: RepaintBoundary(
                          key: _boundary,
                          child: StatementView(
                            statement: _statement!,
                            formatter: formatter,
                          ),
                        ),
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(Spacing.gutter),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_failed)
                    Padding(
                      padding: const EdgeInsets.only(bottom: Spacing.sm),
                      child: Text(
                        l10n.stmtFailed,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  BigButton(
                    label: _busy ? l10n.stmtPreparing : l10n.stmtShare,
                    icon: Icons.picture_as_pdf_outlined,
                    onPressed: _busy || _statement == null ? null : _share,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

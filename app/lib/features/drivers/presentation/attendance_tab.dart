import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vehicle_khata/app/l10n_labels.dart';
import 'package:vehicle_khata/app/providers/feature_providers.dart';
import 'package:vehicle_khata/app/providers/providers.dart';
import 'package:vehicle_khata/app/ui/format.dart';
import 'package:vehicle_khata/app/ui/tokens.dart';
import 'package:vehicle_khata/core/time/calendar_day.dart';
import 'package:vehicle_khata/features/app_lock/presentation/app_lock_controller.dart';
import 'package:vehicle_khata/features/drivers/domain/attendance.dart';
import 'package:vehicle_khata/l10n/gen/app_localizations.dart';

/// Month calendar for marking a driver present / absent / half day.
class AttendanceTab extends ConsumerStatefulWidget {
  const new({required this.driverId, super.key});

  final String driverId;

  @override
  ConsumerState<AttendanceTab> createState() => _AttendanceTabState();
}

class _AttendanceTabState extends ConsumerState<AttendanceTab> {
  /// Bangladesh's week starts on Saturday.
  static const _weekOrder = [6, 7, 1, 2, 3, 4, 5];

  late int _year;
  late int _month;

  @override
  void initState() {
    super.initState();
    final today = CalendarDay.today(ref.read(clockProvider));
    _year = today.year;
    _month = today.month;
  }

  void _shift(int delta) {
    final first = CalendarDay.of(_year, _month + delta, 1);
    setState(() {
      _year = first.year;
      _month = first.month;
    });
  }

  Future<void> _markDay(CalendarDay day, AttendanceStatus? current) async {
    final l10n = AppLocalizations.of(context);
    final formatter = ref.read(numberFormatterProvider);
    final choice = await showModalBottomSheet<_Choice>(
      context: context,
      useRootNavigator: true,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(Spacing.md),
              child: Text(
                l10n.markDay(formatDay(formatter, day)),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            for (final s in AttendanceStatus.values)
              ListTile(
                minTileHeight: 56,
                leading: Icon(
                  s == current
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                ),
                title: Text(l10n.attendanceName(s)),
                onTap: () => Navigator.pop(context, _Choice(s)),
              ),
            if (current != null)
              ListTile(
                minTileHeight: 56,
                leading: const Icon(Icons.clear),
                title: Text(l10n.attClear),
                onTap: () => Navigator.pop(context, const _Choice(null)),
              ),
          ],
        ),
      ),
    );
    if (choice == null) return;
    await ref
        .read(attendanceRepositoryProvider)
        .mark(widget.driverId, day, choice.status);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final formatter = ref.watch(numberFormatterProvider);
    final today = CalendarDay.today(ref.watch(clockProvider));
    final marks =
        ref
            .watch(
              attendanceMonthProvider((
                driverId: widget.driverId,
                year: _year,
                month: _month,
              )),
            )
            .value ??
        const {};

    final first = CalendarDay.of(_year, _month, 1);
    final leading = _weekOrder.indexOf(first.weekday);
    final cells = <CalendarDay?>[
      for (var i = 0; i < leading; i++) null,
      ...DayRange.month(_year, _month).days,
    ];
    while (cells.length % 7 != 0) {
      cells.add(null);
    }

    int count(AttendanceStatus s) => marks.values.where((v) => v == s).length;
    final unmarked = first.daysInMonth - marks.length;

    Color background(AttendanceStatus? s) => switch (s) {
      AttendanceStatus.present => theme.colorScheme.primaryContainer,
      AttendanceStatus.absent => theme.colorScheme.errorContainer,
      AttendanceStatus.halfDay => theme.colorScheme.tertiaryContainer,
      null => theme.colorScheme.surfaceContainerHighest,
    };

    return ListView(
      padding: const EdgeInsets.all(Spacing.gutter),
      children: [
        Row(
          children: [
            IconButton(
              tooltip: l10n.prevMonth,
              icon: const Icon(Icons.chevron_left),
              onPressed: () => _shift(-1),
            ),
            Expanded(
              child: Text(
                '${monthName(l10n, _month)} ${formatter.digits('$_year')}',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
            ),
            IconButton(
              tooltip: l10n.nextMonth,
              icon: const Icon(Icons.chevron_right),
              onPressed: () => _shift(1),
            ),
          ],
        ),
        const SizedBox(height: Spacing.sm),
        Row(
          children: [
            for (final wd in _weekOrder)
              Expanded(
                child: Text(
                  weekdayShort(l10n, wd),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall,
                ),
              ),
          ],
        ),
        const SizedBox(height: Spacing.xs),
        for (var w = 0; w < cells.length ~/ 7; w++)
          Row(
            children: [
              for (var i = 0; i < 7; i++)
                Expanded(
                  child: _cell(cells[w * 7 + i], marks, today, background),
                ),
            ],
          ),
        const SizedBox(height: Spacing.md),
        Wrap(
          spacing: Spacing.sm,
          runSpacing: Spacing.sm,
          children: [
            _SummaryChip(
              label: l10n.attPresent,
              value: formatter.digits('${count(AttendanceStatus.present)}'),
              color: background(AttendanceStatus.present),
            ),
            _SummaryChip(
              label: l10n.attHalfDay,
              value: formatter.digits('${count(AttendanceStatus.halfDay)}'),
              color: background(AttendanceStatus.halfDay),
            ),
            _SummaryChip(
              label: l10n.attAbsent,
              value: formatter.digits('${count(AttendanceStatus.absent)}'),
              color: background(AttendanceStatus.absent),
            ),
            _SummaryChip(
              label: l10n.attUnmarked,
              value: formatter.digits('$unmarked'),
              color: background(null),
            ),
          ],
        ),
      ],
    );
  }

  Widget _cell(
    CalendarDay? day,
    Map<CalendarDay, AttendanceStatus> marks,
    CalendarDay today,
    Color Function(AttendanceStatus?) background,
  ) {
    if (day == null) return const SizedBox(height: 52);
    final status = marks[day];
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final f = ref.read(numberFormatterProvider);
    return Padding(
      padding: const EdgeInsets.all(2),
      child: Semantics(
        button: true,
        label:
            '${formatDay(f, day)}: ${status == null ? l10n.attUnmarked : l10n.attendanceName(status)}',
        excludeSemantics: true,
        child: Material(
          color: background(status),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: day == today
                ? BorderSide(color: theme.colorScheme.primary, width: 2)
                : BorderSide.none,
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => _markDay(day, status),
            child: SizedBox(
              height: 48,
              child: Center(child: Text(f.digits('${day.day}'))),
            ),
          ),
        ),
      ),
    );
  }
}

class _Choice {
  const new(this.status);

  final AttendanceStatus? status;
}

class _SummaryChip extends StatelessWidget {
  const new({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final text = '$label: $value';
    return Chip(
      backgroundColor: color,
      side: BorderSide.none,
      label: Text(text),
    );
  }
}

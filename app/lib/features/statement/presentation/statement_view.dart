import 'package:flutter/material.dart';
import 'package:vehicle_khata/core/money/money.dart';
import 'package:vehicle_khata/core/money/number_formatter.dart';
import 'package:vehicle_khata/core/time/calendar_day.dart';
import 'package:vehicle_khata/features/statement/data/driver_statement.dart';
import 'package:vehicle_khata/l10n/gen/app_localizations.dart';

/// The statement as a fixed-width, black-on-white page. It is both the
/// on-screen preview and what is turned into the PDF, so what you see is what
/// you share.
class StatementView extends StatelessWidget {
  const new({required this.statement, required this.formatter, super.key});

  /// Logical width; the PDF scales this to the A4 width.
  static const width = 360.0;

  final DriverStatement statement;
  final NumberFormatter formatter;

  String _day(CalendarDay d) => formatter.digits(
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}',
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    const ink = Color(0xFF111111);
    const soft = Color(0xFF555555);
    const base = TextStyle(color: ink, fontSize: 13, height: 1.35);
    final bold = base.copyWith(fontWeight: FontWeight.w700);
    final small = base.copyWith(color: soft, fontSize: 11.5);

    Widget row(String label, String value, {TextStyle? style}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label, style: style ?? base)),
          const SizedBox(width: 8),
          Text(value, style: style ?? base),
        ],
      ),
    );

    Widget heading(String text) => Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 4),
      child: Text(text, style: bold.copyWith(fontSize: 14)),
    );

    final s = statement;
    final period = s.range == null
        ? l10n.stmtAllTime
        : l10n.stmtPeriodLine(_day(s.range!.start), _day(s.range!.end));

    return Container(
      width: width,
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: DefaultTextStyle(
        style: base,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.stmtTitle, style: bold.copyWith(fontSize: 18)),
            const SizedBox(height: 6),
            Text(s.driverName, style: bold.copyWith(fontSize: 16)),
            if (s.phone != null && s.phone!.isNotEmpty)
              Text(formatter.digits(s.phone!), style: small),
            Text(period, style: small),
            const Divider(height: 24, color: Color(0xFFBBBBBB)),
            if (s.isEmpty)
              Text(l10n.stmtNone, style: base)
            else ...[
              if (s.payouts.isNotEmpty) ...[
                heading(l10n.stmtPayouts),
                for (final p in s.payouts) ...[
                  Text(
                    l10n.stmtPeriodLine(
                      _day(p.period.start),
                      _day(p.period.end),
                    ),
                    style: bold,
                  ),
                  row(l10n.stmtEarned, formatter.money(p.earned)),
                  if (!p.adjustment.isZero)
                    row(l10n.stmtAdjustment, formatter.money(p.adjustment)),
                  if (!p.deducted.isZero)
                    row(l10n.stmtRecovered, '− ${formatter.money(p.deducted)}'),
                  row(l10n.stmtPaid, formatter.money(p.net), style: bold),
                  Text(
                    l10n.stmtPaidOn(
                      _day(CalendarDay.fromDate(p.paidAt.toLocal())),
                    ),
                    style: small,
                  ),
                  const SizedBox(height: 8),
                ],
              ],
              if (s.advances.isNotEmpty) ...[
                heading(l10n.stmtAdvances),
                for (final a in s.advances) ...[
                  row(_day(a.givenOn), formatter.money(a.amount)),
                  if (a.remaining.isPositive)
                    Text(
                      l10n.stmtRemaining(formatter.money(a.remaining)),
                      style: small,
                    ),
                  if (a.note != null && a.note!.isNotEmpty)
                    Text(a.note!, style: small),
                ],
              ],
              const Divider(height: 24, color: Color(0xFFBBBBBB)),
              row(
                l10n.stmtTotalPaid,
                formatter.money(s.totalPaid),
                style: bold,
              ),
              row(l10n.stmtAdvances, formatter.money(s.totalAdvancesGiven)),
              row(
                l10n.stmtAdvancesOwed,
                formatter.money(s.advancesOwed),
                style: bold,
              ),
            ],
            const SizedBox(height: 20),
            Text(l10n.stmtPreparedWith, style: small),
          ],
        ),
      ),
    );
  }
}

/// Used by tests and the page to know what money text a statement shows.
String statementMoney(NumberFormatter f, Money m) => f.money(m);

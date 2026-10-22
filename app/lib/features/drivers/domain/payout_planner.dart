import 'package:meta/meta.dart';
import 'package:vehicle_khata/core/money/money.dart';
import 'package:vehicle_khata/core/time/calendar_day.dart';

@immutable
class OutstandingAdvance {
  const new({required this.id, required this.givenOn, required this.remaining});

  final String id;
  final CalendarDay givenOn;
  final Money remaining;
}

@immutable
class AdvanceDeduction {
  const new(this.advanceId, this.amount);

  final String advanceId;
  final Money amount;
}

@immutable
class PayoutPlan {
  const new({
    required this.earned,
    required this.adjustment,
    required this.deductions,
    required this.net,
    required this.advancesCarriedOver,
  });

  final Money earned;

  /// Bonus (+) or penalty (−) entered by the owner.
  final Money adjustment;
  final List<AdvanceDeduction> deductions;
  final Money net;

  /// Advance balance still owed after this payout.
  final Money advancesCarriedOver;

  Money get gross => earned + adjustment;
  Money get deducted => deductions.map((d) => d.amount).sum();
}

/// Works out what a payout pays out: `net = earned + adjustment − advances`.
///
/// Advances are recovered oldest first, partially if needed, but never beyond
/// what the driver is owed — the net is never negative and any advance left
/// over carries to the next payout.
PayoutPlan planPayout({
  required Money earned,
  required Iterable<OutstandingAdvance> advances,
  Money adjustment = Money.zero,
}) {
  final gross = earned + adjustment;
  var available = gross.isPositive ? gross : Money.zero;

  final ordered = advances.where((a) => a.remaining.isPositive).toList()
    ..sort((a, b) {
      final byDate = a.givenOn.compareTo(b.givenOn);
      return byDate != 0 ? byDate : a.id.compareTo(b.id);
    });

  final deductions = <AdvanceDeduction>[];
  for (final advance in ordered) {
    if (!available.isPositive) break;
    final take = advance.remaining < available ? advance.remaining : available;
    deductions.add(AdvanceDeduction(advance.id, take));
    available -= take;
  }

  final totalRemaining = ordered.map((a) => a.remaining).sum();
  final deducted = deductions.map((d) => d.amount).sum();
  return PayoutPlan(
    earned: earned,
    adjustment: adjustment,
    deductions: deductions,
    net: available,
    advancesCarriedOver: totalRemaining - deducted,
  );
}

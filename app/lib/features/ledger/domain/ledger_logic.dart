import 'package:meta/meta.dart';
import 'package:vehicle_khata/core/money/money.dart';
import 'package:vehicle_khata/core/time/calendar_day.dart';

enum PartyType { driver, customer }

enum RefType { jama, advance, trip, expense }

/// Who a debt is with. Unnamed customers share the empty id.
@immutable
class Party {
  const new(this.type, [this.id = '']);

  final PartyType type;
  final String id;

  String get key => '${type.name}:$id';

  @override
  bool operator ==(Object other) =>
      other is Party && other.type == type && other.id == id;

  @override
  int get hashCode => Object.hash(type, id);
}

/// One source record that is still owed (either way), after everything that
/// has been paid against it.
@immutable
class OpenItem {
  const new({
    required this.party,
    required this.refType,
    required this.refId,
    required this.day,
    required this.amount,
  });

  final Party party;
  final RefType refType;
  final String refId;

  /// The day the debt arose.
  final CalendarDay day;

  /// Positive: the party owes the owner. Negative: the owner owes the party.
  final Money amount;

  bool get isReceivable => amount.isPositive;
}

enum AgeBucket { days0to7, days8to30, over30 }

/// Age of a debt as of [today]: 0-7, 8-30, or over 30 days.
AgeBucket ageBucket(CalendarDay day, CalendarDay today) {
  final age = day.daysUntil(today);
  if (age <= 7) return AgeBucket.days0to7;
  if (age <= 30) return AgeBucket.days8to30;
  return AgeBucket.over30;
}

@immutable
class Aging {
  const new({
    this.days0to7 = Money.zero,
    this.days8to30 = Money.zero,
    this.over30 = Money.zero,
  });

  factory fromItems(Iterable<OpenItem> items, CalendarDay today) {
    var a = Money.zero;
    var b = Money.zero;
    var c = Money.zero;
    for (final i in items) {
      final m = i.amount.abs();
      switch (ageBucket(i.day, today)) {
        case AgeBucket.days0to7:
          a += m;
        case AgeBucket.days8to30:
          b += m;
        case AgeBucket.over30:
          c += m;
      }
    }
    return Aging(days0to7: a, days8to30: b, over30: c);
  }

  final Money days0to7;
  final Money days8to30;
  final Money over30;

  Money get total => days0to7 + days8to30 + over30;

  Money of(AgeBucket b) => switch (b) {
    AgeBucket.days0to7 => days0to7,
    AgeBucket.days8to30 => days8to30,
    AgeBucket.over30 => over30,
  };
}

/// How a posting changes a ref's balance: from [posted] to [desired].
/// Returns the delta and its kind, or null when nothing changed.
({int delta, String kind})? postingFor({
  required int posted,
  required int desired,
  required int existingRows,
}) {
  if (posted == desired) return null;
  final kind = existingRows == 0
      ? 'accrual'
      : desired == 0
      ? 'reversal'
      : 'adjust';
  return (delta: desired - posted, kind: kind);
}

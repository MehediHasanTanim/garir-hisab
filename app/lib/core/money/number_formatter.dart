import 'package:vehicle_khata/core/money/money.dart';

enum NumeralStyle { latin, bangla }

enum GroupingStyle {
  /// 1,23,456 (lakh/crore).
  southAsian,

  /// 123,456.
  international,
}

/// The single place where numbers and money become display strings.
class NumberFormatter {
  const new({
    this.numerals = NumeralStyle.bangla,
    this.grouping = GroupingStyle.southAsian,
  });

  static const _banglaDigits = '০১২৩৪৫৬৭৮৯';
  static const takaSymbol = '৳';

  final NumeralStyle numerals;
  final GroupingStyle grouping;

  /// "৳ 1,23,456" or "৳ 1,234.50". Poisha are shown only when non-zero.
  String money(Money value, {bool symbol = true}) {
    final abs = value.minor.abs();
    final taka = abs ~/ 100;
    final poisha = abs % 100;
    final body = StringBuffer(_group(taka));
    if (poisha != 0) {
      body
        ..write('.')
        ..write(poisha.toString().padLeft(2, '0'));
    }
    final sign = value.isNegative ? '-' : '';
    final text = _digits(body.toString());
    return symbol ? '$sign$takaSymbol $text' : '$sign$text';
  }

  /// A plain grouped integer, e.g. a count of trips or kilometres.
  String integer(int value) {
    final sign = value < 0 ? '-' : '';
    return sign + _digits(_group(value.abs()));
  }

  /// Converts Latin digits in [text] to the configured numeral style.
  String digits(String text) => _digits(text);

  String _digits(String text) {
    if (numerals == NumeralStyle.latin) return text;
    final out = StringBuffer();
    for (final unit in text.codeUnits) {
      final d = unit - 0x30;
      out.write(
        d >= 0 && d <= 9 ? _banglaDigits[d] : String.fromCharCode(unit),
      );
    }
    return out.toString();
  }

  String _group(int value) {
    final s = value.toString();
    if (s.length <= 3) return s;
    final head = s.substring(0, s.length - 3);
    final tail = s.substring(s.length - 3);
    final size = grouping == GroupingStyle.southAsian ? 2 : 3;
    final parts = <String>[];
    for (var end = head.length; end > 0; end -= size) {
      final start = end - size < 0 ? 0 : end - size;
      parts.insert(0, head.substring(start, end));
    }
    return '${parts.join(',')},$tail';
  }
}

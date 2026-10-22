import 'package:vehicle_khata/core/money/money.dart';

/// Parses user-typed amounts. Accepts Bangla digits, thousands separators
/// (`,`), spaces and a leading ৳.
abstract final class MoneyParser {
  static const _bangla = '০১২৩৪৫৬৭৮৯';

  static String _latin(String input) {
    final out = StringBuffer();
    for (final rune in input.runes) {
      final ch = String.fromCharCode(rune);
      final i = _bangla.indexOf(ch);
      out.write(i >= 0 ? '$i' : ch);
    }
    return out.toString();
  }

  static String _clean(String input) =>
      _latin(input).replaceAll(RegExp(r'[\s,৳]'), '');

  /// "1,500", "১৫০০", "99.5" -> Money. Returns null for anything else
  /// (empty, negative, more than 2 decimals, letters).
  static Money? parseTaka(String input) {
    final text = _clean(input);
    final match = RegExp(r'^(\d{1,12})(?:\.(\d{1,2}))?$').firstMatch(text);
    if (match == null) return null;
    final taka = int.parse(match.group(1)!);
    final poisha = int.parse((match.group(2) ?? '0').padRight(2, '0'));
    return Money(taka * 100 + poisha);
  }

  /// Like [parseTaka] but allows a leading `-` or `−` (a penalty). Blank means
  /// zero.
  static Money? parseSignedTaka(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return Money.zero;
    final negative = trimmed.startsWith('-') || trimmed.startsWith('−');
    final unsigned = negative || trimmed.startsWith('+')
        ? trimmed.substring(1)
        : trimmed;
    final value = parseTaka(unsigned);
    if (value == null) return null;
    return negative ? -value : value;
  }

  /// A percentage such as "12.5" -> 1250 basis points. 0..100 only, at most
  /// 2 decimals.
  static int? parsePercentToBasisPoints(String input) {
    final text = _clean(input).replaceAll('%', '');
    final match = RegExp(r'^(\d{1,3})(?:\.(\d{1,2}))?$').firstMatch(text);
    if (match == null) return null;
    final whole = int.parse(match.group(1)!);
    final frac = int.parse((match.group(2) ?? '0').padRight(2, '0'));
    final bps = whole * 100 + frac;
    return bps > Money.basisPointsPerWhole ? null : bps;
  }

  /// 1250 -> "12.5", 2000 -> "20".
  static String formatBasisPoints(int bps) {
    final whole = bps ~/ 100;
    final frac = bps % 100;
    if (frac == 0) return '$whole';
    final f = frac.toString().padLeft(2, '0').replaceFirst(RegExp(r'0$'), '');
    return '$whole.$f';
  }

  /// Plain taka text for editing: 150000 poisha -> "1500", 150050 -> "1500.5".
  static String formatForEdit(Money m) {
    final taka = m.minor ~/ 100;
    final poisha = m.minor.abs() % 100;
    if (poisha == 0) return '$taka';
    final f = poisha.toString().padLeft(2, '0').replaceFirst(RegExp(r'0$'), '');
    return '$taka.$f';
  }
}

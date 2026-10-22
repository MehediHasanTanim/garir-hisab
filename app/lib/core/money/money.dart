import 'package:meta/meta.dart';

/// An amount of money stored as an integer number of poisha (1 ৳ = 100).
///
/// All arithmetic is integer-only; there are no floating-point values in
/// persistence or calculations.
@immutable
class Money implements Comparable<Money> {
  const new(this.minor);

  /// Whole taka.
  const new taka(int taka) : minor = taka * 100;

  static const zero = Money(0);

  /// Basis points in 100%.
  static const basisPointsPerWhole = 10000;

  final int minor;

  bool get isZero => minor == 0;
  bool get isNegative => minor < 0;
  bool get isPositive => minor > 0;

  Money operator +(Money other) => Money(minor + other.minor);
  Money operator -(Money other) => Money(minor - other.minor);
  Money operator -() => Money(-minor);
  Money operator *(int factor) => Money(minor * factor);

  bool operator <(Money other) => minor < other.minor;
  bool operator <=(Money other) => minor <= other.minor;
  bool operator >(Money other) => minor > other.minor;
  bool operator >=(Money other) => minor >= other.minor;

  Money abs() => Money(minor.abs());

  /// [basisPoints] of this amount (2000 = 20%), rounded to the nearest poisha
  /// with ties going to the even poisha (banker's rounding). Negative amounts
  /// round symmetrically.
  Money percentOf(int basisPoints) {
    final numerator = minor.abs() * basisPoints.abs();
    final quotient = numerator ~/ basisPointsPerWhole;
    final remainder = numerator.remainder(basisPointsPerWhole);
    const half = basisPointsPerWhole ~/ 2;
    final roundUp = remainder > half || (remainder == half && quotient.isOdd);
    final magnitude = roundUp ? quotient + 1 : quotient;
    final negative = (minor < 0) != (basisPoints < 0);
    return Money(negative ? -magnitude : magnitude);
  }

  /// Splits this amount into [parts] shares that sum exactly to the total.
  /// Any leftover poisha go one each to the first shares.
  List<Money> split(int parts) {
    if (parts <= 0) throw ArgumentError.value(parts, 'parts', 'must be > 0');
    final base = minor ~/ parts;
    final extra = minor.remainder(parts);
    final step = extra.isNegative ? -1 : 1;
    return [
      for (var i = 0; i < parts; i++)
        Money(base + (i < extra.abs() ? step : 0)),
    ];
  }

  @override
  int compareTo(Money other) => minor.compareTo(other.minor);

  @override
  bool operator ==(Object other) => other is Money && other.minor == minor;

  @override
  int get hashCode => minor.hashCode;

  @override
  String toString() => 'Money($minor)';
}

extension MoneySum on Iterable<Money> {
  Money sum() => fold(Money.zero, (a, b) => a + b);
}

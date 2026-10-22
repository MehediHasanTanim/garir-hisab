import 'package:flutter_test/flutter_test.dart';
import 'package:vehicle_khata/core/money/money.dart';
import 'package:vehicle_khata/core/money/number_formatter.dart';

void main() {
  const latinSa = NumberFormatter(numerals: NumeralStyle.latin);
  const banglaSa = NumberFormatter();
  const latinIntl = NumberFormatter(
    numerals: NumeralStyle.latin,
    grouping: GroupingStyle.international,
  );

  test('lakh/crore grouping', () {
    expect(latinSa.money(const Money.taka(123456)), '৳ 1,23,456');
    expect(latinSa.money(const Money.taka(12345678)), '৳ 1,23,45,678');
    expect(latinSa.money(const Money.taka(999)), '৳ 999');
    expect(latinSa.money(const Money.taka(1000)), '৳ 1,000');
    expect(latinSa.money(const Money.taka(100000)), '৳ 1,00,000');
  });

  test('international grouping', () {
    expect(latinIntl.money(const Money.taka(123456)), '৳ 123,456');
    expect(latinIntl.money(const Money.taka(1234567)), '৳ 1,234,567');
  });

  test('Bangla numerals', () {
    expect(banglaSa.money(const Money.taka(123456)), '৳ ১,২৩,৪৫৬');
    expect(banglaSa.money(const Money.taka(2800)), '৳ ২,৮০০');
    expect(banglaSa.integer(0), '০');
  });

  test('poisha shown only when non-zero', () {
    expect(latinSa.money(const Money(123450)), '৳ 1,234.50');
    expect(latinSa.money(const Money(5)), '৳ 0.05');
    expect(banglaSa.money(const Money(10050)), '৳ ১০০.৫০');
  });

  test('negatives and symbol-less output', () {
    expect(latinSa.money(const Money(-250000)), '-৳ 2,500');
    expect(latinSa.money(const Money.taka(2800), symbol: false), '2,800');
  });

  test('digits() converts only digits', () {
    expect(banglaSa.digits('12 km'), '১২ km');
  });
}

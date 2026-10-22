import 'package:flutter_test/flutter_test.dart';
import 'package:vehicle_khata/core/money/money.dart';
import 'package:vehicle_khata/core/money/money_parser.dart';

void main() {
  group('parseTaka', () {
    test('accepts plain, grouped, Bangla and decimal input', () {
      expect(MoneyParser.parseTaka('1500'), const Money.taka(1500));
      expect(MoneyParser.parseTaka('1,500'), const Money.taka(1500));
      expect(MoneyParser.parseTaka(' ৳ 1,23,456 '), const Money.taka(123456));
      expect(MoneyParser.parseTaka('১৫০০'), const Money.taka(1500));
      expect(MoneyParser.parseTaka('99.5'), const Money(9950));
      expect(MoneyParser.parseTaka('99.05'), const Money(9905));
      expect(MoneyParser.parseTaka('0'), Money.zero);
    });

    test('rejects invalid input', () {
      for (final bad in [
        '',
        ' ',
        '-5',
        'abc',
        '12.345',
        '1.',
        '.5',
        '1e3',
        '12 34x',
      ]) {
        expect(MoneyParser.parseTaka(bad), isNull, reason: bad);
      }
    });
  });

  group('percent to basis points', () {
    test('parses whole and fractional percentages', () {
      expect(MoneyParser.parsePercentToBasisPoints('20'), 2000);
      expect(MoneyParser.parsePercentToBasisPoints('12.5'), 1250);
      expect(MoneyParser.parsePercentToBasisPoints('12.05%'), 1205);
      expect(MoneyParser.parsePercentToBasisPoints('১০০'), 10000);
      expect(MoneyParser.parsePercentToBasisPoints('0'), 0);
    });

    test('rejects over 100% and junk', () {
      for (final bad in ['100.01', '101', '-1', 'x', '', '1.234']) {
        expect(MoneyParser.parsePercentToBasisPoints(bad), isNull, reason: bad);
      }
    });

    test('format is the inverse', () {
      for (final bps in [0, 1, 5, 50, 100, 1250, 1205, 2000, 10000]) {
        expect(
          MoneyParser.parsePercentToBasisPoints(
            MoneyParser.formatBasisPoints(bps),
          ),
          bps,
        );
      }
    });
  });

  test('formatForEdit round-trips with parseTaka', () {
    for (final m in [
      Money.zero,
      const Money(150000),
      const Money(150050),
      const Money(5),
      const Money(99),
    ]) {
      expect(MoneyParser.parseTaka(MoneyParser.formatForEdit(m)), m);
    }
  });
}

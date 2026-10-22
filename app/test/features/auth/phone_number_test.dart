import 'package:flutter_test/flutter_test.dart';
import 'package:vehicle_khata/features/auth/domain/phone_number.dart';

void main() {
  group('normalizeBd', () {
    test('accepts the common input forms', () {
      for (final input in [
        '01712345678',
        '+8801712345678',
        '8801712345678',
        '1712345678',
        '01712 345678',
        '01712-345-678',
        ' +880 1712 345678 ',
        '০১৭১২৩৪৫৬৭৮',
      ]) {
        expect(PhoneNumber.normalizeBd(input), '+8801712345678', reason: input);
      }
    });

    test('accepts every mobile operator prefix 013-019', () {
      for (final prefix in ['013', '014', '015', '016', '017', '018', '019']) {
        expect(
          PhoneNumber.normalizeBd('${prefix}12345678'),
          '+880${prefix.substring(1)}12345678',
          reason: prefix,
        );
      }
    });

    test('rejects invalid numbers', () {
      for (final input in [
        '',
        '0171234567', // too short
        '017123456789', // too long
        '01012345678', // 010 is not a mobile prefix
        '01212345678', // 012 is not a mobile prefix
        '02712345678',
        'abcdefghijk',
        '+441712345678',
        '+88017123456',
      ]) {
        expect(PhoneNumber.normalizeBd(input), isNull, reason: input);
      }
    });
  });

  test('formatLocal', () {
    expect(PhoneNumber.formatLocal('+8801712345678'), '01712-345678');
    expect(PhoneNumber.formatLocal('+441712345678'), '+441712345678');
  });
}

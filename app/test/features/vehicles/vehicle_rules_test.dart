import 'package:flutter_test/flutter_test.dart';
import 'package:vehicle_khata/features/vehicles/domain/vehicle_enums.dart';
import 'package:vehicle_khata/features/vehicles/domain/vehicle_rules.dart';

void main() {
  test('nickname validation', () {
    expect(VehicleRules.validateNickname(''), NicknameError.empty);
    expect(VehicleRules.validateNickname('   '), NicknameError.empty);
    expect(VehicleRules.validateNickname('a' * 41), NicknameError.tooLong);
    expect(VehicleRules.validateNickname('a' * 40), isNull);
    expect(VehicleRules.validateNickname('  Rahim  '), isNull);
  });

  test('cleanText trims and collapses whitespace', () {
    expect(VehicleRules.cleanText('  a   b \n c '), 'a b c');
  });

  group('regNoKey', () {
    test('ignores case, spaces, hyphens and punctuation', () {
      expect(
        VehicleRules.regNoKey('Dhaka Metro-HA 12-3456'),
        'dhakametroha123456',
      );
      expect(
        VehicleRules.regNoKey('DHAKA METRO HA 12 3456'),
        VehicleRules.regNoKey('dhaka-metro-ha-12-3456'),
      );
    });

    test('converts Bangla digits', () {
      expect(VehicleRules.regNoKey('ঢাকা ১২-৩৪৫৬'), 'ঢাকা123456');
    });

    test('empty input has no key', () {
      expect(VehicleRules.regNoKey(null), isNull);
      expect(VehicleRules.regNoKey('  - '), isNull);
    });
  });

  test('cleanRegNo', () {
    expect(VehicleRules.cleanRegNo('  DM  12 '), 'DM 12');
    expect(VehicleRules.cleanRegNo('   '), isNull);
  });

  test('year validation', () {
    expect(VehicleRules.isValidYear(null, currentYear: 2026), isTrue);
    expect(VehicleRules.isValidYear(2026, currentYear: 2026), isTrue);
    expect(VehicleRules.isValidYear(2027, currentYear: 2026), isTrue);
    expect(VehicleRules.isValidYear(2028, currentYear: 2026), isFalse);
    expect(VehicleRules.isValidYear(1969, currentYear: 2026), isFalse);
  });

  test('type defaults', () {
    expect(VehicleType.cng.defaultFuel, FuelType.cng);
    expect(VehicleType.cng.defaultModel, BusinessModel.self);
    expect(VehicleType.truck.defaultFuel, FuelType.diesel);
    expect(VehicleType.truck.defaultModel, BusinessModel.contract);
  });
}

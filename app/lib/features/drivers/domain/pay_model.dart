import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:vehicle_khata/core/money/money.dart';
import 'package:vehicle_khata/features/vehicles/domain/vehicle_enums.dart';

enum PayModelType { salary, dailyWage, perTrip, commission, jama, mixed }

/// What a commission is calculated on.
enum CommissionBasis { beforeExpenses, afterExpenses }

enum JamaFrequency { daily, weekly }

enum PayModelField {
  monthly,
  perDay,
  halfDayRate,
  perTrip,
  rate,
  jamaAmount,
  offDays,
}

enum PayModelIssueKind { required, outOfRange }

@immutable
class PayModelIssue {
  const new(this.field, this.kind);

  final PayModelField field;
  final PayModelIssueKind kind;

  @override
  bool operator ==(Object other) =>
      other is PayModelIssue && other.field == field && other.kind == kind;

  @override
  int get hashCode => Object.hash(field, kind);

  @override
  String toString() => 'PayModelIssue($field, $kind)';
}

class PayModelFormatException implements Exception {
  const new(this.message);

  final String message;

  @override
  String toString() => 'PayModelFormatException: $message';
}

/// How a driver is paid (feature spec F6). Persisted as versioned JSON so
/// the shape can evolve without a table migration.
@immutable
sealed class PayModel {
  const new();

  factory decode(String source) {
    final Object? json;
    try {
      json = jsonDecode(source);
    } on FormatException catch (e) {
      throw PayModelFormatException('invalid JSON: ${e.message}');
    }
    if (json is! Map<String, Object?>) {
      throw const PayModelFormatException('expected a JSON object');
    }
    return PayModel.fromJson(json);
  }

  factory fromJson(Map<String, Object?> json) {
    final version = json['v'];
    if (version is! int) {
      throw const PayModelFormatException('missing version');
    }
    if (version > currentVersion) {
      throw PayModelFormatException('unsupported version $version');
    }
    // Upgrade older versions here (none yet).
    final typeName = json['type'];
    final matches = PayModelType.values.where((t) => t.name == typeName);
    if (matches.isEmpty) {
      throw PayModelFormatException('unknown type $typeName');
    }

    Money money(String key) {
      final v = json[key];
      if (v is! int) throw PayModelFormatException('$key must be an integer');
      return Money(v);
    }

    int integer(String key) {
      final v = json[key];
      if (v is! int) throw PayModelFormatException('$key must be an integer');
      return v;
    }

    T enumValue<T extends Enum>(List<T> values, String key) {
      final name = json[key];
      for (final v in values) {
        if (v.name == name) return v;
      }
      throw PayModelFormatException('invalid $key: $name');
    }

    return switch (matches.single) {
      PayModelType.salary => SalaryPay(monthly: money('monthlyMinor')),
      PayModelType.dailyWage => DailyWagePay(
        perDay: money('perDayMinor'),
        halfDayBps: integer('halfDayBps'),
      ),
      PayModelType.perTrip => PerTripPay(perTrip: money('perTripMinor')),
      PayModelType.commission => CommissionPay(
        rateBps: integer('rateBps'),
        basis: enumValue(CommissionBasis.values, 'basis'),
      ),
      PayModelType.jama => JamaPay(
        amount: money('amountMinor'),
        frequency: enumValue(JamaFrequency.values, 'frequency'),
        offWeekdays: {
          for (final d in (json['offWeekdays'] as List<Object?>? ?? const []))
            if (d is int) d,
        },
      ),
      PayModelType.mixed => MixedPay(
        baseMonthly: money('baseMonthlyMinor'),
        rateBps: integer('rateBps'),
        basis: enumValue(CommissionBasis.values, 'basis'),
      ),
    };
  }

  /// Bump when the JSON shape changes and add an upgrade step in
  /// [PayModel.fromJson].
  static const currentVersion = 1;

  PayModelType get type;

  /// Problems that stop this configuration from being saved; empty if valid.
  List<PayModelIssue> validate();

  Map<String, Object?> toJson() => {
    'v': currentVersion,
    'type': type.name,
    ..._fields(),
  };

  Map<String, Object?> _fields();

  String encode() => jsonEncode(toJson());

  @override
  bool operator ==(Object other) =>
      other is PayModel &&
      other.runtimeType == runtimeType &&
      other.encode() == encode();

  @override
  int get hashCode => encode().hashCode;
}

List<PayModelIssue> _positive(Money m, PayModelField f) => [
  if (!m.isPositive) PayModelIssue(f, PayModelIssueKind.required),
];

List<PayModelIssue> _rate(int bps, PayModelField f) => [
  if (bps <= 0 || bps > Money.basisPointsPerWhole)
    PayModelIssue(f, PayModelIssueKind.outOfRange),
];

/// Fixed monthly salary, accrued per day; absences are deducted.
@immutable
final class SalaryPay extends PayModel {
  const new({required this.monthly});

  final Money monthly;

  @override
  PayModelType get type => PayModelType.salary;

  @override
  List<PayModelIssue> validate() => _positive(monthly, PayModelField.monthly);

  @override
  Map<String, Object?> _fields() => {'monthlyMinor': monthly.minor};
}

/// Fixed amount per day worked; a half day pays [halfDayBps] of it.
@immutable
final class DailyWagePay extends PayModel {
  const new({required this.perDay, this.halfDayBps = 5000});

  final Money perDay;
  final int halfDayBps;

  @override
  PayModelType get type => PayModelType.dailyWage;

  @override
  List<PayModelIssue> validate() => [
    ..._positive(perDay, PayModelField.perDay),
    if (halfDayBps < 0 || halfDayBps > Money.basisPointsPerWhole)
      const PayModelIssue(
        PayModelField.halfDayRate,
        PayModelIssueKind.outOfRange,
      ),
  ];

  @override
  Map<String, Object?> _fields() => {
    'perDayMinor': perDay.minor,
    'halfDayBps': halfDayBps,
  };
}

/// Fixed amount for every trip.
@immutable
final class PerTripPay extends PayModel {
  const new({required this.perTrip});

  final Money perTrip;

  @override
  PayModelType get type => PayModelType.perTrip;

  @override
  List<PayModelIssue> validate() => _positive(perTrip, PayModelField.perTrip);

  @override
  Map<String, Object?> _fields() => {'perTripMinor': perTrip.minor};
}

/// A percentage (basis points) of the fares earned.
@immutable
final class CommissionPay extends PayModel {
  const new({required this.rateBps, required this.basis});

  final int rateBps;
  final CommissionBasis basis;

  @override
  PayModelType get type => PayModelType.commission;

  @override
  List<PayModelIssue> validate() => _rate(rateBps, PayModelField.rate);

  @override
  Map<String, Object?> _fields() => {'rateBps': rateBps, 'basis': basis.name};
}

/// The driver pays the owner a fixed rent and keeps the rest. Nothing is paid
/// to the driver; the rent itself is tracked by the jama module (Sprint 8).
@immutable
final class JamaPay extends PayModel {
  const new({
    required this.amount,
    this.frequency = JamaFrequency.daily,
    this.offWeekdays = const {},
  });

  final Money amount;
  final JamaFrequency frequency;

  /// ISO weekdays (Mon = 1 .. Sun = 7) on which no jama is due.
  final Set<int> offWeekdays;

  @override
  PayModelType get type => PayModelType.jama;

  @override
  List<PayModelIssue> validate() => [
    ..._positive(amount, PayModelField.jamaAmount),
    if (offWeekdays.any((d) => d < 1 || d > 7) || offWeekdays.length == 7)
      const PayModelIssue(PayModelField.offDays, PayModelIssueKind.outOfRange),
  ];

  @override
  Map<String, Object?> _fields() => {
    'amountMinor': amount.minor,
    'frequency': frequency.name,
    'offWeekdays': offWeekdays.toList()..sort(),
  };
}

/// A monthly base salary plus a commission.
@immutable
final class MixedPay extends PayModel {
  const new({
    required this.baseMonthly,
    required this.rateBps,
    required this.basis,
  });

  final Money baseMonthly;
  final int rateBps;
  final CommissionBasis basis;

  @override
  PayModelType get type => PayModelType.mixed;

  @override
  List<PayModelIssue> validate() => [
    ..._positive(baseMonthly, PayModelField.monthly),
    ..._rate(rateBps, PayModelField.rate),
  ];

  @override
  Map<String, Object?> _fields() => {
    'baseMonthlyMinor': baseMonthly.minor,
    'rateBps': rateBps,
    'basis': basis.name,
  };
}

/// Pay model types that make sense for a vehicle's business model. Self-driven
/// vehicles have no driver.
List<PayModelType> allowedPayTypes(BusinessModel model) => switch (model) {
  BusinessModel.self => const [],
  BusinessModel.salaried => const [PayModelType.salary, PayModelType.mixed],
  BusinessModel.dailyWage => const [PayModelType.dailyWage],
  BusinessModel.commission => const [
    PayModelType.commission,
    PayModelType.perTrip,
    PayModelType.mixed,
  ],
  BusinessModel.jama => const [PayModelType.jama],
  BusinessModel.contract => const [
    PayModelType.perTrip,
    PayModelType.commission,
    PayModelType.mixed,
    PayModelType.dailyWage,
  ],
};

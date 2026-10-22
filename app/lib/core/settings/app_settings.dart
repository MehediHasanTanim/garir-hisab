import 'package:meta/meta.dart';
import 'package:vehicle_khata/core/money/number_formatter.dart';

enum ProfitView { cash, accrual }

/// User preferences. Pure Dart so it can be used from domain code.
@immutable
class AppSettings {
  const new({
    this.languageCode = 'bn',
    this.numerals = NumeralStyle.bangla,
    this.grouping = GroupingStyle.southAsian,
    this.profitView = ProfitView.cash,
  });

  static const supportedLanguages = ['bn', 'en'];

  final String languageCode;
  final NumeralStyle numerals;
  final GroupingStyle grouping;
  final ProfitView profitView;

  NumberFormatter get formatter =>
      NumberFormatter(numerals: numerals, grouping: grouping);

  AppSettings copyWith({
    String? languageCode,
    NumeralStyle? numerals,
    GroupingStyle? grouping,
    ProfitView? profitView,
  }) => AppSettings(
    languageCode: languageCode ?? this.languageCode,
    numerals: numerals ?? this.numerals,
    grouping: grouping ?? this.grouping,
    profitView: profitView ?? this.profitView,
  );

  @override
  bool operator ==(Object other) =>
      other is AppSettings &&
      other.languageCode == languageCode &&
      other.numerals == numerals &&
      other.grouping == grouping &&
      other.profitView == profitView;

  @override
  int get hashCode => Object.hash(languageCode, numerals, grouping, profitView);
}

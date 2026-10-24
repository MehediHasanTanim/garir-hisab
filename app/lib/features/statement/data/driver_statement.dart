import 'package:meta/meta.dart';
import 'package:vehicle_khata/core/money/money.dart';
import 'package:vehicle_khata/core/time/calendar_day.dart';
import 'package:vehicle_khata/features/drivers/data/advance_repository.dart';
import 'package:vehicle_khata/features/drivers/data/driver_repository.dart';
import 'package:vehicle_khata/features/drivers/data/payout_service.dart';
import 'package:vehicle_khata/features/drivers/domain/driver.dart';

/// What the owner and a driver need to agree on for a period: payouts made,
/// advances given, and what is still owed back.
@immutable
class DriverStatement {
  const new({
    required this.driverName,
    required this.phone,
    required this.range,
    required this.payouts,
    required this.advances,
    required this.advancesOwed,
  });

  final String driverName;
  final String? phone;

  /// Null means all time.
  final DayRange? range;
  final List<Payout> payouts;
  final List<Advance> advances;

  /// Still to be recovered from the driver, as of today (all advances).
  final Money advancesOwed;

  Money get totalEarned => payouts.map((p) => p.earned).sum();
  Money get totalAdjustment => payouts.map((p) => p.adjustment).sum();
  Money get totalRecovered => payouts.map((p) => p.deducted).sum();
  Money get totalPaid => payouts.map((p) => p.net).sum();
  Money get totalAdvancesGiven => advances.map((a) => a.amount).sum();

  bool get isEmpty => payouts.isEmpty && advances.isEmpty;
}

class StatementService {
  new(this._drivers, this._payouts, this._advances);

  final DriverRepository _drivers;
  final PayoutService _payouts;
  final AdvanceRepository _advances;

  /// Payouts whose period touches [range], oldest first; advances given in
  /// [range]. A null [range] includes everything.
  Future<DriverStatement?> build(String driverId, DayRange? range) async {
    final driver = await _drivers.get(driverId);
    if (driver == null) return null;
    final payouts = (await _payouts.listForDriver(driverId))
        .where(
          (p) =>
              range == null ||
              (!p.period.start.isAfter(range.end) &&
                  !p.period.end.isBefore(range.start)),
        )
        .toList()
        .reversed
        .toList();
    final allAdvances = await _advances.listForDriver(driverId);
    final advances = allAdvances
        .where(
          (a) =>
              range == null ||
              (!a.givenOn.isBefore(range.start) &&
                  !a.givenOn.isAfter(range.end)),
        )
        .toList()
        .reversed
        .toList();
    final owed = allAdvances
        .where((a) => a.remaining.isPositive)
        .map((a) => a.remaining)
        .sum();
    return DriverStatement(
      driverName: driver.name,
      phone: driver.phone,
      range: range,
      payouts: payouts,
      advances: advances,
      advancesOwed: owed,
    );
  }
}

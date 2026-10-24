import 'package:meta/meta.dart';
import 'package:vehicle_khata/core/money/money.dart';
import 'package:vehicle_khata/core/time/calendar_day.dart';
import 'package:vehicle_khata/features/expenses/domain/expense.dart';

enum PaymentStatus { paid, partial, unpaid }

/// Whether a fare has been fully, partly or not at all received.
PaymentStatus paymentStatus({required Money fare, required Money received}) {
  if (received >= fare) return PaymentStatus.paid;
  if (!received.isPositive) return PaymentStatus.unpaid;
  return PaymentStatus.partial;
}

@immutable
class Trip {
  const new({
    required this.id,
    required this.vehicleId,
    required this.startedAt,
    required this.day,
    required this.fare,
    required this.received,
    required this.driverPay,
    required this.driverPayOverridden,
    this.driverId,
    this.fromPlace,
    this.toPlace,
    this.distanceM,
    this.loadNote,
    this.note,
    this.returnOfTripId,
  });

  final String id;
  final String vehicleId;
  final String? driverId;
  final DateTime startedAt;

  /// The trip's calendar day (local time).
  final CalendarDay day;
  final String? fromPlace;
  final String? toPlace;
  final int? distanceM;
  final Money fare;
  final Money received;
  final Money driverPay;

  /// True when the owner typed the driver's pay instead of using the
  /// calculated amount.
  final bool driverPayOverridden;
  final String? loadNote;
  final String? note;

  /// The outbound trip this one is the return leg of.
  final String? returnOfTripId;

  Money get due => fare - received;
  PaymentStatus get status => paymentStatus(fare: fare, received: received);
}

@immutable
class TripDraft {
  const new({
    required this.vehicleId,
    required this.startedAt,
    required this.fare,
    required this.received,
    required this.driverPay,
    this.driverPayOverridden = false,
    this.driverId,
    this.fromPlace,
    this.toPlace,
    this.distanceM,
    this.loadNote,
    this.note,
    this.returnOfTripId,
    this.expenses = const [],
  });

  factory fromTrip(Trip t, List<Expense> expenses) => TripDraft(
    vehicleId: t.vehicleId,
    driverId: t.driverId,
    startedAt: t.startedAt,
    fromPlace: t.fromPlace,
    toPlace: t.toPlace,
    distanceM: t.distanceM,
    fare: t.fare,
    received: t.received,
    driverPay: t.driverPay,
    driverPayOverridden: t.driverPayOverridden,
    loadNote: t.loadNote,
    note: t.note,
    returnOfTripId: t.returnOfTripId,
    expenses: expenses.map(ExpenseDraft.fromExpense).toList(),
  );

  final String vehicleId;
  final String? driverId;
  final DateTime startedAt;
  final String? fromPlace;
  final String? toPlace;
  final int? distanceM;
  final Money fare;
  final Money received;
  final Money driverPay;
  final bool driverPayOverridden;
  final String? loadNote;
  final String? note;
  final String? returnOfTripId;
  final List<ExpenseDraft> expenses;
}

/// A trip with its expenses.
@immutable
class TripDetail {
  const new({required this.trip, required this.expenses});

  final Trip trip;
  final List<Expense> expenses;
}

/// A trip row in a list, with the numbers needed to show it.
@immutable
class TripSummary {
  const new({
    required this.trip,
    required this.vehicleNickname,
    required this.ownerExpenses,
    this.driverName,
  });

  final Trip trip;
  final String vehicleNickname;
  final String? driverName;

  /// Expenses that are a cost to the owner.
  final Money ownerExpenses;

  Money get profit => trip.fare - ownerExpenses - trip.driverPay;
}

/// Totals of a driver's trips for pay calculation.
@immutable
class DriverTripTotals {
  const new({
    required this.count,
    required this.fare,
    required this.ownerExpenses,
    required this.driverPay,
  });

  static const zero = DriverTripTotals(
    count: 0,
    fare: Money.zero,
    ownerExpenses: Money.zero,
    driverPay: Money.zero,
  );

  final int count;
  final Money fare;
  final Money ownerExpenses;
  final Money driverPay;
}

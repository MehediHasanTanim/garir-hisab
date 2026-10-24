import 'package:drift/drift.dart';
import 'package:vehicle_khata/core/db/app_database.dart';
import 'package:vehicle_khata/core/money/money.dart';
import 'package:vehicle_khata/core/time/calendar_day.dart';
import 'package:vehicle_khata/features/expenses/domain/expense.dart';

Expense expenseFromRow(ExpenseRow r) => Expense(
  id: r.id,
  vehicleId: r.vehicleId,
  tripId: r.tripId,
  categoryId: r.categoryId,
  amount: Money(r.amountMinor),
  spentAt: DateTime.fromMillisecondsSinceEpoch(r.spentAt, isUtc: true),
  paidBy: r.paidBy,
  reimbursable: r.reimbursable,
  note: r.note,
  receiptFile: r.receiptFile,
  qtyMilli: r.qtyMilli,
  odometerM: r.odometerM,
);

String? _blank(String? s) {
  final t = s?.trim() ?? '';
  return t.isEmpty ? null : t;
}

ExpensesCompanion expenseCompanion(
  ExpenseDraft e, {
  required String vehicleId,
  required String? tripId,
  required DateTime at,
  String? id,
}) => ExpensesCompanion(
  id: id == null ? const Value.absent() : Value(id),
  vehicleId: Value(vehicleId),
  tripId: Value(tripId),
  categoryId: Value(e.categoryId),
  amountMinor: Value(e.amount.minor),
  spentAt: Value((e.spentAt ?? at).toUtc().millisecondsSinceEpoch),
  paidBy: Value(e.paidBy),
  // Only a driver-paid expense can be reimbursable.
  reimbursable: Value(e.paidBy == PaidBy.driver && e.reimbursable),
  note: Value(_blank(e.note)),
  receiptFile: Value(e.receiptFile),
  qtyMilli: Value(e.qtyMilli),
  odometerM: Value(e.odometerM),
  spentDay: Value(CalendarDay.fromDate((e.spentAt ?? at).toLocal()).epochDay),
);

/// Comparable snapshot of an expense, for audit diffs. With [draft] it
/// describes the state after applying the draft.
Map<String, Object?> expenseSnapshot(
  Expense e, {
  ExpenseDraft? draft,
  DateTime? at,
  String? vehicleId,
}) {
  final d = draft;
  return {
    'vehicleId': vehicleId ?? e.vehicleId,
    'categoryId': d?.categoryId ?? e.categoryId,
    'amountMinor': (d?.amount ?? e.amount).minor,
    'paidBy': (d?.paidBy ?? e.paidBy).name,
    'reimbursable': d == null
        ? e.reimbursable
        : d.paidBy == PaidBy.driver && d.reimbursable,
    'note': d == null ? e.note : _blank(d.note),
    'qtyMilli': d == null ? e.qtyMilli : d.qtyMilli,
    'odometerM': d == null ? e.odometerM : d.odometerM,
    'spentAt': (d == null ? e.spentAt : (d.spentAt ?? at ?? e.spentAt))
        .toUtc()
        .toIso8601String(),
  };
}

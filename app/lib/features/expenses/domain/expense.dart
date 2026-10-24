import 'package:meta/meta.dart';
import 'package:vehicle_khata/core/money/money.dart';

/// Who handed over the money for an expense.
enum PaidBy { owner, driver, client }

/// Built-in category keys. Their names are localized; custom categories carry
/// their own name instead.
enum DefaultCategory {
  fuel,
  toll,
  parking,
  helper,
  police,
  food,
  repair,
  parts,
  tyre,
  service,
  washing,
  insurance,
  registration,
  loan,
  other,
}

@immutable
class ExpenseCategory {
  const new({
    required this.id,
    required this.sortOrder,
    required this.archived,
    this.key,
    this.name,
  });

  /// Built-in categories have fixed ids so that devices stay in sync.
  static String defaultId(DefaultCategory key) => 'default:${key.name}';

  final String id;

  /// Set for built-in categories.
  final DefaultCategory? key;

  /// Set for custom categories.
  final String? name;
  final int sortOrder;
  final bool archived;

  bool get isFuel => key == DefaultCategory.fuel;
  bool get isCustom => key == null;
}

@immutable
class Expense {
  const new({
    required this.id,
    required this.vehicleId,
    required this.categoryId,
    required this.amount,
    required this.spentAt,
    required this.paidBy,
    required this.reimbursable,
    this.tripId,
    this.note,
    this.receiptFile,
    this.qtyMilli,
    this.odometerM,
  });

  final String id;
  final String vehicleId;

  /// Null for vehicle-level expenses (repairs, insurance…).
  final String? tripId;
  final String categoryId;
  final Money amount;
  final DateTime spentAt;
  final PaidBy paidBy;

  /// A driver-paid expense the owner will pay back.
  final bool reimbursable;
  final String? note;
  final String? receiptFile;

  /// Fuel quantity in thousandths of a litre / cubic metre.
  final int? qtyMilli;

  /// Odometer reading in metres.
  final int? odometerM;

  bool get isOwnerBorne => ownerBears(paidBy, reimbursable: reimbursable);
}

/// Whether an expense is a cost to the owner: money the owner paid, or money
/// the driver paid that the owner will reimburse. A client-paid expense, or a
/// driver's own non-reimbursable one, is not.
bool ownerBears(PaidBy paidBy, {required bool reimbursable}) =>
    switch (paidBy) {
      PaidBy.owner => true,
      PaidBy.driver => reimbursable,
      PaidBy.client => false,
    };

/// What the user edits for one expense. [id] is set when editing an existing
/// one.
@immutable
class ExpenseDraft {
  const new({
    required this.categoryId,
    required this.amount,
    this.id,
    this.paidBy = PaidBy.owner,
    this.reimbursable = false,
    this.note,
    this.receiptFile,
    this.qtyMilli,
    this.odometerM,
    this.spentAt,
  });

  factory fromExpense(Expense e) => ExpenseDraft(
    id: e.id,
    categoryId: e.categoryId,
    amount: e.amount,
    paidBy: e.paidBy,
    reimbursable: e.reimbursable,
    note: e.note,
    receiptFile: e.receiptFile,
    qtyMilli: e.qtyMilli,
    odometerM: e.odometerM,
    spentAt: e.spentAt,
  );

  final String? id;
  final String categoryId;
  final Money amount;
  final PaidBy paidBy;
  final bool reimbursable;
  final String? note;
  final String? receiptFile;
  final int? qtyMilli;
  final int? odometerM;

  /// Only used for vehicle-level expenses; trip expenses take the trip time.
  final DateTime? spentAt;

  bool get isOwnerBorne => ownerBears(paidBy, reimbursable: reimbursable);

  ExpenseDraft copyWith({
    String? categoryId,
    Money? amount,
    PaidBy? paidBy,
    bool? reimbursable,
    String? note,
    String? receiptFile,
    int? qtyMilli,
    int? odometerM,
    DateTime? spentAt,
    bool clearReceipt = false,
  }) => ExpenseDraft(
    id: id,
    categoryId: categoryId ?? this.categoryId,
    amount: amount ?? this.amount,
    paidBy: paidBy ?? this.paidBy,
    reimbursable: reimbursable ?? this.reimbursable,
    note: note ?? this.note,
    receiptFile: clearReceipt ? null : receiptFile ?? this.receiptFile,
    qtyMilli: qtyMilli ?? this.qtyMilli,
    odometerM: odometerM ?? this.odometerM,
    spentAt: spentAt ?? this.spentAt,
  );
}

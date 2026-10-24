import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vehicle_khata/app/l10n_labels.dart';
import 'package:vehicle_khata/app/providers/feature_providers.dart';
import 'package:vehicle_khata/app/providers/providers.dart';
import 'package:vehicle_khata/app/ui/format.dart';
import 'package:vehicle_khata/app/ui/tokens.dart';
import 'package:vehicle_khata/app/ui/widgets/amount_sheet.dart';
import 'package:vehicle_khata/app/ui/widgets/big_button.dart';
import 'package:vehicle_khata/core/money/money.dart';
import 'package:vehicle_khata/core/time/calendar_day.dart';
import 'package:vehicle_khata/features/expenses/domain/expense.dart';
import 'package:vehicle_khata/features/expenses/presentation/category_name_dialog.dart';
import 'package:vehicle_khata/features/vehicles/data/photo_store.dart';
import 'package:vehicle_khata/l10n/gen/app_localizations.dart';

/// What the editor returns: a saved draft, or a request to delete.
class ExpenseEditResult {
  const new save(ExpenseDraft this.draft) : delete = false;
  const new remove() : draft = null, delete = true;

  final ExpenseDraft? draft;
  final bool delete;
}

/// Edits one expense in a bottom sheet. [showDate] is for vehicle-level
/// expenses (trip expenses take the trip's time); [allowDelete] adds a delete
/// button.
Future<ExpenseEditResult?> showExpenseEditor(
  BuildContext context, {
  required ExpenseDraft initial,
  bool showDate = false,
  bool allowDelete = false,
}) {
  return showModalBottomSheet<ExpenseEditResult>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    builder: (context) => _ExpenseEditor(
      initial: initial,
      showDate: showDate,
      allowDelete: allowDelete,
    ),
  );
}

const _newCategory = '__new__';

class _ExpenseEditor extends ConsumerStatefulWidget {
  const new({
    required this.initial,
    required this.showDate,
    required this.allowDelete,
  });

  final ExpenseDraft initial;
  final bool showDate;
  final bool allowDelete;

  @override
  ConsumerState<_ExpenseEditor> createState() => _ExpenseEditorState();
}

class _ExpenseEditorState extends ConsumerState<_ExpenseEditor> {
  late String _categoryId = widget.initial.categoryId;
  late Money _amount = widget.initial.amount;
  late PaidBy _paidBy = widget.initial.paidBy;
  late bool _reimbursable = widget.initial.reimbursable;
  late String? _receipt = widget.initial.receiptFile;
  late DateTime? _spentAt = widget.initial.spentAt;
  late final _note = TextEditingController(text: widget.initial.note);
  late final _qty = TextEditingController(
    text: widget.initial.qtyMilli == null
        ? ''
        : _trimNumber(widget.initial.qtyMilli! / 1000),
  );
  late final _odo = TextEditingController(
    text: widget.initial.odometerM == null
        ? ''
        : _trimNumber(widget.initial.odometerM! / 1000),
  );
  late final PhotoStore _photoStore;
  final _addedReceipts = <String>[];
  bool _saved = false;
  String? _amountError;
  String? _qtyError;
  String? _odoError;

  @override
  void initState() {
    super.initState();
    _photoStore = ref.read(photoStoreProvider);
  }

  @override
  void dispose() {
    // A receipt picked in this sheet but never saved is not kept.
    if (!_saved) {
      for (final f in _addedReceipts) {
        unawaited(_photoStore.delete(f));
      }
    }
    _note.dispose();
    _qty.dispose();
    _odo.dispose();
    super.dispose();
  }

  static String _trimNumber(double v) {
    final text = v.toStringAsFixed(3);
    return text.replaceFirst(RegExp(r'\.?0+$'), '');
  }

  /// "12.5" -> 12500 (thousandths); null if invalid or not positive/zero.
  static int? _parseMilli(String input, {required bool allowZero}) {
    final text = input.trim().replaceAll(',', '');
    if (text.isEmpty) return null;
    final v = double.tryParse(_latin(text));
    if (v == null || v < 0 || (!allowZero && v == 0)) return -1;
    return (v * 1000).round();
  }

  static String _latin(String s) {
    const bangla = '০১২৩৪৫৬৭৮৯';
    final out = StringBuffer();
    for (final rune in s.runes) {
      final ch = String.fromCharCode(rune);
      final i = bangla.indexOf(ch);
      out.write(i >= 0 ? '$i' : ch);
    }
    return out.toString();
  }

  Future<void> _pickAmount() async {
    final l10n = AppLocalizations.of(context);
    final value = await showAmountSheet(
      context,
      title: l10n.advanceAmount,
      initial: _amount,
    );
    if (value != null && mounted) {
      setState(() {
        _amount = value;
        _amountError = null;
      });
    }
  }

  Future<void> _addCategory() async {
    final id = await showCategoryNameDialog(context);
    if (id != null && mounted) setState(() => _categoryId = id);
  }

  Future<void> _photoMenu() async {
    final l10n = AppLocalizations.of(context);
    final choice = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(l10n.takePhoto),
              onTap: () => Navigator.pop(context, 'camera'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l10n.chooseFromGallery),
              onTap: () => Navigator.pop(context, 'gallery'),
            ),
            if (_receipt != null)
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: Text(l10n.removePhoto),
                onTap: () => Navigator.pop(context, 'remove'),
              ),
          ],
        ),
      ),
    );
    switch (choice) {
      case 'camera':
      case 'gallery':
        final path = await ref
            .read(photoPickerProvider)
            .pick(
              choice == 'camera' ? PhotoSource.camera : PhotoSource.gallery,
            );
        if (path == null) return;
        final name = await _photoStore.save(path);
        if (!mounted) return;
        setState(() {
          _receipt = name;
          _addedReceipts.add(name);
        });
      case 'remove':
        setState(() => _receipt = null);
    }
  }

  Future<void> _pickDate() async {
    final current = _spentAt ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) {
      setState(
        () => _spentAt = DateTime(
          picked.year,
          picked.month,
          picked.day,
          current.hour,
          current.minute,
        ).toUtc(),
      );
    }
  }

  void _save(bool isFuel) {
    final l10n = AppLocalizations.of(context);
    final qty = isFuel ? _parseMilli(_qty.text, allowZero: false) : null;
    final odo = isFuel ? _parseMilli(_odo.text, allowZero: true) : null;
    setState(() {
      _amountError = _amount.isPositive ? null : l10n.errAmountInvalid;
      _qtyError = qty == -1 ? l10n.errQtyInvalid : null;
      _odoError = odo == -1 ? l10n.errOdoInvalid : null;
    });
    if (_amountError != null || _qtyError != null || _odoError != null) return;

    _saved = true;
    Navigator.pop(
      context,
      ExpenseEditResult.save(
        ExpenseDraft(
          id: widget.initial.id,
          categoryId: _categoryId,
          amount: _amount,
          paidBy: _paidBy,
          reimbursable: _paidBy == PaidBy.driver && _reimbursable,
          note: _note.text,
          receiptFile: _receipt,
          qtyMilli: qty,
          odometerM: odo,
          spentAt: _spentAt,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final formatter = ref.watch(numberFormatterProvider);
    final categories = ref.watch(allCategoriesProvider).value ?? const [];
    final selectable = [
      for (final c in categories)
        if (!c.archived || c.id == widget.initial.categoryId) c,
    ];
    final isFuel =
        _categoryId == ExpenseCategory.defaultId(DefaultCategory.fuel);

    const gap = SizedBox(height: Spacing.md);
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          Spacing.gutter,
          0,
          Spacing.gutter,
          Spacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.initial.id == null ? l10n.addExpense : l10n.editExpense,
              style: theme.textTheme.titleLarge,
            ),
            gap,
            AmountTile(
              label: l10n.advanceAmount,
              amountText: _amount.isPositive ? formatter.money(_amount) : null,
              hint: l10n.tapToEnter,
              errorText: _amountError,
              onTap: _pickAmount,
            ),
            gap,
            DropdownButtonFormField<String>(
              initialValue: selectable.any((c) => c.id == _categoryId)
                  ? _categoryId
                  : null,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: l10n.expenseCategory,
                border: const OutlineInputBorder(),
              ),
              items: [
                for (final c in selectable)
                  DropdownMenuItem(
                    value: c.id,
                    child: Text(l10n.categoryLabel(c)),
                  ),
                DropdownMenuItem(
                  value: _newCategory,
                  child: Text(l10n.newCategory),
                ),
              ],
              onChanged: (id) {
                if (id == _newCategory) {
                  unawaited(_addCategory());
                } else if (id != null) {
                  setState(() => _categoryId = id);
                }
              },
            ),
            gap,
            Text(l10n.paidBy, style: theme.textTheme.titleSmall),
            const SizedBox(height: Spacing.sm),
            SegmentedButton<PaidBy>(
              showSelectedIcon: false,
              segments: [
                for (final p in PaidBy.values)
                  ButtonSegment(value: p, label: Text(l10n.paidByName(p))),
              ],
              selected: {_paidBy},
              onSelectionChanged: (s) => setState(() => _paidBy = s.first),
            ),
            if (_paidBy == PaidBy.driver)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.reimbursable),
                value: _reimbursable,
                onChanged: (v) => setState(() => _reimbursable = v),
              ),
            if (isFuel) ...[
              gap,
              TextField(
                controller: _qty,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[0-9০-৯.,]')),
                  LengthLimitingTextInputFormatter(10),
                ],
                decoration: InputDecoration(
                  labelText: '${l10n.fuelQty} (${l10n.optional})',
                  errorText: _qtyError,
                  border: const OutlineInputBorder(),
                ),
              ),
              gap,
              TextField(
                controller: _odo,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[0-9০-৯.,]')),
                  LengthLimitingTextInputFormatter(12),
                ],
                decoration: InputDecoration(
                  labelText: '${l10n.odometer} (${l10n.optional})',
                  errorText: _odoError,
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
            if (widget.showDate) ...[
              gap,
              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: l10n.advanceDate,
                    border: const OutlineInputBorder(),
                    suffixIcon: const Icon(Icons.calendar_today_outlined),
                  ),
                  child: Text(
                    formatDay(
                      formatter,
                      CalendarDay.fromDate(
                        (_spentAt ?? DateTime.now()).toLocal(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
            gap,
            TextField(
              controller: _note,
              decoration: InputDecoration(
                labelText: l10n.advanceNote,
                border: const OutlineInputBorder(),
              ),
            ),
            gap,
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(Sizes.minTap),
              ),
              onPressed: _photoMenu,
              icon: Icon(
                _receipt == null
                    ? Icons.receipt_long_outlined
                    : Icons.check_circle_outline,
              ),
              label: Text(_receipt == null ? l10n.addReceipt : l10n.receipt),
            ),
            const SizedBox(height: Spacing.lg),
            BigButton(
              label: l10n.save,
              icon: Icons.check,
              onPressed: () => _save(isFuel),
            ),
            if (widget.allowDelete)
              TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                ),
                onPressed: () {
                  _saved = true;
                  Navigator.pop(context, const ExpenseEditResult.remove());
                },
                icon: const Icon(Icons.delete_outline),
                label: Text(l10n.deleteLabel),
              ),
          ],
        ),
      ),
    );
  }
}

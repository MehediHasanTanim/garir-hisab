import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vehicle_khata/app/l10n_labels.dart';
import 'package:vehicle_khata/app/providers/feature_providers.dart';
import 'package:vehicle_khata/app/providers/providers.dart';
import 'package:vehicle_khata/app/ui/format.dart';
import 'package:vehicle_khata/app/ui/tokens.dart';
import 'package:vehicle_khata/app/ui/widgets/amount_sheet.dart';
import 'package:vehicle_khata/app/ui/widgets/big_button.dart';
import 'package:vehicle_khata/app/ui/widgets/empty_state.dart';
import 'package:vehicle_khata/app/ui/widgets/khata_list_tile.dart';
import 'package:vehicle_khata/app/ui/widgets/quick_chips.dart';
import 'package:vehicle_khata/core/money/money.dart';
import 'package:vehicle_khata/core/money/number_formatter.dart';
import 'package:vehicle_khata/core/time/calendar_day.dart';
import 'package:vehicle_khata/features/app_lock/presentation/app_lock_controller.dart';
import 'package:vehicle_khata/features/drivers/data/driver_repository.dart';
import 'package:vehicle_khata/features/drivers/domain/driver.dart';
import 'package:vehicle_khata/features/expenses/domain/expense.dart';
import 'package:vehicle_khata/features/expenses/presentation/expense_editor.dart';
import 'package:vehicle_khata/features/trips/data/trip_repository.dart';
import 'package:vehicle_khata/features/trips/domain/trip.dart';
import 'package:vehicle_khata/features/trips/domain/trip_math.dart';
import 'package:vehicle_khata/features/trips/presentation/place_field.dart';
import 'package:vehicle_khata/features/vehicles/data/photo_store.dart';
import 'package:vehicle_khata/features/vehicles/data/vehicle_repository.dart';
import 'package:vehicle_khata/features/vehicles/domain/vehicle.dart';
import 'package:vehicle_khata/l10n/gen/app_localizations.dart';

/// Add or edit a trip. Modes:
/// * [tripId] — edit that trip;
/// * [repeatFrom] — new trip pre-filled from an earlier one;
/// * [returnOf] — new trip for the way back of an earlier one;
/// * [vehicleId] — new trip for this vehicle.
class TripFormPage extends ConsumerStatefulWidget {
  const new({
    this.tripId,
    this.vehicleId,
    this.repeatFrom,
    this.returnOf,
    super.key,
  });

  final String? tripId;
  final String? vehicleId;
  final String? repeatFrom;
  final String? returnOf;

  @override
  ConsumerState<TripFormPage> createState() => _TripFormPageState();
}

class _Seed {
  const new({this.source, this.lastVehicleId});

  final TripDetail? source;
  final String? lastVehicleId;
}

class _TripFormPageState extends ConsumerState<TripFormPage> {
  late final Future<_Seed> _seed = _load();

  Future<_Seed> _load() async {
    final repo = ref.read(tripRepositoryProvider);
    final id = widget.tripId ?? widget.repeatFrom ?? widget.returnOf;
    return _Seed(
      source: id == null ? null : await repo.get(id),
      lastVehicleId: await repo.lastTripVehicleId(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return FutureBuilder<_Seed>(
      future: _seed,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final seed = snap.data!;
        final wantsSource =
            widget.tripId != null ||
            widget.repeatFrom != null ||
            widget.returnOf != null;
        if (wantsSource && seed.source == null) {
          return Scaffold(
            appBar: AppBar(),
            body: EmptyState(icon: Icons.search_off, title: l10n.tripNotFound),
          );
        }
        return _TripForm(
          seed: seed,
          editing: widget.tripId != null,
          vehicleId: widget.vehicleId,
          returnOf: widget.returnOf,
          isRepeat: widget.repeatFrom != null,
        );
      },
    );
  }
}

enum _Payment { paid, partial, unpaid }

/// One expense line in the form, with a stable key for list updates.
class _Line {
  new(this.draft);

  final ExpenseDraft draft;
}

class _TripForm extends ConsumerStatefulWidget {
  const new({
    required this.seed,
    required this.editing,
    required this.vehicleId,
    required this.returnOf,
    required this.isRepeat,
  });

  final _Seed seed;
  final bool editing;
  final String? vehicleId;
  final String? returnOf;
  final bool isRepeat;

  @override
  ConsumerState<_TripForm> createState() => _TripFormState();
}

class _TripFormState extends ConsumerState<_TripForm> {
  late final _from = TextEditingController();
  late final _to = TextEditingController();
  late final _distance = TextEditingController();
  late final _load = TextEditingController();
  late final _note = TextEditingController();
  late final PhotoStore _photoStore;

  String? _vehicleId;
  String? _driverId;
  bool _driverTouched = false;
  late DateTime _startedAt;
  Money _fare = Money.zero;
  _Payment _payment = _Payment.paid;
  Money _received = Money.zero;
  Money? _payOverride;

  /// When editing, the stored (non-overridden) pay is kept until something
  /// that affects it changes.
  Money? _frozenPay;
  final _expenses = <_Line>[];
  String? _returnOfTripId;

  late final Set<String> _originalReceipts;
  final _everAddedReceipts = <String>{};
  bool _saved = false;
  bool _saving = false;
  String? _fareError;
  String? _receivedError;
  String? _distanceError;
  String? _vehicleError;
  String? _saveError;

  @override
  void initState() {
    super.initState();
    _photoStore = ref.read(photoStoreProvider);
    final src = widget.seed.source;
    _startedAt = ref.read(clockProvider)();
    _originalReceipts = {
      if (widget.editing && src != null)
        for (final e in src.expenses)
          if (e.receiptFile != null) e.receiptFile!,
    };

    if (src != null) {
      final t = src.trip;
      _vehicleId = t.vehicleId;
      _driverId = t.driverId;
      _driverTouched = true;
      _fare = t.fare;
      _distance.text = t.distanceM == null ? '' : _km(t.distanceM!);
      _load.text = t.loadNote ?? '';

      if (widget.returnOf != null) {
        // The way back: swap the route, same fare, fresh expenses.
        _from.text = t.toPlace ?? '';
        _to.text = t.fromPlace ?? '';
        _returnOfTripId = t.id;
      } else {
        _from.text = t.fromPlace ?? '';
        _to.text = t.toPlace ?? '';
        _returnOfTripId = t.returnOfTripId;
      }

      if (widget.editing) {
        _startedAt = t.startedAt.toLocal();
        _note.text = t.note ?? '';
        _payment = switch (t.status) {
          PaymentStatus.paid => _Payment.paid,
          PaymentStatus.partial => _Payment.partial,
          PaymentStatus.unpaid => _Payment.unpaid,
        };
        _received = t.received;
        if (t.driverPayOverridden) {
          _payOverride = t.driverPay;
        } else {
          _frozenPay = t.driverPay;
        }
        for (final e in src.expenses) {
          _expenses.add(_Line(ExpenseDraft.fromExpense(e)));
        }
      } else if (widget.isRepeat) {
        // Same trip again: copy the costs (without receipts).
        for (final e in src.expenses) {
          _expenses.add(
            _Line(
              ExpenseDraft(
                categoryId: e.categoryId,
                amount: e.amount,
                paidBy: e.paidBy,
                reimbursable: e.reimbursable,
                note: e.note,
              ),
            ),
          );
        }
      }
    } else {
      _vehicleId = widget.vehicleId ?? widget.seed.lastVehicleId;
    }
  }

  @override
  void dispose() {
    if (!_saved) {
      for (final f in _everAddedReceipts.difference(_originalReceipts)) {
        unawaited(_photoStore.delete(f));
      }
    }
    for (final c in [_from, _to, _distance, _load, _note]) {
      c.dispose();
    }
    super.dispose();
  }

  static String _km(int metres) {
    final text = (metres / 1000).toStringAsFixed(3);
    return text.replaceFirst(RegExp(r'\.?0+$'), '');
  }

  Money get _receivedNow => switch (_payment) {
    _Payment.paid => _fare,
    _Payment.unpaid => Money.zero,
    _Payment.partial => _received,
  };

  Iterable<ExpenseDraft> get _drafts => _expenses.map((l) => l.draft);

  /// Something that affects the calculated driver pay changed.
  void _invalidatePay() => _frozenPay = null;

  Money _calculatedPay(AssignmentView? assignment) {
    final model =
        assignment != null && assignment.assignment.driverId == _driverId
        ? assignment.assignment.payModel
        : null;
    final ownerExpenses = _drafts
        .where((e) => e.isOwnerBorne)
        .map((e) => e.amount)
        .sum();
    return tripDriverPay(
      model: model,
      fare: _fare,
      ownerExpenses: ownerExpenses,
    );
  }

  Money _effectivePay(AssignmentView? assignment) =>
      _payOverride ?? _frozenPay ?? _calculatedPay(assignment);

  Future<void> _pickFare() async {
    final l10n = AppLocalizations.of(context);
    final v = await showAmountSheet(
      context,
      title: l10n.tripFare,
      initial: _fare,
    );
    if (v == null || !mounted) return;
    setState(() {
      _fare = v;
      _fareError = null;
      _receivedError = null;
      _invalidatePay();
    });
  }

  Future<void> _pickReceived() async {
    final l10n = AppLocalizations.of(context);
    final v = await showAmountSheet(
      context,
      title: l10n.amountReceived,
      initial: _received,
    );
    if (v == null || !mounted) return;
    setState(() {
      _received = v;
      _receivedError = null;
    });
  }

  Future<void> _pickPayOverride(AssignmentView? assignment) async {
    final l10n = AppLocalizations.of(context);
    final v = await showAmountSheet(
      context,
      title: l10n.driverPayLabel,
      initial: _effectivePay(assignment),
    );
    if (v == null || !mounted) return;
    setState(() => _payOverride = v);
  }

  Future<void> _quickExpense(String categoryId, String name) async {
    final v = await showAmountSheet(context, title: name);
    if (v == null || !v.isPositive || !mounted) return;
    setState(() {
      _expenses.add(_Line(ExpenseDraft(categoryId: categoryId, amount: v)));
      _invalidatePay();
    });
  }

  Future<void> _moreExpense(List<ExpenseCategory> categories) async {
    final l10n = AppLocalizations.of(context);
    final picked = await showModalBottomSheet<ExpenseCategory>(
      context: context,
      useRootNavigator: true,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final c in categories)
              ListTile(
                minTileHeight: 52,
                title: Text(l10n.categoryLabel(c)),
                onTap: () => Navigator.pop(context, c),
              ),
          ],
        ),
      ),
    );
    if (picked != null && mounted) {
      await _quickExpense(picked.id, l10n.categoryLabel(picked));
    }
  }

  Future<void> _editExpense(_Line line) async {
    final result = await showExpenseEditor(
      context,
      initial: line.draft,
      allowDelete: true,
    );
    if (result == null || !mounted) return;
    setState(() {
      final index = _expenses.indexOf(line);
      if (result.delete) {
        _expenses.removeAt(index);
      } else {
        final draft = result.draft!;
        _trackReceipt(draft.receiptFile);
        _expenses[index] = _Line(draft);
      }
      _invalidatePay();
    });
  }

  void _trackReceipt(String? file) {
    if (file != null && !_originalReceipts.contains(file)) {
      _everAddedReceipts.add(file);
    }
  }

  Future<void> _pickWhen() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startedAt,
      firstDate: DateTime(2000),
      lastDate: _startedAt.add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startedAt),
    );
    if (!mounted) return;
    setState(
      () => _startedAt = DateTime(
        date.year,
        date.month,
        date.day,
        time?.hour ?? _startedAt.hour,
        time?.minute ?? _startedAt.minute,
      ),
    );
  }

  Future<void> _save(AssignmentView? assignment) async {
    final l10n = AppLocalizations.of(context);
    final km = _distance.text.trim().isEmpty
        ? null
        : double.tryParse(_latin(_distance.text.trim().replaceAll(',', '')));
    final distanceBad =
        _distance.text.trim().isNotEmpty && (km == null || km < 0);

    setState(() {
      _vehicleError = _vehicleId == null ? l10n.errVehicleRequired : null;
      _fareError = _fare.isPositive ? null : l10n.errFareRequired;
      _receivedError = _receivedNow > _fare ? l10n.errReceivedTooHigh : null;
      _distanceError = distanceBad ? l10n.errDistanceInvalid : null;
      _saveError = null;
    });
    if (_vehicleError != null ||
        _fareError != null ||
        _receivedError != null ||
        _distanceError != null) {
      return;
    }

    setState(() => _saving = true);
    final draft = TripDraft(
      vehicleId: _vehicleId!,
      driverId: _driverId,
      startedAt: _startedAt.toUtc(),
      fromPlace: _from.text,
      toPlace: _to.text,
      distanceM: km == null ? null : (km * 1000).round(),
      fare: _fare,
      received: _receivedNow,
      driverPay: _effectivePay(assignment),
      driverPayOverridden: _payOverride != null,
      loadNote: _load.text,
      note: _note.text,
      returnOfTripId: _returnOfTripId,
      expenses: _drafts.toList(),
    );

    final repo = ref.read(tripRepositoryProvider);
    try {
      if (widget.editing) {
        await repo.update(widget.seed.source!.trip.id, draft);
      } else {
        await repo.create(draft);
      }
    } on TripException catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _saveError = l10n.tripError(e.error);
      });
      return;
    }
    _saved = true;

    // Receipts that are no longer attached are not kept.
    final finalFiles = {
      for (final e in _drafts)
        if (e.receiptFile != null) e.receiptFile!,
    };
    final store = ref.read(photoStoreProvider);
    for (final f in {
      ..._originalReceipts,
      ..._everAddedReceipts,
    }.difference(finalFiles)) {
      await store.delete(f);
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.tripSaved)));
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/entries');
    }
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final formatter = ref.watch(numberFormatterProvider);
    final vehicles =
        ref.watch(vehicleListProvider(const VehicleFilter(limit: 500))).value ??
        const <Vehicle>[];
    final categories = ref.watch(categoriesProvider).value ?? const [];
    final drivers =
        ref
            .watch(
              driverListProvider(
                const DriverFilter(status: DriverStatus.active, limit: 500),
              ),
            )
            .value ??
        const <Driver>[];

    // A new trip with no vehicle chosen yet: take the only/first one.
    if (_vehicleId == null && vehicles.isNotEmpty && !widget.editing) {
      _vehicleId = vehicles.first.id;
    }
    final vehicleId = _vehicleId;
    final assignment = vehicleId == null
        ? null
        : ref.watch(activeAssignmentProvider(vehicleId)).value;
    // Default the driver to whoever is assigned, until the user picks.
    if (!_driverTouched && assignment != null) {
      _driverId = assignment.assignment.driverId;
    }

    if (vehicles.isEmpty && !widget.editing) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.newTrip)),
        body: EmptyState(
          icon: Icons.directions_car_outlined,
          title: l10n.needVehicleFirst,
          action: BigButton(
            label: l10n.addVehicle,
            icon: Icons.add,
            onPressed: () => context.push('/vehicles/new'),
          ),
        ),
      );
    }

    final pay = _effectivePay(assignment);
    final profit = tripProfit(fare: _fare, expenses: _drafts, driverPay: pay);
    String categoryOf(String id) {
      final c =
          categories.where((c) => c.id == id).firstOrNull ??
          ref
              .watch(allCategoriesProvider)
              .value
              ?.where((c) => c.id == id)
              .firstOrNull;
      return c == null ? '' : l10n.categoryLabel(c);
    }

    ExpenseCategory? cat(DefaultCategory k) =>
        categories.where((c) => c.key == k).firstOrNull;
    final chipCategories = [
      (cat(DefaultCategory.fuel), Icons.local_gas_station_outlined),
      (cat(DefaultCategory.toll), Icons.toll_outlined),
      (cat(DefaultCategory.parking), Icons.local_parking_outlined),
      (cat(DefaultCategory.helper), Icons.engineering_outlined),
    ];

    const gap = SizedBox(height: Spacing.md);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editing ? l10n.editTrip : l10n.newTrip),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(Spacing.gutter),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (vehicles.length > 1 || widget.editing)
                      DropdownButtonFormField<String>(
                        initialValue: vehicles.any((v) => v.id == vehicleId)
                            ? vehicleId
                            : null,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: l10n.payVehicle,
                          errorText: _vehicleError,
                          border: const OutlineInputBorder(),
                        ),
                        items: [
                          for (final v in vehicles)
                            DropdownMenuItem(
                              value: v.id,
                              child: Text(v.nickname),
                            ),
                        ],
                        onChanged: (id) => setState(() {
                          _vehicleId = id;
                          _driverTouched = false;
                          _invalidatePay();
                        }),
                      )
                    else
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.directions_car_outlined),
                        title: Text(vehicles.first.nickname),
                      ),
                    gap,
                    AmountTile(
                      label: l10n.tripFare,
                      amountText: _fare.isPositive
                          ? formatter.money(_fare)
                          : null,
                      hint: l10n.tapToEnter,
                      errorText: _fareError,
                      emphasis: true,
                      onTap: _pickFare,
                    ),
                    const SizedBox(height: Spacing.lg),
                    Text(l10n.expensesTitle, style: theme.textTheme.titleSmall),
                    const SizedBox(height: Spacing.sm),
                    QuickChips<String>(
                      onSelected: (value) {
                        if (value == '__more__') {
                          unawaited(_moreExpense(categories));
                        } else {
                          final c = categories.firstWhere((c) => c.id == value);
                          unawaited(_quickExpense(c.id, l10n.categoryLabel(c)));
                        }
                      },
                      chips: [
                        for (final (c, icon) in chipCategories)
                          if (c != null)
                            QuickChipData(
                              value: c.id,
                              label: l10n.categoryLabel(c),
                              icon: icon,
                            ),
                        QuickChipData(
                          value: '__more__',
                          label: l10n.addExpenseMore,
                          icon: Icons.more_horiz,
                        ),
                      ],
                    ),
                    if (_expenses.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: Spacing.sm),
                        child: Text(
                          l10n.noExpenses,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ),
                    for (final line in _expenses)
                      ListTile(
                        key: ObjectKey(line),
                        contentPadding: EdgeInsets.zero,
                        minTileHeight: 56,
                        title: Text(categoryOf(line.draft.categoryId)),
                        subtitle: line.draft.paidBy == PaidBy.owner
                            ? null
                            : Text(l10n.paidByName(line.draft.paidBy)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              formatter.money(line.draft.amount),
                              style: theme.textTheme.titleMedium,
                            ),
                            IconButton(
                              tooltip: l10n.deleteLabel,
                              icon: const Icon(Icons.close),
                              onPressed: () => setState(() {
                                _expenses.remove(line);
                                _invalidatePay();
                              }),
                            ),
                          ],
                        ),
                        onTap: () => _editExpense(line),
                      ),
                    const SizedBox(height: Spacing.md),
                    Text(l10n.paymentTitle, style: theme.textTheme.titleSmall),
                    const SizedBox(height: Spacing.sm),
                    SegmentedButton<_Payment>(
                      showSelectedIcon: false,
                      segments: [
                        ButtonSegment(
                          value: _Payment.paid,
                          label: Text(l10n.payPaid),
                        ),
                        ButtonSegment(
                          value: _Payment.partial,
                          label: Text(l10n.payPartial),
                        ),
                        ButtonSegment(
                          value: _Payment.unpaid,
                          label: Text(l10n.payUnpaid),
                        ),
                      ],
                      selected: {_payment},
                      onSelectionChanged: (s) => setState(() {
                        _payment = s.first;
                        _receivedError = null;
                      }),
                    ),
                    if (_payment == _Payment.partial) ...[
                      gap,
                      AmountTile(
                        label: l10n.amountReceived,
                        amountText: _received.isPositive
                            ? formatter.money(_received)
                            : null,
                        hint: l10n.tapToEnter,
                        errorText: _receivedError,
                        onTap: _pickReceived,
                      ),
                    ],
                    const SizedBox(height: Spacing.lg),
                    _ProfitCard(profit: profit, formatter: formatter),
                    gap,
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.driverPayLabel),
                      subtitle: Text(
                        _payOverride != null
                            ? l10n.driverPayCustom
                            : l10n.driverPayAuto,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            formatter.money(pay),
                            style: theme.textTheme.titleMedium,
                          ),
                          if (_payOverride != null)
                            IconButton(
                              tooltip: l10n.resetToAuto,
                              icon: const Icon(Icons.restart_alt),
                              onPressed: () => setState(() {
                                _payOverride = null;
                                _frozenPay = null;
                              }),
                            ),
                          IconButton(
                            tooltip: l10n.editLabel,
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () => _pickPayOverride(assignment),
                          ),
                        ],
                      ),
                    ),
                    gap,
                    if (drivers.isNotEmpty)
                      DropdownButtonFormField<String?>(
                        initialValue: drivers.any((d) => d.id == _driverId)
                            ? _driverId
                            : null,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: l10n.selectDriver,
                          border: const OutlineInputBorder(),
                        ),
                        hint: Text(l10n.noDriverOption),
                        items: [
                          DropdownMenuItem<String?>(
                            child: Text(l10n.noDriverOption),
                          ),
                          for (final d in drivers)
                            DropdownMenuItem<String?>(
                              value: d.id,
                              child: Text(d.name),
                            ),
                        ],
                        onChanged: (id) => setState(() {
                          _driverId = id;
                          _driverTouched = true;
                          _invalidatePay();
                        }),
                      ),
                    gap,
                    Row(
                      children: [
                        Expanded(
                          child: PlaceField(
                            controller: _from,
                            label: '${l10n.tripFrom} (${l10n.optional})',
                          ),
                        ),
                        const SizedBox(width: Spacing.sm),
                        Expanded(
                          child: PlaceField(
                            controller: _to,
                            label: '${l10n.tripTo} (${l10n.optional})',
                          ),
                        ),
                      ],
                    ),
                    gap,
                    TextField(
                      controller: _distance,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp('[0-9০-৯.,]')),
                        LengthLimitingTextInputFormatter(10),
                      ],
                      decoration: InputDecoration(
                        labelText: '${l10n.tripDistance} (${l10n.optional})',
                        errorText: _distanceError,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    gap,
                    InkWell(
                      onTap: _pickWhen,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: l10n.tripWhen,
                          border: const OutlineInputBorder(),
                          suffixIcon: const Icon(Icons.schedule),
                        ),
                        child: Text(
                          '${formatDay(formatter, CalendarDay.fromDate(_startedAt))}  '
                          '${formatter.digits('${_startedAt.hour.toString().padLeft(2, '0')}:${_startedAt.minute.toString().padLeft(2, '0')}')}',
                        ),
                      ),
                    ),
                    gap,
                    TextField(
                      controller: _load,
                      decoration: InputDecoration(
                        labelText: '${l10n.tripLoad} (${l10n.optional})',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    gap,
                    TextField(
                      controller: _note,
                      decoration: InputDecoration(
                        labelText: l10n.advanceNote,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    if (_saveError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: Spacing.md),
                        child: Text(
                          _saveError!,
                          style: TextStyle(color: theme.colorScheme.error),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Spacing.gutter,
                Spacing.sm,
                Spacing.gutter,
                Spacing.md,
              ),
              child: BigButton(
                label: l10n.save,
                icon: Icons.check,
                onPressed: _saving ? null : () => _save(assignment),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfitCard extends StatelessWidget {
  const new({required this.profit, required this.formatter});

  final TripProfit profit;
  final NumberFormatter formatter;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    Widget row(String label, Money value, {bool bold = false}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: bold ? theme.textTheme.titleMedium : null,
            ),
          ),
          if (bold)
            AmountText(amount: value, formatter: formatter)
          else
            Text(formatter.money(value)),
        ],
      ),
    );

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          children: [
            row(l10n.tripFare, profit.fare),
            row(l10n.expensesTitle, -profit.expenses),
            row(l10n.driverPayLabel, -profit.driverPay),
            const Divider(),
            row(
              profit.profit.isNegative ? l10n.lossLabel : l10n.profitLabel,
              profit.profit,
              bold: true,
            ),
          ],
        ),
      ),
    );
  }
}

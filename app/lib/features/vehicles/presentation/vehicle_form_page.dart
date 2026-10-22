import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vehicle_khata/app/l10n_labels.dart';
import 'package:vehicle_khata/app/providers/feature_providers.dart';
import 'package:vehicle_khata/app/providers/providers.dart';
import 'package:vehicle_khata/app/ui/tokens.dart';
import 'package:vehicle_khata/app/ui/vehicle_icons.dart';
import 'package:vehicle_khata/app/ui/widgets/big_button.dart';
import 'package:vehicle_khata/app/ui/widgets/empty_state.dart';
import 'package:vehicle_khata/core/money/money.dart';
import 'package:vehicle_khata/features/vehicles/data/photo_store.dart';
import 'package:vehicle_khata/features/vehicles/domain/vehicle.dart';
import 'package:vehicle_khata/features/vehicles/domain/vehicle_enums.dart';
import 'package:vehicle_khata/features/vehicles/domain/vehicle_rules.dart';
import 'package:vehicle_khata/features/vehicles/presentation/vehicle_photo.dart';
import 'package:vehicle_khata/l10n/gen/app_localizations.dart';

/// Add (vehicleId == null) or edit a vehicle.
class VehicleFormPage extends ConsumerWidget {
  const new({this.vehicleId, super.key});

  final String? vehicleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final id = vehicleId;
    if (id == null) return const _VehicleForm();

    return ref
        .watch(vehicleProvider(id))
        .when(
          loading: () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (_, _) => Scaffold(
            appBar: AppBar(),
            body: EmptyState(icon: Icons.error_outline, title: l10n.errUnknown),
          ),
          data: (v) => v == null
              ? Scaffold(
                  appBar: AppBar(),
                  body: EmptyState(
                    icon: Icons.search_off,
                    title: l10n.vehicleNotFound,
                  ),
                )
              : _VehicleForm(existing: v),
        );
  }
}

class _VehicleForm extends ConsumerStatefulWidget {
  const new({this.existing});

  final Vehicle? existing;

  @override
  ConsumerState<_VehicleForm> createState() => _VehicleFormState();
}

class _VehicleFormState extends ConsumerState<_VehicleForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nickname;
  late final TextEditingController _regNo;
  late final TextEditingController _model;
  late final TextEditingController _year;
  late final TextEditingController _price;

  late VehicleType _type;
  late FuelType _fuel;
  late BusinessModel _businessModel;
  late VehicleStatus _status;
  DateTime? _purchaseDate;

  /// Photo currently shown, and photos added in this session (to clean up).
  String? _photoFile;
  final _addedPhotos = <String>[];
  String? _originalPhoto;

  late final PhotoStore _photoStore;

  Vehicle? _duplicate;
  Timer? _debounce;
  bool _saving = false;
  bool _saved = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _photoStore = ref.read(photoStoreProvider);
    final v = widget.existing;
    _nickname = TextEditingController(text: v?.nickname ?? '');
    _regNo = TextEditingController(text: v?.regNo ?? '');
    _model = TextEditingController(text: v?.model ?? '');
    _year = TextEditingController(text: v?.year?.toString() ?? '');
    _price = TextEditingController(
      text: v?.purchasePrice == null ? '' : '${v!.purchasePrice!.minor ~/ 100}',
    );
    _type = v?.type ?? VehicleType.cng;
    _fuel = v?.fuelType ?? _type.defaultFuel;
    _businessModel = v?.businessModel ?? _type.defaultModel;
    _status = v?.status ?? VehicleStatus.active;
    _purchaseDate = v?.purchaseDate;
    _photoFile = v?.photoFile;
    _originalPhoto = v?.photoFile;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    // Remove photos picked but never saved.
    if (!_saved) {
      for (final f in _addedPhotos) {
        unawaited(_photoStore.delete(f));
      }
    }
    _nickname.dispose();
    _regNo.dispose();
    _model.dispose();
    _year.dispose();
    _price.dispose();
    super.dispose();
  }

  void _onRegNoChanged(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      final dup = await ref
          .read(vehicleRepositoryProvider)
          .findByRegNo(text, excludingId: widget.existing?.id);
      if (mounted) setState(() => _duplicate = dup);
    });
  }

  Future<void> _pickPhoto(PhotoSource source) async {
    final path = await ref.read(photoPickerProvider).pick(source);
    if (path == null) return;
    final name = await _photoStore.save(path);
    if (!mounted) return;
    setState(() {
      _photoFile = name;
      _addedPhotos.add(name);
    });
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
            if (_photoFile != null)
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
        await _pickPhoto(PhotoSource.camera);
      case 'gallery':
        await _pickPhoto(PhotoSource.gallery);
      case 'remove':
        setState(() => _photoFile = null);
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _purchaseDate ?? now,
      firstDate: DateTime(1970),
      lastDate: now,
    );
    if (picked != null) setState(() => _purchaseDate = picked);
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);

    final priceText = _price.text.trim();
    final draft = VehicleDraft(
      nickname: _nickname.text,
      type: _type,
      fuelType: _fuel,
      businessModel: _businessModel,
      status: _status,
      regNo: _regNo.text,
      model: _model.text,
      year: int.tryParse(_year.text.trim()),
      photoFile: _photoFile,
      purchaseDate: _purchaseDate,
      purchasePrice: priceText.isEmpty
          ? null
          : Money.taka(int.parse(priceText)),
    );

    final repo = ref.read(vehicleRepositoryProvider);
    final id = widget.existing?.id;
    if (id == null) {
      await repo.create(draft);
    } else {
      await repo.update(id, draft);
    }
    _saved = true;

    // Remove replaced/removed original and any picked-then-discarded photos.
    final store = _photoStore;
    if (_originalPhoto != null && _originalPhoto != _photoFile) {
      await store.delete(_originalPhoto);
    }
    for (final f in _addedPhotos.where((f) => f != _photoFile)) {
      await store.delete(f);
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).vehicleSaved)),
    );
    // Deep links open the form with nothing to pop back to.
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final formatter = ref.watch(numberFormatterProvider);

    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? l10n.editVehicle : l10n.newVehicle)),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(Spacing.gutter),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Column(
                          children: [
                            VehiclePhoto(
                              type: _type,
                              photoFile: _photoFile,
                              size: 96,
                            ),
                            TextButton.icon(
                              onPressed: _photoMenu,
                              icon: const Icon(Icons.photo_camera_outlined),
                              label: Text(l10n.photo),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: Spacing.md),
                      TextFormField(
                        controller: _nickname,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: l10n.vehicleNickname,
                          hintText: l10n.vehicleNicknameHint,
                          border: const OutlineInputBorder(),
                        ),
                        validator: (v) =>
                            switch (VehicleRules.validateNickname(v ?? '')) {
                              NicknameError.empty => l10n.errNicknameEmpty,
                              NicknameError.tooLong => l10n.errNicknameTooLong(
                                formatter.digits(
                                  '${VehicleRules.maxNicknameLength}',
                                ),
                              ),
                              null => null,
                            },
                      ),
                      const SizedBox(height: Spacing.lg),
                      Text(l10n.vehicleType, style: theme.textTheme.titleSmall),
                      const SizedBox(height: Spacing.sm),
                      Wrap(
                        spacing: Spacing.sm,
                        runSpacing: Spacing.sm,
                        children: [
                          for (final t in VehicleType.values)
                            ChoiceChip(
                              avatar: Icon(vehicleIcon(t), size: 20),
                              label: Text(l10n.vehicleTypeName(t)),
                              selected: _type == t,
                              onSelected: (_) => setState(() {
                                _type = t;
                                if (!_isEdit) {
                                  _fuel = t.defaultFuel;
                                  _businessModel = t.defaultModel;
                                }
                              }),
                            ),
                        ],
                      ),
                      const SizedBox(height: Spacing.lg),
                      TextFormField(
                        controller: _regNo,
                        textInputAction: TextInputAction.next,
                        textCapitalization: TextCapitalization.characters,
                        onChanged: _onRegNoChanged,
                        decoration: InputDecoration(
                          labelText: '${l10n.regNo} (${l10n.optional})',
                          border: const OutlineInputBorder(),
                          helperText: _duplicate == null
                              ? null
                              : l10n.dupRegWarning(_duplicate!.nickname),
                          helperMaxLines: 2,
                          helperStyle: TextStyle(
                            color: theme.colorScheme.tertiary,
                          ),
                          suffixIcon: _duplicate == null
                              ? null
                              : Icon(
                                  Icons.warning_amber_rounded,
                                  color: theme.colorScheme.tertiary,
                                ),
                        ),
                      ),
                      const SizedBox(height: Spacing.md),
                      TextFormField(
                        controller: _model,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: '${l10n.vehicleModel} (${l10n.optional})',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: Spacing.md),
                      TextFormField(
                        controller: _year,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                        ],
                        decoration: InputDecoration(
                          labelText: '${l10n.vehicleYear} (${l10n.optional})',
                          border: const OutlineInputBorder(),
                        ),
                        validator: (v) {
                          final text = (v ?? '').trim();
                          if (text.isEmpty) return null;
                          return VehicleRules.isValidYear(
                                int.tryParse(text),
                                currentYear: DateTime.now().year,
                              )
                              ? null
                              : l10n.errYearInvalid;
                        },
                      ),
                      const SizedBox(height: Spacing.lg),
                      Text(l10n.fuelType, style: theme.textTheme.titleSmall),
                      const SizedBox(height: Spacing.sm),
                      Wrap(
                        spacing: Spacing.sm,
                        runSpacing: Spacing.sm,
                        children: [
                          for (final f in FuelType.values)
                            ChoiceChip(
                              label: Text(l10n.fuelName(f)),
                              selected: _fuel == f,
                              onSelected: (_) => setState(() => _fuel = f),
                            ),
                        ],
                      ),
                      const SizedBox(height: Spacing.lg),
                      DropdownButtonFormField<BusinessModel>(
                        initialValue: _businessModel,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: l10n.businessModel,
                          border: const OutlineInputBorder(),
                        ),
                        items: [
                          for (final m in BusinessModel.values)
                            DropdownMenuItem(
                              value: m,
                              child: Text(l10n.modelName(m)),
                            ),
                        ],
                        onChanged: (m) {
                          if (m != null) setState(() => _businessModel = m);
                        },
                      ),
                      if (_isEdit) ...[
                        const SizedBox(height: Spacing.lg),
                        Text(
                          l10n.statusLabel,
                          style: theme.textTheme.titleSmall,
                        ),
                        const SizedBox(height: Spacing.sm),
                        SegmentedButton<VehicleStatus>(
                          showSelectedIcon: false,
                          segments: [
                            for (final s in VehicleStatus.values)
                              ButtonSegment(
                                value: s,
                                label: Text(l10n.statusName(s)),
                              ),
                          ],
                          selected: {_status},
                          onSelectionChanged: (s) =>
                              setState(() => _status = s.first),
                        ),
                      ],
                      const SizedBox(height: Spacing.lg),
                      InkWell(
                        onTap: _pickDate,
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText:
                                '${l10n.purchaseDate} (${l10n.optional})',
                            border: const OutlineInputBorder(),
                            suffixIcon: const Icon(
                              Icons.calendar_today_outlined,
                            ),
                          ),
                          child: Text(
                            _purchaseDate == null
                                ? ''
                                : formatter.digits(_formatDate(_purchaseDate!)),
                          ),
                        ),
                      ),
                      const SizedBox(height: Spacing.md),
                      TextFormField(
                        controller: _price,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        decoration: InputDecoration(
                          labelText: '${l10n.purchasePrice} (${l10n.optional})',
                          border: const OutlineInputBorder(),
                        ),
                        validator: (v) {
                          final text = (v ?? '').trim();
                          return text.isEmpty || int.tryParse(text) != null
                              ? null
                              : l10n.errPriceInvalid;
                        },
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
                  onPressed: _saving ? null : _save,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

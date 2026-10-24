import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vehicle_khata/app/providers/feature_providers.dart';
import 'package:vehicle_khata/app/providers/providers.dart';
import 'package:vehicle_khata/app/ui/format.dart';
import 'package:vehicle_khata/app/ui/tokens.dart';
import 'package:vehicle_khata/app/ui/widgets/big_button.dart';
import 'package:vehicle_khata/app/ui/widgets/empty_state.dart';
import 'package:vehicle_khata/core/time/calendar_day.dart';
import 'package:vehicle_khata/features/drivers/domain/driver.dart';
import 'package:vehicle_khata/features/drivers/domain/driver_rules.dart';
import 'package:vehicle_khata/features/drivers/presentation/driver_avatar.dart';
import 'package:vehicle_khata/features/vehicles/data/photo_store.dart';
import 'package:vehicle_khata/l10n/gen/app_localizations.dart';

/// Add (driverId == null) or edit a driver.
class DriverFormPage extends ConsumerStatefulWidget {
  const new({this.driverId, super.key});

  final String? driverId;

  @override
  ConsumerState<DriverFormPage> createState() => _DriverFormPageState();
}

class _DriverFormPageState extends ConsumerState<DriverFormPage> {
  Future<Driver?>? _load;

  @override
  void initState() {
    super.initState();
    final id = widget.driverId;
    if (id != null) _load = ref.read(driverRepositoryProvider).get(id);
  }

  @override
  Widget build(BuildContext context) {
    if (_load == null) return const _DriverForm();
    final l10n = AppLocalizations.of(context);
    return FutureBuilder<Driver?>(
      future: _load,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final driver = snap.data;
        if (driver == null) {
          return Scaffold(
            appBar: AppBar(),
            body: EmptyState(
              icon: Icons.search_off,
              title: l10n.driverNotFound,
            ),
          );
        }
        return _DriverForm(existing: driver);
      },
    );
  }
}

class _DriverForm extends ConsumerStatefulWidget {
  const new({this.existing});

  final Driver? existing;

  @override
  ConsumerState<_DriverForm> createState() => _DriverFormState();
}

class _DriverFormState extends ConsumerState<_DriverForm> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.existing?.name);
  late final _phone = TextEditingController(text: widget.existing?.phone);
  late final _license = TextEditingController(text: widget.existing?.licenseNo);
  late final _nid = TextEditingController(text: widget.existing?.nid);
  late final _address = TextEditingController(text: widget.existing?.address);
  late final _emergency = TextEditingController(
    text: widget.existing?.emergencyContact,
  );
  late CalendarDay? _licenseExpiry = widget.existing?.licenseExpiry;
  late CalendarDay? _joinDate = widget.existing?.joinDate;
  late String? _photoFile = widget.existing?.photoFile;
  late final PhotoStore _photoStore;
  final _addedPhotos = <String>[];
  bool _saving = false;
  bool _saved = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _photoStore = ref.read(photoStoreProvider);
  }

  @override
  void dispose() {
    if (!_saved) {
      for (final f in _addedPhotos) {
        unawaited(_photoStore.delete(f));
      }
    }
    for (final c in [_name, _phone, _license, _nid, _address, _emergency]) {
      c.dispose();
    }
    super.dispose();
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
      useRootNavigator: true,
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

  Future<CalendarDay?> _pickDay(
    CalendarDay? initial, {
    bool future = false,
  }) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial?.toDate() ?? now,
      firstDate: DateTime(1970),
      lastDate: future ? DateTime(now.year + 30) : now,
    );
    return picked == null ? null : CalendarDay.fromDate(picked);
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    final draft = DriverDraft(
      name: _name.text,
      phone: _phone.text,
      licenseNo: _license.text,
      licenseExpiry: _licenseExpiry,
      nid: _nid.text,
      address: _address.text,
      emergencyContact: _emergency.text,
      joinDate: _joinDate,
      photoFile: _photoFile,
      status: widget.existing?.status ?? DriverStatus.active,
    );
    final repo = ref.read(driverRepositoryProvider);
    final id = widget.existing?.id;
    if (id == null) {
      await repo.create(draft);
    } else {
      await repo.update(id, draft);
    }
    _saved = true;

    final original = widget.existing?.photoFile;
    if (original != null && original != _photoFile) {
      await _photoStore.delete(original);
    }
    for (final f in _addedPhotos.where((f) => f != _photoFile)) {
      await _photoStore.delete(f);
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).driverSaved)),
    );
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/drivers');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final formatter = ref.watch(numberFormatterProvider);

    Widget dateField(
      String label,
      CalendarDay? value,
      ValueChanged<CalendarDay> onPicked, {
      bool future = false,
    }) => InkWell(
      onTap: () async {
        final picked = await _pickDay(value, future: future);
        if (picked != null) onPicked(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: '$label (${l10n.optional})',
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today_outlined),
        ),
        child: Text(value == null ? '' : formatDay(formatter, value)),
      ),
    );

    const gap = SizedBox(height: Spacing.md);
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? l10n.editDriver : l10n.newDriver)),
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
                            DriverAvatar(
                              name: _name.text,
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
                      TextFormField(
                        controller: _name,
                        textInputAction: TextInputAction.next,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          labelText: l10n.driverName,
                          border: const OutlineInputBorder(),
                        ),
                        onChanged: (_) => setState(() {}),
                        validator: (v) => switch (DriverRules.validateName(
                          v ?? '',
                        )) {
                          DriverNameError.empty => l10n.errNameEmpty,
                          DriverNameError.tooLong => l10n.errNameTooLong(
                            formatter.digits('${DriverRules.maxNameLength}'),
                          ),
                          null => null,
                        },
                      ),
                      gap,
                      TextFormField(
                        controller: _phone,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[0-9০-৯+\s\-]'),
                          ),
                          LengthLimitingTextInputFormatter(20),
                        ],
                        decoration: InputDecoration(
                          labelText: '${l10n.phoneLabel} (${l10n.optional})',
                          hintText: l10n.phoneHint,
                          border: const OutlineInputBorder(),
                        ),
                        validator: (v) => DriverRules.isValidPhone(v)
                            ? null
                            : l10n.errInvalidPhone,
                      ),
                      gap,
                      TextFormField(
                        controller: _license,
                        textInputAction: TextInputAction.next,
                        textCapitalization: TextCapitalization.characters,
                        decoration: InputDecoration(
                          labelText: '${l10n.licenseNo} (${l10n.optional})',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      gap,
                      dateField(
                        l10n.licenseExpiry,
                        _licenseExpiry,
                        (d) => setState(() => _licenseExpiry = d),
                        future: true,
                      ),
                      gap,
                      TextFormField(
                        controller: _nid,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[0-9০-৯\s\-]'),
                          ),
                          LengthLimitingTextInputFormatter(24),
                        ],
                        decoration: InputDecoration(
                          labelText: '${l10n.nid} (${l10n.optional})',
                          helperText: l10n.nidHelper,
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: const OutlineInputBorder(),
                        ),
                        validator: (v) => DriverRules.isValidNid(v)
                            ? null
                            : l10n.errNidInvalid,
                      ),
                      gap,
                      TextFormField(
                        controller: _address,
                        textInputAction: TextInputAction.next,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: '${l10n.address} (${l10n.optional})',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      gap,
                      TextFormField(
                        controller: _emergency,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          labelText:
                              '${l10n.emergencyContact} (${l10n.optional})',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      gap,
                      dateField(
                        l10n.joinDate,
                        _joinDate,
                        (d) => setState(() => _joinDate = d),
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
}

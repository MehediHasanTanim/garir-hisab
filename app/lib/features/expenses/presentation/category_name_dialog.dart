import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vehicle_khata/app/l10n_labels.dart';
import 'package:vehicle_khata/app/providers/feature_providers.dart';
import 'package:vehicle_khata/features/expenses/data/category_repository.dart';
import 'package:vehicle_khata/features/expenses/domain/expense.dart';
import 'package:vehicle_khata/l10n/gen/app_localizations.dart';

/// Asks for a category name and creates it (or renames [existing]). Returns
/// the category id, or null if cancelled.
Future<String?> showCategoryNameDialog(
  BuildContext context, {
  ExpenseCategory? existing,
}) => showDialog<String>(
  context: context,
  builder: (_) => _CategoryNameDialog(existing: existing),
);

/// Owns its controller so it is disposed only after the dialog has fully
/// closed (disposing it right after `showDialog` returns breaks the exit
/// animation).
class _CategoryNameDialog extends ConsumerStatefulWidget {
  const new({this.existing});

  final ExpenseCategory? existing;

  @override
  ConsumerState<_CategoryNameDialog> createState() =>
      _CategoryNameDialogState();
}

class _CategoryNameDialogState extends ConsumerState<_CategoryNameDialog> {
  late final _controller = TextEditingController(text: widget.existing?.name);
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final repo = ref.read(categoryRepositoryProvider);
    try {
      final existing = widget.existing;
      final String id;
      if (existing == null) {
        id = await repo.createCustom(_controller.text);
      } else {
        await repo.rename(existing.id, _controller.text);
        id = existing.id;
      }
      if (mounted) Navigator.pop(context, id);
    } on CategoryException catch (e) {
      if (mounted) setState(() => _error = l10n.categoryError(e.error));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(
        widget.existing == null ? l10n.newCategory : l10n.renameCategory,
      ),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(
          labelText: l10n.categoryName,
          errorText: _error,
          border: const OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(onPressed: _save, child: Text(l10n.save)),
      ],
    );
  }
}

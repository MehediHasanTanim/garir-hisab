import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vehicle_khata/app/l10n_labels.dart';
import 'package:vehicle_khata/app/providers/feature_providers.dart';
import 'package:vehicle_khata/app/ui/tokens.dart';
import 'package:vehicle_khata/features/expenses/presentation/category_name_dialog.dart';
import 'package:vehicle_khata/l10n/gen/app_localizations.dart';

/// Manage expense categories: add your own, rename them, archive any.
class CategoriesPage extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final categories = ref.watch(allCategoriesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.expenseCategories)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showCategoryNameDialog(context),
        icon: const Icon(Icons.add),
        label: Text(l10n.addCategory),
      ),
      body: categories.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(child: Text(l10n.errUnknown)),
        data: (list) => ListView(
          padding: const EdgeInsets.only(bottom: 96),
          children: [
            Padding(
              padding: const EdgeInsets.all(Spacing.gutter),
              child: Text(
                l10n.categoriesHint,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            for (final c in list)
              SwitchListTile(
                key: ValueKey(c.id),
                title: Text(l10n.categoryLabel(c)),
                subtitle: c.archived ? Text(l10n.statusArchived) : null,
                // On = in use; off = archived.
                value: !c.archived,
                secondary: c.isCustom
                    ? IconButton(
                        tooltip: l10n.renameCategory,
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () =>
                            showCategoryNameDialog(context, existing: c),
                      )
                    : const Icon(Icons.label_outline),
                onChanged: (on) => ref
                    .read(categoryRepositoryProvider)
                    .setArchived(c.id, archived: !on),
              ),
          ],
        ),
      ),
    );
  }
}

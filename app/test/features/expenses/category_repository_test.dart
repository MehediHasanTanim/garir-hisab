import 'package:flutter_test/flutter_test.dart';
import 'package:vehicle_khata/features/expenses/data/category_repository.dart';
import 'package:vehicle_khata/features/expenses/domain/expense.dart';

import '../../helpers/fixtures.dart';

Matcher _throwsCategory(CategoryError e) =>
    throwsA(isA<CategoryException>().having((x) => x.error, 'error', e));

void main() {
  late Fixture f;
  setUp(() => f = Fixture());
  tearDown(() => f.close());

  test('the built-in categories are created on first use, in order', () async {
    final all = await f.categories.all();
    expect(all.map((c) => c.key), DefaultCategory.values);
    expect(all.first.id, 'default:fuel');
    expect(all.every((c) => !c.isCustom && !c.archived), isTrue);
    expect(all.first.isFuel, isTrue);
  });

  test('seeding is idempotent and keeps user changes', () async {
    await f.categories.all();
    await f.categories.setArchived('default:toll', archived: true);
    // A second repository (e.g. another app start) must not undo that.
    final again = CategoryRepository(f.db);
    final all = await again.all();
    expect(all, hasLength(DefaultCategory.values.length));
    expect(all.firstWhere((c) => c.id == 'default:toll').archived, isTrue);
  });

  test(
    'archived categories are hidden from the active list but still resolve',
    () async {
      await f.categories.setArchived('default:toll', archived: true);
      final active = await f.categories.watch().first;
      expect(active.any((c) => c.id == 'default:toll'), isFalse);
      expect(
        (await f.categories.watch(includeArchived: true).first).any(
          (c) => c.id == 'default:toll',
        ),
        isTrue,
      );
      expect((await f.categories.get('default:toll'))!.archived, isTrue);

      await f.categories.setArchived('default:toll', archived: false);
      expect(
        (await f.categories.watch().first).any((c) => c.id == 'default:toll'),
        isTrue,
      );
    },
  );

  group('custom categories', () {
    test('are added after the built-in ones', () async {
      final id = await f.categories.createCustom('  Car   wash  ');
      final all = await f.categories.all();
      expect(all.last.id, id);
      expect(all.last.name, 'Car wash');
      expect(all.last.isCustom, isTrue);
      expect(all.last.sortOrder, greaterThan(all[all.length - 2].sortOrder));
    });

    test('names must be non-empty and unique (ignoring case)', () async {
      await expectLater(
        f.categories.createCustom('   '),
        _throwsCategory(CategoryError.emptyName),
      );
      await f.categories.createCustom('Car wash');
      await expectLater(
        f.categories.createCustom('car WASH'),
        _throwsCategory(CategoryError.duplicateName),
      );
    });

    test('can be renamed; built-in ones cannot', () async {
      final id = await f.categories.createCustom('Wash');
      await f.categories.rename(id, 'Car wash');
      expect((await f.categories.get(id))!.name, 'Car wash');
      await expectLater(
        f.categories.rename(id, ' '),
        _throwsCategory(CategoryError.emptyName),
      );
      await expectLater(
        f.categories.rename('default:fuel', 'Petrol'),
        _throwsCategory(CategoryError.notCustom),
      );
      // Renaming to its own name is not a duplicate.
      await f.categories.rename(id, 'Car wash');
    });

    test('unknown ids', () async {
      await expectLater(
        f.categories.rename('nope', 'x'),
        _throwsCategory(CategoryError.notFound),
      );
      await expectLater(
        f.categories.setArchived('nope', archived: true),
        _throwsCategory(CategoryError.notFound),
      );
    });
  });

  test('changes are audited', () async {
    final id = await f.categories.createCustom('Wash');
    await f.categories.rename(id, 'Car wash');
    await f.categories.setArchived(id, archived: true);
    expect((await f.audit('expense_category', id)).map((r) => r.action), [
      'create',
      'rename',
      'archive',
    ]);
  });
}

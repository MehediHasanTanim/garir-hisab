import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:vehicle_khata/core/db/app_database.dart';
import 'package:vehicle_khata/core/money/money.dart';
import 'package:vehicle_khata/features/vehicles/data/vehicle_repository.dart';
import 'package:vehicle_khata/features/vehicles/domain/vehicle.dart';
import 'package:vehicle_khata/features/vehicles/domain/vehicle_enums.dart';

VehicleDraft _draft(
  String name, {
  VehicleType type = VehicleType.cng,
  String? regNo,
  String? model,
  VehicleStatus status = VehicleStatus.active,
}) => VehicleDraft(
  nickname: name,
  type: type,
  fuelType: type.defaultFuel,
  businessModel: type.defaultModel,
  regNo: regNo,
  model: model,
  status: status,
);

void main() {
  late AppDatabase db;
  late VehicleRepository repo;

  setUp(() {
    db = AppDatabase.inMemory();
    repo = VehicleRepository(db);
  });
  tearDown(() => db.close());

  Future<List<String>> names([VehicleFilter f = const VehicleFilter()]) async =>
      (await repo.watch(f).first).map((v) => v.nickname).toList();

  test('create then read back every field', () async {
    final id = await repo.create(
      VehicleDraft(
        nickname: '  Rahim   CNG ',
        type: VehicleType.pickup,
        fuelType: FuelType.diesel,
        businessModel: BusinessModel.jama,
        regNo: ' Dhaka Metro  HA 12-3456 ',
        model: ' Tata Ace ',
        year: 2019,
        photoFile: 'p.jpg',
        purchaseDate: DateTime.utc(2020, 3, 4),
        purchasePrice: const Money.taka(650000),
      ),
    );
    final v = (await repo.get(id))!;
    expect(v.nickname, 'Rahim CNG');
    expect(v.type, VehicleType.pickup);
    expect(v.fuelType, FuelType.diesel);
    expect(v.businessModel, BusinessModel.jama);
    expect(v.regNo, 'Dhaka Metro HA 12-3456');
    expect(v.model, 'Tata Ace');
    expect(v.year, 2019);
    expect(v.photoFile, 'p.jpg');
    expect(v.purchaseDate, DateTime.utc(2020, 3, 4));
    expect(v.purchasePrice, const Money.taka(650000));
    expect(v.status, VehicleStatus.active);
    expect(v.archived, isFalse);
  });

  test('blank optional fields are stored as null', () async {
    final id = await repo.create(_draft('A', regNo: '  ', model: ' '));
    final v = (await repo.get(id))!;
    expect(v.regNo, isNull);
    expect(v.model, isNull);
  });

  test('list is newest first', () async {
    await repo.create(_draft('first'));
    await Future<void>.delayed(const Duration(milliseconds: 3));
    await repo.create(_draft('second'));
    expect(await names(), ['second', 'first']);
  });

  group('search', () {
    setUp(() async {
      await repo.create(_draft('Rahim CNG', regNo: 'DM HA 11-1111'));
      await repo.create(
        _draft('Karim Pickup', type: VehicleType.pickup, model: 'Tata Ace'),
      );
      await repo.create(_draft('100% Sure', regNo: 'CTG-22-2222'));
    });

    test('by nickname, case-insensitive', () async {
      expect(await names(const VehicleFilter(query: 'rahim')), ['Rahim CNG']);
    });

    test('by model', () async {
      expect(await names(const VehicleFilter(query: 'ace')), ['Karim Pickup']);
    });

    test('by registration, ignoring spaces and hyphens', () async {
      expect(await names(const VehicleFilter(query: 'dmha111')), ['Rahim CNG']);
      expect(await names(const VehicleFilter(query: 'ctg 22')), ['100% Sure']);
    });

    test('LIKE wildcards are matched literally', () async {
      expect(await names(const VehicleFilter(query: '%')), ['100% Sure']);
      expect(await names(const VehicleFilter(query: '_')), isEmpty);
    });

    test('no match', () async {
      expect(await names(const VehicleFilter(query: 'zzz')), isEmpty);
    });
  });

  test('status filter', () async {
    await repo.create(_draft('Active one'));
    await repo.create(_draft('Garage one', status: VehicleStatus.inGarage));
    expect(await names(const VehicleFilter(status: VehicleStatus.inGarage)), [
      'Garage one',
    ]);
    expect(await names(), hasLength(2));
  });

  test('setStatus changes status', () async {
    final id = await repo.create(_draft('A'));
    await repo.setStatus(id, VehicleStatus.sold);
    expect((await repo.get(id))!.status, VehicleStatus.sold);
  });

  test(
    'archive hides by default, shows with includeArchived, restore works',
    () async {
      final id = await repo.create(_draft('A'));
      await repo.create(_draft('B'));
      await repo.setArchived(id, archived: true);

      expect(await names(), ['B']);
      expect(
        await names(const VehicleFilter(includeArchived: true)),
        hasLength(2),
      );
      expect((await repo.get(id))!.archived, isTrue);

      await repo.setArchived(id, archived: false);
      expect(await names(), hasLength(2));
    },
  );

  test('limit caps the page size', () async {
    for (var i = 0; i < 5; i++) {
      await repo.create(_draft('v$i'));
    }
    expect(await names(const VehicleFilter(limit: 3)), hasLength(3));
    expect(await names(const VehicleFilter(limit: 10)), hasLength(5));
  });

  test('update changes fields and bumps rev / marks dirty', () async {
    final id = await repo.create(_draft('Old', regNo: 'AA 11'));
    await (db.update(db.vehicles)..where((t) => t.id.equals(id))).write(
      const VehiclesCompanion(dirty: Value.absentIfNull(false)),
    );
    final before = await (db.select(
      db.vehicles,
    )..where((t) => t.id.equals(id))).getSingle();

    await repo.update(id, _draft('New', regNo: 'BB 22'));

    final after = await (db.select(
      db.vehicles,
    )..where((t) => t.id.equals(id))).getSingle();
    expect(after.nickname, 'New');
    expect(after.regNo, 'BB 22');
    expect(after.regNoKey, 'bb22');
    expect(after.rev, before.rev + 1);
    expect(after.dirty, isTrue);
    expect(after.updatedAt, greaterThanOrEqualTo(before.updatedAt));
  });

  group('duplicate registration detection', () {
    test('finds a vehicle with an equivalent number', () async {
      final id = await repo.create(_draft('Rahim', regNo: 'DM HA 11-1111'));
      final dup = await repo.findByRegNo('dm-ha 11 1111');
      expect(dup?.id, id);
    });

    test('excludes the vehicle being edited', () async {
      final id = await repo.create(_draft('Rahim', regNo: 'DM HA 11-1111'));
      expect(await repo.findByRegNo('DM HA 11-1111', excludingId: id), isNull);
    });

    test('blank numbers never collide', () async {
      await repo.create(_draft('A'));
      expect(await repo.findByRegNo(''), isNull);
      expect(await repo.findByRegNo(null), isNull);
    });

    test('deleted vehicles are ignored', () async {
      final id = await repo.create(_draft('Gone', regNo: 'X 1'));
      await db.softDelete(db.vehicles, id);
      expect(await repo.findByRegNo('X 1'), isNull);
      expect(await repo.get(id), isNull);
      expect(await names(const VehicleFilter(includeArchived: true)), isEmpty);
    });
  });

  test('countActive excludes deleted rows', () async {
    final id = await repo.create(_draft('A'));
    await repo.create(_draft('B'));
    expect(await repo.countActive(), 2);
    await db.softDelete(db.vehicles, id);
    expect(await repo.countActive(), 1);
  });
}

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:vehicle_khata/features/drivers/data/driver_repository.dart';
import 'package:vehicle_khata/features/drivers/domain/driver.dart';

import '../../helpers/fixtures.dart';

void main() {
  late Fixture f;
  setUp(() => f = Fixture());
  tearDown(() => f.close());

  Future<List<String>> names([
    DriverFilter filter = const DriverFilter(),
  ]) async => (await f.drivers.watch(filter).first).map((d) => d.name).toList();

  test('create then read back every field', () async {
    final id = await f.drivers.create(
      DriverDraft(
        name: '  Abdul   Karim ',
        phone: '017 1234-5678',
        licenseNo: ' DL-123 ',
        licenseExpiry: day(2027, 5, 1),
        nid: '১৯৯০১২৩৪৫৬৭৮৯',
        address: ' Mirpur ',
        emergencyContact: 'Wife 01812345678',
        joinDate: day(2025, 1, 10),
        photoFile: 'p.jpg',
      ),
    );
    final d = (await f.drivers.get(id))!;
    expect(d.name, 'Abdul Karim');
    expect(d.phone, '+8801712345678');
    expect(d.licenseNo, 'DL-123');
    expect(d.licenseExpiry, day(2027, 5, 1));
    expect(d.nid, '1990123456789'); // Bangla digits normalised
    expect(d.hasNid, isTrue);
    expect(d.address, 'Mirpur');
    expect(d.emergencyContact, 'Wife 01812345678');
    expect(d.joinDate, day(2025, 1, 10));
    expect(d.photoFile, 'p.jpg');
    expect(d.status, DriverStatus.active);
  });

  test('the national ID is stored encrypted, never as plaintext', () async {
    final id = await f.driver(nid: '1990123456789');
    final row = await f.db.select(f.db.drivers).getSingle();
    expect(row.id, id);
    expect(row.nidEncrypted, startsWith('v1:'));
    expect(row.nidEncrypted, isNot(contains('1990123456789')));
  });

  test('list rows say a NID exists without exposing it', () async {
    await f.driver(nid: '1990123456789');
    await f.driver(name: 'No Nid');
    final list = await f.drivers.watch(const DriverFilter()).first;
    final withNid = list.firstWhere((d) => d.name == 'Karim');
    expect(withNid.hasNid, isTrue);
    expect(withNid.nid, isNull);
    expect(list.firstWhere((d) => d.name == 'No Nid').hasNid, isFalse);
  });

  test('NID can be changed and removed', () async {
    final id = await f.driver(nid: '1990123456789');
    Future<DriverDraft> draft(String? nid) async =>
        DriverDraft.fromDriver((await f.drivers.get(id))!).copyWithNid(nid);
    await f.drivers.update(id, await draft('9876543210'));
    expect((await f.drivers.get(id))!.nid, '9876543210');
    await f.drivers.update(id, await draft(null));
    final d = (await f.drivers.get(id))!;
    expect(d.nid, isNull);
    expect(d.hasNid, isFalse);
  });

  test(
    'blank optional fields are stored as null; bad phone kept as typed',
    () async {
      final id = await f.drivers.create(
        const DriverDraft(name: 'A', phone: '  ', licenseNo: ' ', address: ''),
      );
      final d = (await f.drivers.get(id))!;
      expect(d.phone, isNull);
      expect(d.licenseNo, isNull);
      expect(d.address, isNull);

      final id2 = await f.drivers.create(
        const DriverDraft(name: 'B', phone: '02-9876543'),
      );
      expect((await f.drivers.get(id2))!.phone, '02-9876543');
    },
  );

  group('search', () {
    setUp(() async {
      await f.driver(name: 'Abdul Karim', phone: '01712345678');
      await f.driver(name: 'Rahim', phone: '01911112222');
      await f.drivers.create(
        const DriverDraft(name: 'Salam', licenseNo: 'DL-99'),
      );
    });

    test('by name, case-insensitive', () async {
      expect(await names(const DriverFilter(query: 'KARIM')), ['Abdul Karim']);
    });

    test('by phone in any common form', () async {
      for (final q in ['01712345678', '+8801712345678', '1712345', '১৭১২৩৪৫']) {
        expect(await names(DriverFilter(query: q)), ['Abdul Karim'], reason: q);
      }
    });

    test('by licence number', () async {
      expect(await names(const DriverFilter(query: 'dl-99')), ['Salam']);
    });

    test('short numeric queries do not match phones by accident', () async {
      expect(await names(const DriverFilter(query: '01')), isEmpty);
    });

    test('wildcards are literal', () async {
      expect(await names(const DriverFilter(query: '%')), isEmpty);
    });
  });

  test('list is alphabetical and filterable by status', () async {
    await f.driver(name: 'Zubair');
    final left = await f.driver(name: 'Arif');
    await f.drivers.setStatus(left, DriverStatus.left);
    expect(await names(), ['Arif', 'Zubair']);
    expect(await names(const DriverFilter(status: DriverStatus.left)), [
      'Arif',
    ]);
    expect(await names(const DriverFilter(status: DriverStatus.active)), [
      'Zubair',
    ]);
  });

  test('limit caps the page', () async {
    for (var i = 0; i < 5; i++) {
      await f.driver(name: 'D$i');
    }
    expect(await names(const DriverFilter(limit: 2)), hasLength(2));
  });

  test('deleted drivers are not returned', () async {
    final id = await f.driver();
    await f.db.softDelete(f.db.drivers, id);
    expect(await f.drivers.get(id), isNull);
    expect(await names(), isEmpty);
  });

  group('audit log', () {
    test('create, update and status changes are recorded', () async {
      final id = await f.driver();
      await f.drivers.update(
        id,
        DriverDraft.fromDriver((await f.drivers.get(id))!)
            .copyWithName('Karim Uddin'),
      );
      await f.drivers.setStatus(id, DriverStatus.left);

      final rows = await f.audit('driver', id);
      expect(rows.map((r) => r.action), ['create', 'update', 'status']);
      final diff = jsonDecode(rows[1].diffJson) as Map<String, Object?>;
      expect(diff['name'], {'from': 'Karim', 'to': 'Karim Uddin'});
      expect(diff.keys, ['name'], reason: 'unchanged fields are omitted');
    });

    test('NID changes are logged without the value', () async {
      final id = await f.driver(nid: '1990123456789');
      await f.drivers.update(
        id,
        DriverDraft.fromDriver((await f.drivers.get(id))!)
            .copyWithNid('9876543210'),
      );
      final rows = await f.audit('driver', id);
      final diff = jsonDecode(rows.last.diffJson) as Map<String, Object?>;
      expect(diff['nid'], {'changed': true});
      for (final r in rows) {
        expect(r.diffJson, isNot(contains('1990123456789')));
        expect(r.diffJson, isNot(contains('9876543210')));
      }
    });

    test('re-saving unchanged data logs an empty diff', () async {
      final id = await f.driver(nid: '1990123456789');
      await f.drivers.update(
        id,
        DriverDraft.fromDriver((await f.drivers.get(id))!),
      );
      final rows = await f.audit('driver', id);
      expect(jsonDecode(rows.last.diffJson), isEmpty);
    });
  });

  test('update bumps rev and marks the row dirty', () async {
    final id = await f.driver();
    final before = await f.db.select(f.db.drivers).getSingle();
    await f.drivers.update(
      id,
      DriverDraft.fromDriver((await f.drivers.get(id))!).copyWithName('New'),
    );
    final after = await f.db.select(f.db.drivers).getSingle();
    expect(after.rev, before.rev + 1);
    expect(after.dirty, isTrue);
  });
}

extension on DriverDraft {
  DriverDraft copyWithName(String name) => DriverDraft(
    name: name,
    status: status,
    phone: phone,
    licenseNo: licenseNo,
    licenseExpiry: licenseExpiry,
    nid: nid,
    address: address,
    emergencyContact: emergencyContact,
    joinDate: joinDate,
    photoFile: photoFile,
  );

  DriverDraft copyWithNid(String? nid) => DriverDraft(
    name: name,
    status: status,
    phone: phone,
    licenseNo: licenseNo,
    licenseExpiry: licenseExpiry,
    nid: nid,
    address: address,
    emergencyContact: emergencyContact,
    joinDate: joinDate,
    photoFile: photoFile,
  );
}

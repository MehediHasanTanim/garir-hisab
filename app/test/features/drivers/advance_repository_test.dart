import 'package:flutter_test/flutter_test.dart';
import 'package:vehicle_khata/core/money/money.dart';
import 'package:vehicle_khata/features/drivers/data/advance_repository.dart';
import 'package:vehicle_khata/features/drivers/domain/driver.dart';

import '../../helpers/fixtures.dart';

Matcher _throwsAdvance(AdvanceError e) =>
    throwsA(isA<AdvanceException>().having((x) => x.error, 'error', e));

void main() {
  late Fixture f;
  late String driverId;
  setUp(() async {
    f = Fixture();
    driverId = await f.driver();
  });
  tearDown(() => f.close());

  test('gives an advance and lists it newest first', () async {
    await f.advances.give(
      driverId: driverId,
      amount: const Money.taka(2000),
      day: day(2026, 3, 1),
      note: ' Eid ',
    );
    await f.advances.give(
      driverId: driverId,
      amount: const Money.taka(500),
      day: day(2026, 3, 20),
    );
    final list = await f.advances.watchForDriver(driverId).first;
    expect(list.map((a) => a.amount), [
      const Money.taka(500),
      const Money.taka(2000),
    ]);
    expect(list.last.note, 'Eid');
    expect(list.first.note, isNull);
    expect(list.every((a) => a.recovered == Money.zero), isTrue);
    expect(list.first.remaining, const Money.taka(500));
  });

  test(
    'rejects zero or negative amounts and unknown or departed drivers',
    () async {
      for (final bad in [Money.zero, const Money(-100)]) {
        await expectLater(
          f.advances.give(
            driverId: driverId,
            amount: bad,
            day: day(2026, 3, 1),
          ),
          _throwsAdvance(AdvanceError.invalidAmount),
        );
      }
      await expectLater(
        f.advances.give(
          driverId: 'nope',
          amount: const Money.taka(1),
          day: day(2026, 3, 1),
        ),
        _throwsAdvance(AdvanceError.driverNotFound),
      );
      await f.drivers.setStatus(driverId, DriverStatus.left);
      await expectLater(
        f.advances.give(
          driverId: driverId,
          amount: const Money.taka(1),
          day: day(2026, 3, 1),
        ),
        _throwsAdvance(AdvanceError.driverNotFound),
      );
    },
  );

  test('outstanding total and per-advance balances', () async {
    await f.advances.give(
      driverId: driverId,
      amount: const Money.taka(2000),
      day: day(2026, 3, 1),
    );
    await f.advances.give(
      driverId: driverId,
      amount: const Money.taka(1500),
      day: day(2026, 3, 2),
    );
    expect(
      await f.advances.watchOutstandingTotal(driverId).first,
      const Money.taka(3500),
    );
    final out = await f.advances.outstanding(driverId);
    expect(out.map((a) => a.remaining), [
      const Money.taka(1500),
      const Money.taka(2000),
    ]);
  });

  test('advances are per driver', () async {
    final other = await f.driver(name: 'Other');
    await f.advances.give(
      driverId: other,
      amount: const Money.taka(999),
      day: day(2026, 3, 1),
    );
    expect(await f.advances.watchOutstandingTotal(driverId).first, Money.zero);
    expect(await f.advances.outstanding(driverId), isEmpty);
  });

  test('an unrecovered advance can be removed, and is audited', () async {
    final id = await f.advances.give(
      driverId: driverId,
      amount: const Money.taka(100),
      day: day(2026, 3, 1),
    );
    await f.advances.remove(id);
    expect(await f.advances.watchForDriver(driverId).first, isEmpty);
    expect((await f.audit('advance', id)).map((r) => r.action), [
      'create',
      'delete',
    ]);
  });

  test('stream updates when an advance is added', () async {
    final seen = <int>[];
    final sub = f.advances
        .watchForDriver(driverId)
        .listen((l) => seen.add(l.length));
    await Future<void>.delayed(Duration.zero);
    await f.advances.give(
      driverId: driverId,
      amount: const Money.taka(1),
      day: day(2026, 3, 1),
    );
    await Future<void>.delayed(const Duration(milliseconds: 20));
    await sub.cancel();
    expect(seen.last, 1);
  });
}

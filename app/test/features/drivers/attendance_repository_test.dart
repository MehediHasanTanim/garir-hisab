import 'package:flutter_test/flutter_test.dart';
import 'package:vehicle_khata/core/time/calendar_day.dart';
import 'package:vehicle_khata/features/drivers/domain/attendance.dart';

import '../../helpers/fixtures.dart';

void main() {
  late Fixture f;
  late String driverId;
  setUp(() async {
    f = Fixture();
    driverId = await f.driver();
  });
  tearDown(() => f.close());

  final march = DayRange.month(2026, 3);

  Future<Map<CalendarDay, AttendanceStatus>> marks() =>
      f.attendance.forRange(driverId, march);

  test('marks a day and reads it back', () async {
    await f.attendance.mark(
      driverId,
      day(2026, 3, 5),
      AttendanceStatus.present,
    );
    await f.attendance.mark(driverId, day(2026, 3, 6), AttendanceStatus.absent);
    await f.attendance.mark(
      driverId,
      day(2026, 3, 7),
      AttendanceStatus.halfDay,
    );
    expect(await marks(), {
      day(2026, 3, 5): AttendanceStatus.present,
      day(2026, 3, 6): AttendanceStatus.absent,
      day(2026, 3, 7): AttendanceStatus.halfDay,
    });
  });

  test('re-marking a day changes its status without a second row', () async {
    await f.attendance.mark(
      driverId,
      day(2026, 3, 5),
      AttendanceStatus.present,
    );
    await f.attendance.mark(driverId, day(2026, 3, 5), AttendanceStatus.absent);
    expect(await marks(), {day(2026, 3, 5): AttendanceStatus.absent});
    expect(await f.db.select(f.db.attendanceRecords).get(), hasLength(1));
  });

  test(
    'clearing removes the mark; marking again revives the same row',
    () async {
      await f.attendance.mark(
        driverId,
        day(2026, 3, 5),
        AttendanceStatus.present,
      );
      await f.attendance.mark(driverId, day(2026, 3, 5), null);
      expect(await marks(), isEmpty);

      await f.attendance.mark(
        driverId,
        day(2026, 3, 5),
        AttendanceStatus.halfDay,
      );
      expect(await marks(), {day(2026, 3, 5): AttendanceStatus.halfDay});
      expect(await f.db.select(f.db.attendanceRecords).get(), hasLength(1));
    },
  );

  test('clearing an unmarked day does nothing', () async {
    await f.attendance.mark(driverId, day(2026, 3, 5), null);
    expect(await f.db.select(f.db.attendanceRecords).get(), isEmpty);
    expect(await f.audit('attendance'), isEmpty);
  });

  test('repeating the same mark writes nothing new', () async {
    await f.attendance.mark(
      driverId,
      day(2026, 3, 5),
      AttendanceStatus.present,
    );
    final before = await f.db.select(f.db.attendanceRecords).getSingle();
    await f.attendance.mark(
      driverId,
      day(2026, 3, 5),
      AttendanceStatus.present,
    );
    final after = await f.db.select(f.db.attendanceRecords).getSingle();
    expect(after.rev, before.rev);
    expect(await f.audit('attendance'), hasLength(1));
  });

  test('range queries are inclusive and per driver', () async {
    final other = await f.driver(name: 'Other');
    await f.attendance.mark(
      driverId,
      day(2026, 2, 28),
      AttendanceStatus.present,
    );
    await f.attendance.mark(
      driverId,
      day(2026, 3, 1),
      AttendanceStatus.present,
    );
    await f.attendance.mark(
      driverId,
      day(2026, 3, 31),
      AttendanceStatus.present,
    );
    await f.attendance.mark(
      driverId,
      day(2026, 4, 1),
      AttendanceStatus.present,
    );
    await f.attendance.mark(other, day(2026, 3, 15), AttendanceStatus.absent);
    expect((await marks()).keys, [day(2026, 3, 1), day(2026, 3, 31)]);
  });

  test('watchRange emits as marks change', () async {
    final stream = f.attendance.watchRange(driverId, march);
    final emissions = <int>[];
    final sub = stream.listen((m) => emissions.add(m.length));
    await Future<void>.delayed(Duration.zero);
    await f.attendance.mark(
      driverId,
      day(2026, 3, 1),
      AttendanceStatus.present,
    );
    await f.attendance.mark(driverId, day(2026, 3, 2), AttendanceStatus.absent);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    await sub.cancel();
    expect(emissions.last, 2);
  });

  test('changes are audited', () async {
    await f.attendance.mark(
      driverId,
      day(2026, 3, 5),
      AttendanceStatus.present,
    );
    await f.attendance.mark(driverId, day(2026, 3, 5), AttendanceStatus.absent);
    await f.attendance.mark(driverId, day(2026, 3, 5), null);
    expect((await f.audit('attendance')).map((r) => r.action), [
      'create',
      'update',
      'clear',
    ]);
  });
}

import 'package:meta/meta.dart';
import 'package:vehicle_khata/core/money/money.dart';
import 'package:vehicle_khata/core/time/calendar_day.dart';
import 'package:vehicle_khata/features/drivers/domain/pay_model.dart';

enum DriverStatus { active, left }

@immutable
class Driver {
  const new({
    required this.id,
    required this.name,
    required this.status,
    required this.createdAt,
    this.phone,
    this.licenseNo,
    this.licenseExpiry,
    this.hasNid = false,
    this.nid,
    this.address,
    this.emergencyContact,
    this.joinDate,
    this.photoFile,
  });

  final String id;
  final String name;
  final DriverStatus status;
  final DateTime createdAt;

  /// E.164 when it is a valid Bangladesh number, otherwise as typed.
  final String? phone;
  final String? licenseNo;
  final CalendarDay? licenseExpiry;

  /// Whether a national ID is stored. The number itself is only loaded (and
  /// decrypted) by `DriverRepository.get`, never for list rows.
  final bool hasNid;
  final String? nid;
  final String? address;
  final String? emergencyContact;
  final CalendarDay? joinDate;
  final String? photoFile;

  bool get isActive => status == DriverStatus.active;
}

@immutable
class DriverDraft {
  const new({
    required this.name,
    this.status = DriverStatus.active,
    this.phone,
    this.licenseNo,
    this.licenseExpiry,
    this.nid,
    this.address,
    this.emergencyContact,
    this.joinDate,
    this.photoFile,
  });

  factory fromDriver(Driver d) => DriverDraft(
    name: d.name,
    status: d.status,
    phone: d.phone,
    licenseNo: d.licenseNo,
    licenseExpiry: d.licenseExpiry,
    nid: d.nid,
    address: d.address,
    emergencyContact: d.emergencyContact,
    joinDate: d.joinDate,
    photoFile: d.photoFile,
  );

  final String name;
  final DriverStatus status;
  final String? phone;
  final String? licenseNo;
  final CalendarDay? licenseExpiry;

  /// Plain national ID; encrypted before it is stored.
  final String? nid;
  final String? address;
  final String? emergencyContact;
  final CalendarDay? joinDate;
  final String? photoFile;
}

/// A driver working a vehicle from [start] until [end] (null = still active).
@immutable
class Assignment {
  const new({
    required this.id,
    required this.vehicleId,
    required this.driverId,
    required this.payModel,
    required this.start,
    this.end,
  });

  final String id;
  final String vehicleId;
  final String driverId;
  final PayModel payModel;
  final CalendarDay start;
  final CalendarDay? end;

  bool get isActive => end == null;

  DayRange? get range => end == null ? null : DayRange(start, end!);

  /// The days this assignment covers, up to [until] if it is still active.
  DayRange rangeUntil(CalendarDay until) {
    final last = end ?? until;
    return DayRange(start, last.isBefore(start) ? start : last);
  }
}

/// An assignment with the names needed to list it.
@immutable
class AssignmentView {
  const new({
    required this.assignment,
    required this.driverName,
    required this.vehicleNickname,
  });

  final Assignment assignment;
  final String driverName;
  final String vehicleNickname;
}

@immutable
class Advance {
  const new({
    required this.id,
    required this.driverId,
    required this.amount,
    required this.givenOn,
    required this.recovered,
    this.note,
  });

  final String id;
  final String driverId;
  final Money amount;
  final CalendarDay givenOn;

  /// Already taken back through payouts.
  final Money recovered;
  final String? note;

  Money get remaining => amount - recovered;
  bool get isSettled => !remaining.isPositive;
}

@immutable
class Payout {
  const new({
    required this.id,
    required this.driverId,
    required this.period,
    required this.earned,
    required this.adjustment,
    required this.deducted,
    required this.net,
    required this.paidAt,
    this.assignmentId,
    this.adjustmentNote,
    this.note,
  });

  final String id;
  final String driverId;
  final String? assignmentId;

  /// The days this payout covers.
  final DayRange period;
  final Money earned;
  final Money adjustment;
  final String? adjustmentNote;
  final Money deducted;
  final Money net;
  final DateTime paidAt;
  final String? note;
}

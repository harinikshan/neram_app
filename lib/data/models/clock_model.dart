import 'package:uuid/uuid.dart';
import 'package:timezone/timezone.dart' as tz;
import '../services/timezone_service.dart';

class ClockModel {
  final String id;
  final String timezoneId; // IANA ID e.g. "America/New_York"
  final String displayName; // "New York"
  final String region; // "America"
  final Duration utcOffset;
  final bool isMaster;
  final int orderIndex;

  const ClockModel({
    required this.id,
    required this.timezoneId,
    required this.displayName,
    required this.region,
    required this.utcOffset,
    this.isMaster = false,
    this.orderIndex = 0,
  });

  factory ClockModel.fromTimezoneId(
    String timezoneId, {
    int orderIndex = 0,
    bool isMaster = false,
  }) {
    final resolvedTimezoneId = TimezoneService.normalizeTimezoneId(timezoneId);
    final location = tz.getLocation(resolvedTimezoneId);
    final now = tz.TZDateTime.now(location);
    final parts = resolvedTimezoneId.split('/');
    final city = parts.last.replaceAll('_', ' ');
    final region = parts.length > 1 ? parts.first : '';

    return ClockModel(
      id: const Uuid().v4(),
      timezoneId: resolvedTimezoneId,
      displayName: city,
      region: region,
      utcOffset: now.timeZoneOffset,
      isMaster: isMaster,
      orderIndex: orderIndex,
    );
  }

  /// Get current time in this timezone
  DateTime currentTime(DateTime nowUtc) {
    final location = TimezoneService.getLocation(timezoneId);
    return tz.TZDateTime.from(nowUtc.toUtc(), location);
  }

  /// Get current UTC offset (accounts for DST changes)
  Duration currentOffset() {
    final location = TimezoneService.getLocation(timezoneId);
    final now = tz.TZDateTime.now(location);
    return now.timeZoneOffset;
  }

  /// Get timezone abbreviation (e.g., "EST", "PDT")
  String get abbreviation {
    final location = TimezoneService.getLocation(timezoneId);
    final now = tz.TZDateTime.now(location);
    return now.timeZoneName;
  }

  /// Offset relative to another clock
  Duration offsetFrom(ClockModel other) {
    return currentOffset() - other.currentOffset();
  }

  /// Format offset as string e.g. "+5:30" or "-8:00"
  String offsetString(ClockModel master) {
    final diff = offsetFrom(master);
    if (diff.inMinutes == 0) return 'Same time';
    final sign = diff.isNegative ? '-' : '+';
    final hours = diff.inHours.abs();
    final minutes = (diff.inMinutes.abs() % 60);
    if (minutes == 0) return '$sign${hours}h';
    return '$sign${hours}h ${minutes}m';
  }

  /// UTC offset as string e.g. "UTC+5:30"
  String get utcOffsetString {
    final offset = currentOffset();
    final sign = offset.isNegative ? '-' : '+';
    final hours = offset.inHours.abs();
    final minutes = (offset.inMinutes.abs() % 60);
    if (minutes == 0) return 'UTC$sign$hours';
    return 'UTC$sign$hours:${minutes.toString().padLeft(2, '0')}';
  }

  ClockModel copyWith({
    String? id,
    String? timezoneId,
    String? displayName,
    String? region,
    Duration? utcOffset,
    bool? isMaster,
    int? orderIndex,
  }) {
    return ClockModel(
      id: id ?? this.id,
      timezoneId: timezoneId ?? this.timezoneId,
      displayName: displayName ?? this.displayName,
      region: region ?? this.region,
      utcOffset: utcOffset ?? this.utcOffset,
      isMaster: isMaster ?? this.isMaster,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'timezoneId': timezoneId,
    'displayName': displayName,
    'region': region,
    'isMaster': isMaster,
    'orderIndex': orderIndex,
  };

  factory ClockModel.fromJson(Map<String, dynamic> json) {
    final timezoneId = TimezoneService.normalizeTimezoneId(
      json['timezoneId'] as String,
    );
    final location = tz.getLocation(timezoneId);
    final now = tz.TZDateTime.now(location);

    return ClockModel(
      id: json['id'] as String,
      timezoneId: timezoneId,
      displayName: json['displayName'] as String,
      region: json['region'] as String,
      utcOffset: now.timeZoneOffset,
      isMaster: json['isMaster'] as bool? ?? false,
      orderIndex: json['orderIndex'] as int? ?? 0,
    );
  }
}

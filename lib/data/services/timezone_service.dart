import 'package:flutter/foundation.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class TimezoneService {
  static bool _initialized = false;
  static const String _fallbackTimezone = 'Etc/UTC';
  static const Map<String, String> _timezoneAliases = {
    'Asia/Calcutta': 'Asia/Kolkata',
    'US/Eastern': 'America/New_York',
    'US/Central': 'America/Chicago',
    'US/Mountain': 'America/Denver',
    'US/Pacific': 'America/Los_Angeles',
    'US/Alaska': 'America/Anchorage',
    'US/Hawaii': 'Pacific/Honolulu',
    'GMT': 'Etc/UTC',
    'UTC': 'Etc/UTC',
  };

  /// Initialize the timezone database
  static Future<void> initialize() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    _initialized = true;
  }

  /// Get device's local timezone IANA ID
  static Future<String> getDeviceTimezone() async {
    try {
      if (kIsWeb) {
        // flutter_timezone works on web too in recent versions
        final timezoneId = await FlutterTimezone.getLocalTimezone();
        return normalizeTimezoneId(timezoneId);
      }
      final timezoneId = await FlutterTimezone.getLocalTimezone();
      return normalizeTimezoneId(timezoneId);
    } catch (e) {
      // Fallback: try to determine from offset
      final offset = DateTime.now().timeZoneOffset;
      return _guessTimezoneFromOffset(offset);
    }
  }

  /// Resolve a potentially aliased timezone ID to one supported by timezone DB.
  static String normalizeTimezoneId(String timezoneId) {
    final trimmed = timezoneId.trim();
    if (trimmed.isEmpty) return _fallbackTimezone;

    if (tz.timeZoneDatabase.locations.containsKey(trimmed)) {
      return trimmed;
    }

    final alias = _timezoneAliases[trimmed];
    if (alias != null && tz.timeZoneDatabase.locations.containsKey(alias)) {
      return alias;
    }

    final offsetGuess = _guessTimezoneFromOffset(DateTime.now().timeZoneOffset);
    if (tz.timeZoneDatabase.locations.containsKey(offsetGuess)) {
      return offsetGuess;
    }

    return _fallbackTimezone;
  }

  /// Get all available timezone locations
  static Map<String, tz.Location> getAllLocations() {
    return tz.timeZoneDatabase.locations;
  }

  /// Get a location by IANA ID
  static tz.Location getLocation(String timezoneId) {
    return tz.getLocation(normalizeTimezoneId(timezoneId));
  }

  /// Get current time in a timezone
  static DateTime getCurrentTime(String timezoneId) {
    final location = getLocation(timezoneId);
    return tz.TZDateTime.now(location);
  }

  /// Get popular timezones to show as defaults
  static List<String> getPopularTimezones() {
    return [
      'America/New_York',
      'America/Los_Angeles',
      'America/Chicago',
      'Europe/London',
      'Europe/Paris',
      'Europe/Berlin',
      'Asia/Tokyo',
      'Asia/Shanghai',
      'Asia/Kolkata',
      'Asia/Dubai',
      'Asia/Singapore',
      'Australia/Sydney',
      'Pacific/Auckland',
      'America/Sao_Paulo',
      'Asia/Hong_Kong',
    ];
  }

  /// Fallback timezone guess from UTC offset
  static String _guessTimezoneFromOffset(Duration offset) {
    final offsetMinutes = offset.inMinutes;
    final mapping = {
      -480: 'America/Los_Angeles',
      -420: 'America/Denver',
      -360: 'America/Chicago',
      -300: 'America/New_York',
      0: 'Europe/London',
      60: 'Europe/Paris',
      120: 'Europe/Helsinki',
      180: 'Europe/Moscow',
      210: 'Asia/Tehran',
      240: 'Asia/Dubai',
      270: 'Asia/Kabul',
      300: 'Asia/Karachi',
      330: 'Asia/Kolkata',
      345: 'Asia/Kathmandu',
      360: 'Asia/Dhaka',
      420: 'Asia/Bangkok',
      480: 'Asia/Shanghai',
      540: 'Asia/Tokyo',
      570: 'Australia/Adelaide',
      600: 'Australia/Sydney',
      660: 'Pacific/Noumea',
      720: 'Pacific/Auckland',
    };
    return mapping[offsetMinutes] ?? 'UTC';
  }
}

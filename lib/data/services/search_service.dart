import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:timezone/timezone.dart' as tz;
import '../../core/constants/country_timezone_map.dart';
import '../../core/constants/app_constants.dart';
import 'timezone_service.dart';

final _time12Regex = RegExp(r'^(\d{1,2})(?::(\d{2}))?\s*(am|pm)$', caseSensitive: false);
final _time24Regex = RegExp(r'^(\d{1,2}):(\d{2})$');

class TimezoneSearchResult {
  final String timezoneId;
  final String city;
  final String region;
  final String utcOffsetString;
  final int score;

  const TimezoneSearchResult({
    required this.timezoneId,
    required this.city,
    required this.region,
    required this.utcOffsetString,
    required this.score,
  });
}

class SearchService {
  late final List<_TimezoneEntry> _allTimezones;
  bool _initialized = false;

  void initialize() {
    if (_initialized) return;
    final locations = tz.timeZoneDatabase.locations;
    final seenTimezoneIds = <String>{};

    _allTimezones = locations.entries
        .map((entry) {
          final canonicalId = TimezoneService.normalizeTimezoneId(entry.key);
          if (!seenTimezoneIds.add(canonicalId)) {
            return null;
          }

          final location = tz.getLocation(canonicalId);
          final parts = canonicalId.split('/');
          final city = parts.last.replaceAll('_', ' ');
          final region = parts.length > 1 ? parts.first : '';
          final now = tz.TZDateTime.now(location);
          final offset = now.timeZoneOffset;

          return _TimezoneEntry(
            timezoneId: canonicalId,
            city: city,
            region: region,
            searchableText:
                '${canonicalId.replaceAll('_', ' ').replaceAll('/', ' ')} $city',
            offset: offset,
            abbreviation: now.timeZoneName,
          );
        })
        .whereType<_TimezoneEntry>()
        .toList();
    _initialized = true;
  }

  List<TimezoneSearchResult> search(String query) {
    if (!_initialized) initialize();
    if (query.trim().isEmpty) return _popularResults();

    final q = query.trim().toLowerCase();
    final results = <TimezoneSearchResult>[];
    final seen = <String>{};

    // 1. Check country name map (intent search)
    _addCountryMatches(q, results, seen);

    // 2. Check city name map
    _addCityMatches(q, results, seen);

    // 3. Check abbreviation map
    _addAbbreviationMatches(q, results, seen);

    // 4. Check UTC offset pattern (e.g., "+5:30", "utc+5")
    _addOffsetMatches(q, results, seen);

    // 5. Check time pattern (e.g., "3pm", "15:00")
    _addTimeMatches(q, results, seen);

    // 6. Fuzzy search across all timezones
    for (final tz in _allTimezones) {
      if (seen.contains(tz.timezoneId)) continue;

      final score = _calculateScore(q, tz);
      if (score >= AppConstants.searchMinScore) {
        results.add(_entryToResult(tz, score));
        seen.add(tz.timezoneId);
      }
    }

    // Sort by score descending
    results.sort((a, b) => b.score.compareTo(a.score));
    return results.take(AppConstants.searchMaxResults).toList();
  }

  int _calculateScore(String query, _TimezoneEntry tz) {
    final cityLower = tz.city.toLowerCase();

    // Exact prefix on city name = highest
    if (cityLower.startsWith(query)) return 100;

    // City contains query
    if (cityLower.contains(query)) return 90;

    // Region/City combined contains query
    if (tz.searchableText.toLowerCase().contains(query)) return 80;

    // Fuzzy match
    final fuzzyScore = partialRatio(query, tz.searchableText.toLowerCase());
    return (fuzzyScore * 0.8).round(); // Scale fuzzy to max 80
  }

  void _addCountryMatches(
    String query,
    List<TimezoneSearchResult> results,
    Set<String> seen,
  ) {
    if (_allTimezones.isEmpty) return;
    for (final entry in countryTimezoneMap.entries) {
      if (entry.key.contains(query) || query.contains(entry.key)) {
        for (final tzId in entry.value) {
          if (seen.contains(tzId)) continue;
          final match = _allTimezones
              .where((t) => t.timezoneId == tzId)
              .firstOrNull;
          if (match != null) {
            results.add(_entryToResult(match, 95));
            seen.add(tzId);
          }
        }
      }
    }
  }

  void _addCityMatches(
    String query,
    List<TimezoneSearchResult> results,
    Set<String> seen,
  ) {
    if (_allTimezones.isEmpty) return;
    for (final entry in cityTimezoneMap.entries) {
      if (entry.key.startsWith(query) || entry.key.contains(query)) {
        for (final tzId in entry.value) {
          if (seen.contains(tzId)) continue;
          final match = _allTimezones
              .where((t) => t.timezoneId == tzId)
              .firstOrNull;
          if (match != null) {
            results.add(_entryToResult(match, 97));
            seen.add(tzId);
          }
        }
      }
    }
  }

  void _addTimeMatches(
    String query,
    List<TimezoneSearchResult> results,
    Set<String> seen,
  ) {
    final parsed = _parseTime(query);
    if (parsed == null) return;
    final (targetHour, targetMinute) = parsed;
    final now = DateTime.now();

    for (final entry in _allTimezones) {
      if (seen.contains(entry.timezoneId)) continue;
      try {
        final location = tz.getLocation(entry.timezoneId);
        final tzNow = tz.TZDateTime.from(now, location);
        if (tzNow.hour == targetHour && (targetMinute == -1 || tzNow.minute == targetMinute)) {
          results.add(_entryToResult(entry, 75));
          seen.add(entry.timezoneId);
        }
      } catch (_) {}
    }
  }

  static (int, int)? _parseTime(String query) {
    // 12-hour: "3pm", "3:00pm", "11:30am"
    final m12 = _time12Regex.firstMatch(query);
    if (m12 != null) {
      var hour = int.parse(m12.group(1)!);
      final minute = int.tryParse(m12.group(2) ?? '') ?? -1;
      final isPm = m12.group(3)!.toLowerCase() == 'pm';
      if (hour < 1 || hour > 12) return null;
      if (isPm && hour != 12) hour += 12;
      if (!isPm && hour == 12) hour = 0;
      return (hour, minute);
    }
    // 24-hour: "15:00", "08:30"
    final m24 = _time24Regex.firstMatch(query);
    if (m24 != null) {
      final hour = int.parse(m24.group(1)!);
      final minute = int.parse(m24.group(2)!);
      if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
      return (hour, minute);
    }
    return null;
  }

  void _addAbbreviationMatches(
    String query,
    List<TimezoneSearchResult> results,
    Set<String> seen,
  ) {
    if (_allTimezones.isEmpty) return;
    // Check our abbreviation map
    for (final entry in abbreviationMap.entries) {
      if (entry.key == query) {
        for (final tzId in entry.value) {
          if (seen.contains(tzId)) continue;
          final match = _allTimezones
              .where((t) => t.timezoneId == tzId)
              .firstOrNull;
          if (match != null) {
            results.add(_entryToResult(match, 93));
            seen.add(tzId);
          }
        }
      }
    }

    // Check actual timezone abbreviations
    for (final tz in _allTimezones) {
      if (seen.contains(tz.timezoneId)) continue;
      if (tz.abbreviation.toLowerCase() == query) {
        results.add(_entryToResult(tz, 88));
        seen.add(tz.timezoneId);
      }
    }
  }

  void _addOffsetMatches(
    String query,
    List<TimezoneSearchResult> results,
    Set<String> seen,
  ) {
    // Match patterns like "+5:30", "utc+5", "-8", "gmt+5:30"
    final cleaned = query.replaceAll('utc', '').replaceAll('gmt', '').trim();
    final offsetRegex = RegExp(r'^([+-]?)(\d{1,2})(?::(\d{2}))?$');
    final match = offsetRegex.firstMatch(cleaned);
    if (match == null) return;

    final sign = match.group(1) == '-' ? -1 : 1;
    final hours = int.parse(match.group(2)!);
    final minutes = int.tryParse(match.group(3) ?? '0') ?? 0;
    final targetMinutes = sign * (hours * 60 + minutes);

    for (final tz in _allTimezones) {
      if (seen.contains(tz.timezoneId)) continue;
      if (tz.offset.inMinutes == targetMinutes) {
        results.add(_entryToResult(tz, 70));
        seen.add(tz.timezoneId);
      }
    }
  }

  List<TimezoneSearchResult> _popularResults() {
    if (_allTimezones.isEmpty) return [];
    final popular = [
      'America/New_York',
      'America/Los_Angeles',
      'Europe/London',
      'Europe/Paris',
      'Asia/Tokyo',
      'Asia/Kolkata',
      'Asia/Dubai',
      'Asia/Singapore',
      'Australia/Sydney',
      'Pacific/Auckland',
    ];

    final results = <TimezoneSearchResult>[];
    for (final tzId in popular) {
      final match = _allTimezones
          .where((t) => t.timezoneId == tzId)
          .firstOrNull;
      if (match != null) {
        results.add(_entryToResult(match, 100));
      }
    }
    return results;
  }

  TimezoneSearchResult _entryToResult(_TimezoneEntry entry, int score) {
    final offset = entry.offset;
    final sign = offset.isNegative ? '-' : '+';
    final hours = offset.inHours.abs();
    final minutes = (offset.inMinutes.abs() % 60);
    final offsetStr = minutes == 0
        ? 'UTC$sign$hours'
        : 'UTC$sign$hours:${minutes.toString().padLeft(2, '0')}';

    return TimezoneSearchResult(
      timezoneId: entry.timezoneId,
      city: entry.city,
      region: entry.region,
      utcOffsetString: offsetStr,
      score: score,
    );
  }
}

class _TimezoneEntry {
  final String timezoneId;
  final String city;
  final String region;
  final String searchableText;
  final Duration offset;
  final String abbreviation;

  const _TimezoneEntry({
    required this.timezoneId,
    required this.city,
    required this.region,
    required this.searchableText,
    required this.offset,
    required this.abbreviation,
  });
}

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/clock_model.dart';
import '../../../data/services/timezone_service.dart';
import '../../../core/constants/app_constants.dart';
import 'time_tick_provider.dart';

/// Result of attempting to add a clock
enum AddClockResult { added, duplicate, maxReached }

/// Manages the ordered list of all clocks (master at index 0)
final clockListProvider =
    StateNotifierProvider<ClockListNotifier, List<ClockModel>>((ref) {
      return ClockListNotifier(ref);
    });

/// Derived: master clock is always index 0
final masterClockProvider = Provider<ClockModel?>((ref) {
  final clocks = ref.watch(clockListProvider);
  return clocks.isEmpty ? null : clocks.first;
});

/// Derived: child clocks (everything except index 0)
final childClocksProvider = Provider<List<ClockModel>>((ref) {
  final clocks = ref.watch(clockListProvider);
  return clocks.length > 1 ? clocks.sublist(1) : [];
});

/// Settings: 24-hour format
final use24HourProvider = StateProvider<bool>((ref) => false);

/// Settings: show seconds
final showSecondsProvider = StateProvider<bool>((ref) => true);

class ClockListNotifier extends StateNotifier<List<ClockModel>> {
  final Ref _ref;
  bool _loaded = false;

  ClockListNotifier(this._ref) : super([]);

  bool get isLoaded => _loaded;

  /// Initialize from saved preferences or device timezone
  Future<void> initialize() async {
    if (_loaded) return;

    final prefs = _ref.read(preferencesRepositoryProvider);
    final savedOrder = await prefs.loadTimezoneOrder();
    final use24 = await prefs.getUse24Hour();
    final showSec = await prefs.getShowSeconds();

    _ref.read(use24HourProvider.notifier).state = use24;
    _ref.read(showSecondsProvider.notifier).state = showSec;

    if (savedOrder.isNotEmpty) {
      final normalizedOrder = _normalizedUniqueTimezoneIds(savedOrder);
      try {
        state = normalizedOrder.asMap().entries.map((entry) {
          return ClockModel.fromTimezoneId(
            entry.value,
            orderIndex: entry.key,
            isMaster: entry.key == 0,
          );
        }).toList();
        if (!_listsEqual(savedOrder, normalizedOrder)) {
          await prefs.saveTimezoneOrder(normalizedOrder);
        }
        _loaded = true;
        return;
      } catch (e) {
        debugPrint('Failed to load saved clocks: $e');
        // Fall through to default
      }
    }

    // Default: device timezone only
    final deviceTz = await TimezoneService.getDeviceTimezone();
    state = [
      ClockModel.fromTimezoneId(deviceTz, orderIndex: 0, isMaster: true),
    ];
    _loaded = true;
  }

  /// Add a new timezone clock. Returns result indicating success or failure reason.
  AddClockResult addClock(String timezoneId) {
    if (state.length >= AppConstants.maxTotalClocks) return AddClockResult.maxReached;
    final normalizedId = TimezoneService.normalizeTimezoneId(timezoneId);
    // Don't add duplicates
    if (state.any((c) => c.timezoneId == normalizedId)) return AddClockResult.duplicate;

    state = [
      ...state,
      ClockModel.fromTimezoneId(
        normalizedId,
        orderIndex: state.length,
        isMaster: false,
      ),
    ];
    _persist();
    return AddClockResult.added;
  }

  /// Remove a clock by its ID
  void removeClock(String clockId) {
    // Can't remove the last clock
    if (state.length <= 1) return;

    final filtered = state.where((c) => c.id != clockId).toList();
    state = _reindex(filtered);
    _persist();
  }

  /// Reorder clocks - moving to index 0 promotes to master
  void reorder(int oldIndex, int newIndex) {
    final updated = [...state];
    final item = updated.removeAt(oldIndex);
    updated.insert(newIndex, item);
    state = _reindex(updated);
    _persist();
  }

  /// Set a specific clock as master (move to index 0)
  void setAsMaster(String clockId) {
    final index = state.indexWhere((c) => c.id == clockId);
    if (index <= 0) return; // Already master or not found
    reorder(index, 0);
  }

  /// Reset to device timezone only
  Future<void> resetToDeviceTime() async {
    final deviceTz = await TimezoneService.getDeviceTimezone();
    state = [
      ClockModel.fromTimezoneId(deviceTz, orderIndex: 0, isMaster: true),
    ];
    _persist();
  }

  /// Restore from bookmark
  void restoreFromBookmark(List<String> timezoneIds) {
    final normalizedIds = _normalizedUniqueTimezoneIds(timezoneIds);
    if (normalizedIds.isEmpty) return;
    state = normalizedIds.asMap().entries.map((entry) {
      return ClockModel.fromTimezoneId(
        entry.value,
        orderIndex: entry.key,
        isMaster: entry.key == 0,
      );
    }).toList();
    _persist();
  }

  List<ClockModel> _reindex(List<ClockModel> clocks) {
    return clocks.asMap().entries.map((entry) {
      return entry.value.copyWith(
        orderIndex: entry.key,
        isMaster: entry.key == 0,
      );
    }).toList();
  }

  Future<void> _persist() async {
    final prefs = _ref.read(preferencesRepositoryProvider);
    await prefs.saveTimezoneOrder(state.map((c) => c.timezoneId).toList());
  }

  List<String> _normalizedUniqueTimezoneIds(List<String> timezoneIds) {
    final seen = <String>{};
    final normalized = <String>[];
    for (final timezoneId in timezoneIds) {
      final canonical = TimezoneService.normalizeTimezoneId(timezoneId);
      if (seen.add(canonical)) {
        normalized.add(canonical);
      }
      if (normalized.length >= AppConstants.maxTotalClocks) break;
    }
    return normalized;
  }

  bool _listsEqual(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

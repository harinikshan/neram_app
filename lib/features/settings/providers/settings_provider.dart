import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../clock/providers/clock_list_provider.dart';
import '../../clock/providers/time_tick_provider.dart';

class SettingsActions {
  final Ref _ref;

  SettingsActions(this._ref);

  Future<void> toggle24Hour(bool value) async {
    _ref.read(use24HourProvider.notifier).state = value;
    final prefs = _ref.read(preferencesRepositoryProvider);
    await prefs.setUse24Hour(value);
  }

  Future<void> toggleShowSeconds(bool value) async {
    _ref.read(showSecondsProvider.notifier).state = value;
    final prefs = _ref.read(preferencesRepositoryProvider);
    await prefs.setShowSeconds(value);
  }

  Future<void> resetToDeviceTime() async {
    await _ref.read(clockListProvider.notifier).resetToDeviceTime();
    _ref.read(timePreviewOffsetMinutesProvider.notifier).state = 0;
  }

  Future<void> resetAllData() async {
    final prefs = _ref.read(preferencesRepositoryProvider);
    await prefs.resetAll();
    await _ref.read(clockListProvider.notifier).resetToDeviceTime();
    _ref.read(use24HourProvider.notifier).state = false;
    _ref.read(showSecondsProvider.notifier).state = true;
    _ref.read(timePreviewOffsetMinutesProvider.notifier).state = 0;
  }
}

final settingsActionsProvider = Provider<SettingsActions>((ref) {
  return SettingsActions(ref);
});

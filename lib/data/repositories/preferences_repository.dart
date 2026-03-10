import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../models/user_preferences.dart';
import '../models/bookmark_model.dart';

class PreferencesRepository {
  SharedPreferences? _prefs;

  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // User Preferences
  Future<UserPreferences?> loadPreferences() async {
    try {
      final prefs = await _preferences;
      final json = prefs.getString('user_preferences');
      if (json == null) return null;
      return UserPreferences.fromJson(jsonDecode(json));
    } catch (e) {
      return null;
    }
  }

  Future<void> savePreferences(UserPreferences preferences) async {
    final prefs = await _preferences;
    await prefs.setString('user_preferences', jsonEncode(preferences.toJson()));
  }

  // Timezone order (quick access)
  Future<List<String>> loadTimezoneOrder() async {
    try {
      final prefs = await _preferences;
      return prefs.getStringList(AppConstants.prefTimezoneOrder) ?? [];
    } catch (e) {
      return [];
    }
  }

  Future<void> saveTimezoneOrder(List<String> timezoneIds) async {
    final prefs = await _preferences;
    await prefs.setStringList(AppConstants.prefTimezoneOrder, timezoneIds);
  }

  // Settings
  Future<bool> getUse24Hour() async {
    final prefs = await _preferences;
    return prefs.getBool(AppConstants.prefUse24Hour) ?? false;
  }

  Future<void> setUse24Hour(bool value) async {
    final prefs = await _preferences;
    await prefs.setBool(AppConstants.prefUse24Hour, value);
  }

  Future<bool> getShowSeconds() async {
    final prefs = await _preferences;
    return prefs.getBool(AppConstants.prefShowSeconds) ?? true;
  }

  Future<void> setShowSeconds(bool value) async {
    final prefs = await _preferences;
    await prefs.setBool(AppConstants.prefShowSeconds, value);
  }

  // Bookmarks
  Future<List<BookmarkModel>> loadBookmarks() async {
    try {
      final prefs = await _preferences;
      final json = prefs.getString(AppConstants.prefBookmarks);
      if (json == null) return [];
      final list = jsonDecode(json) as List;
      return list.map((e) => BookmarkModel.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveBookmarks(List<BookmarkModel> bookmarks) async {
    final prefs = await _preferences;
    final json = jsonEncode(bookmarks.map((b) => b.toJson()).toList());
    await prefs.setString(AppConstants.prefBookmarks, json);
  }

  // First launch
  Future<bool> isFirstLaunch() async {
    final prefs = await _preferences;
    return prefs.getBool(AppConstants.prefFirstLaunch) ?? true;
  }

  Future<void> setFirstLaunchComplete() async {
    final prefs = await _preferences;
    await prefs.setBool(AppConstants.prefFirstLaunch, false);
  }

  // Reset all
  Future<void> resetAll() async {
    final prefs = await _preferences;
    await prefs.clear();
  }
}

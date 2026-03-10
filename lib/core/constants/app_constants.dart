class AppConstants {
  AppConstants._();

  static const String appName = 'Neram';
  static const String appTagline = 'World Time, Your Way';

  // Clock limits
  static const int maxChildClocks = 10;
  static const int maxTotalClocks = 11; // 1 master + 10 children

  // Animation durations
  static const Duration flipDuration = Duration(milliseconds: 450);
  static const Duration childFadeDuration = Duration(milliseconds: 300);
  static const Duration dialRotationDuration = Duration(seconds: 60);
  static const Duration searchDebounce = Duration(milliseconds: 300);

  // Search
  static const int searchMinScore = 50;
  static const int searchMaxResults = 20;

  // Screenshot
  static const double screenshotWidth = 1080;
  static const double screenshotPixelRatio = 3.0;

  // Glass
  static const double glassBlur = 12.0;
  static const double glassBorderRadius = 16.0;
  static const double glassBorderWidth = 0.5;

  // Preferences keys
  static const String prefTimezoneOrder = 'timezone_order';
  static const String prefMasterTimezone = 'master_timezone';
  static const String prefUse24Hour = 'use_24_hour';
  static const String prefShowSeconds = 'show_seconds';
  static const String prefBookmarks = 'bookmarks';
  static const String prefFirstLaunch = 'first_launch';
}

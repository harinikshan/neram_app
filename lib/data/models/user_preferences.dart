class UserPreferences {
  final bool use24HourFormat;
  final bool showSeconds;
  final List<String> timezoneIds;
  final String masterTimezoneId;

  const UserPreferences({
    this.use24HourFormat = false,
    this.showSeconds = true,
    this.timezoneIds = const [],
    this.masterTimezoneId = '',
  });

  factory UserPreferences.defaults(String deviceTimezone) {
    return UserPreferences(
      use24HourFormat: false,
      showSeconds: true,
      timezoneIds: [deviceTimezone],
      masterTimezoneId: deviceTimezone,
    );
  }

  UserPreferences copyWith({
    bool? use24HourFormat,
    bool? showSeconds,
    List<String>? timezoneIds,
    String? masterTimezoneId,
  }) {
    return UserPreferences(
      use24HourFormat: use24HourFormat ?? this.use24HourFormat,
      showSeconds: showSeconds ?? this.showSeconds,
      timezoneIds: timezoneIds ?? this.timezoneIds,
      masterTimezoneId: masterTimezoneId ?? this.masterTimezoneId,
    );
  }

  Map<String, dynamic> toJson() => {
        'use24HourFormat': use24HourFormat,
        'showSeconds': showSeconds,
        'timezoneIds': timezoneIds,
        'masterTimezoneId': masterTimezoneId,
      };

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      use24HourFormat: json['use24HourFormat'] as bool? ?? false,
      showSeconds: json['showSeconds'] as bool? ?? true,
      timezoneIds: (json['timezoneIds'] as List?)?.cast<String>() ?? [],
      masterTimezoneId: json['masterTimezoneId'] as String? ?? '',
    );
  }
}

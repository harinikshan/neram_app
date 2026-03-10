import 'package:intl/intl.dart';

extension DateTimeFormatting on DateTime {
  String formatTime({bool use24Hour = false, bool showSeconds = true}) {
    final pattern = use24Hour
        ? (showSeconds ? 'HH:mm:ss' : 'HH:mm')
        : (showSeconds ? 'hh:mm:ss a' : 'hh:mm a');
    return DateFormat(pattern).format(this);
  }

  String formatDate() {
    return DateFormat('EEE, MMM d').format(this);
  }

  String formatFull({bool use24Hour = false}) {
    final pattern = use24Hour ? 'EEE, MMM d, yyyy HH:mm' : 'EEE, MMM d, yyyy hh:mm a';
    return DateFormat(pattern).format(this);
  }

  /// Get individual digit strings for flip clock
  List<String> get hourDigits {
    final h = hour.toString().padLeft(2, '0');
    return [h[0], h[1]];
  }

  List<String> get hour12Digits {
    final h12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final h = h12.toString().padLeft(2, '0');
    return [h[0], h[1]];
  }

  List<String> get minuteDigits {
    final m = minute.toString().padLeft(2, '0');
    return [m[0], m[1]];
  }

  List<String> get secondDigits {
    final s = second.toString().padLeft(2, '0');
    return [s[0], s[1]];
  }

  String get amPm => hour >= 12 ? 'PM' : 'AM';

  /// Check if this is a different day from [other] in the same timezone
  bool isDifferentDay(DateTime other) {
    return year != other.year || month != other.month || day != other.day;
  }

  /// Get "+1 day" or "-1 day" relative offset string
  String dayOffsetString(DateTime reference) {
    final thisDayStart = DateTime(year, month, day);
    final refDayStart = DateTime(reference.year, reference.month, reference.day);
    final diff = thisDayStart.difference(refDayStart).inDays;
    if (diff == 0) return '';
    if (diff > 0) return '+$diff day${diff > 1 ? 's' : ''}';
    return '$diff day${diff.abs() > 1 ? 's' : ''}';
  }
}

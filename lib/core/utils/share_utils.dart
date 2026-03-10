import 'dart:typed_data';
import 'package:share_plus/share_plus.dart';
import '../../data/models/clock_model.dart';
import '../extensions/datetime_extensions.dart';

class ShareUtils {
  ShareUtils._();

  static Future<void> shareText(String text) async {
    await Share.share(text);
  }

  static Future<void> shareImage(Uint8List bytes, {String? text}) async {
    final xFile = XFile.fromData(
      bytes,
      mimeType: 'image/png',
      name: 'neram_clocks.png',
    );
    await Share.shareXFiles([xFile], text: text);
  }

  /// Generate formatted share text
  static String generateShareText({
    required List<ClockModel> clocks,
    required DateTime now,
    required bool use24Hour,
    String? message,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('Neram - World Clock');
    buffer.writeln('==============================');
    buffer.writeln();

    for (final clock in clocks) {
      final time = clock.currentTime(now);
      final timeStr = time.formatTime(use24Hour: use24Hour, showSeconds: false);
      final dateStr = time.formatDate();
      final prefix = clock.isMaster ? '>> ' : '   ';
      final masterTag = clock.isMaster ? ' [Master]' : '';

      buffer.writeln('$prefix${clock.displayName}$masterTag');
      buffer.writeln('$prefix$timeStr  $dateStr');
      buffer.writeln('$prefix${clock.abbreviation}  ${clock.utcOffsetString}');
      buffer.writeln();
    }

    if (message != null && message.isNotEmpty) {
      buffer.writeln('---');
      buffer.writeln(message);
      buffer.writeln();
    }

    buffer.writeln('Shared via Neram');
    return buffer.toString();
  }

  /// Generate minimal raw text
  static String generateRawText({
    required List<ClockModel> clocks,
    required DateTime now,
    required bool use24Hour,
    String? message,
  }) {
    final buffer = StringBuffer();

    for (final clock in clocks) {
      final time = clock.currentTime(now);
      final timeStr = time.formatTime(use24Hour: use24Hour, showSeconds: false);
      buffer.writeln('${clock.displayName}: $timeStr (${clock.abbreviation})');
    }

    if (message != null && message.isNotEmpty) {
      buffer.writeln();
      buffer.writeln(message);
    }

    return buffer.toString();
  }
}

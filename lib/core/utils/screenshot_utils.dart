import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ScreenshotUtils {
  ScreenshotUtils._();

  static final GlobalKey screenshotKey = GlobalKey();

  /// Capture a widget wrapped in RepaintBoundary with the screenshotKey
  static Future<ui.Image?> capture({double pixelRatio = 3.0}) async {
    try {
      final boundary =
          screenshotKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) return null;
      return await boundary.toImage(pixelRatio: pixelRatio);
    } catch (e) {
      return null;
    }
  }

  /// Convert ui.Image to PNG bytes
  static Future<Uint8List?> captureAsBytes({double pixelRatio = 3.0}) async {
    final image = await capture(pixelRatio: pixelRatio);
    if (image == null) return null;

    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }
}

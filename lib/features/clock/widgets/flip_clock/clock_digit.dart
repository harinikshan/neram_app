import 'package:flutter/material.dart';

/// Renders a single digit face (the static visual on a flip panel half)
class ClockDigitFace extends StatelessWidget {
  final String digit;
  final double fontSize;
  final double width;
  final double height;
  final bool isTopHalf;
  final TextStyle? textStyle;
  final Color topColor;
  final Color bottomColor;
  final Color digitColor;
  final double cornerRadius;

  const ClockDigitFace({
    super.key,
    required this.digit,
    required this.fontSize,
    required this.width,
    required this.height,
    required this.isTopHalf,
    required this.topColor,
    required this.bottomColor,
    required this.digitColor,
    required this.cornerRadius,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: isTopHalf ? Alignment.topCenter : Alignment.bottomCenter,
          end: isTopHalf ? Alignment.bottomCenter : Alignment.topCenter,
          colors: [
            topColor,
            isTopHalf ? topColor.withValues(alpha: 0.95) : bottomColor,
          ],
        ),
        borderRadius: isTopHalf
            ? BorderRadius.vertical(top: Radius.circular(cornerRadius))
            : BorderRadius.vertical(bottom: Radius.circular(cornerRadius)),
      ),
      child: ClipRect(
        child: Align(
          alignment: isTopHalf ? Alignment.topCenter : Alignment.bottomCenter,
          heightFactor: 0.5,
          child: SizedBox(
            height: height * 2,
            child: Center(
              child: Text(
                digit,
                style:
                    textStyle ??
                    TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: fontSize,
                      fontWeight: FontWeight.w700,
                      color: digitColor,
                      height: 1.0,
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

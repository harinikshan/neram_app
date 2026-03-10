import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import 'clock_digit.dart';

/// A single flip panel that animates a digit change with 3D flip effect.
/// The panel is split into top and bottom halves.
/// When the digit changes, the top half flips down revealing the new digit,
/// then the bottom half flips up to show the new digit.
class FlipPanel extends StatefulWidget {
  final String digit;
  final double fontSize;
  final double width;
  final double height;
  final Duration duration;
  final TextStyle? textStyle;
  final Color panelTopColor;
  final Color panelBottomColor;
  final Color panelDividerColor;
  final Color digitColor;
  final double cornerRadius;
  final bool showScrews;
  final double perspective;

  const FlipPanel({
    super.key,
    required this.digit,
    this.fontSize = 56,
    this.width = 52,
    this.height = 76,
    this.duration = AppConstants.flipDuration,
    this.textStyle,
    this.panelTopColor = AppColors.clockFace,
    this.panelBottomColor = AppColors.clockFaceLight,
    this.panelDividerColor = AppColors.clockDivider,
    this.digitColor = AppColors.clockDigit,
    this.cornerRadius = 8,
    this.showScrews = true,
    this.perspective = 0.002,
  });

  @override
  State<FlipPanel> createState() => _FlipPanelState();
}

class _FlipPanelState extends State<FlipPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _flipAnimation;

  String _currentDigit = '';
  String _previousDigit = '';
  bool _isFlipping = false;

  @override
  void initState() {
    super.initState();
    _currentDigit = widget.digit;
    _previousDigit = widget.digit;

    _controller = AnimationController(duration: widget.duration, vsync: this);

    _flipAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isFlipping = false;
          _previousDigit = _currentDigit;
        });
      }
    });
  }

  @override
  void didUpdateWidget(FlipPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.digit != _currentDigit) {
      _previousDigit = _currentDigit;
      _currentDigit = widget.digit;
      _isFlipping = true;
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final halfHeight = widget.height / 2;

    return RepaintBoundary(
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: Stack(
          children: [
            if (!_isFlipping)
              Positioned.fill(
                child: _StaticDigitFace(
                  digit: _currentDigit,
                  fontSize: widget.fontSize,
                  textStyle: widget.textStyle,
                  topColor: widget.panelTopColor,
                  bottomColor: widget.panelBottomColor,
                  digitColor: widget.digitColor,
                  cornerRadius: widget.cornerRadius,
                ),
              ),

            // Animated flipping panels
            if (_isFlipping) ...[
              // BOTTOM: Shows the NEW digit (revealed when top flap falls)
              Positioned(
                bottom: 0,
                child: ClockDigitFace(
                  digit: _currentDigit,
                  fontSize: widget.fontSize,
                  width: widget.width,
                  height: halfHeight,
                  isTopHalf: false,
                  textStyle: widget.textStyle,
                  topColor: widget.panelTopColor,
                  bottomColor: widget.panelBottomColor,
                  digitColor: widget.digitColor,
                  cornerRadius: widget.cornerRadius,
                ),
              ),

              // TOP: Shows the NEW digit (after flip completes)
              Positioned(
                top: 0,
                child: ClockDigitFace(
                  digit: _currentDigit,
                  fontSize: widget.fontSize,
                  width: widget.width,
                  height: halfHeight,
                  isTopHalf: true,
                  textStyle: widget.textStyle,
                  topColor: widget.panelTopColor,
                  bottomColor: widget.panelBottomColor,
                  digitColor: widget.digitColor,
                  cornerRadius: widget.cornerRadius,
                ),
              ),

              // UPPER FLAP: Shows previous digit, flips down
              Positioned(
                top: 0,
                child: AnimatedBuilder(
                  animation: _flipAnimation,
                  builder: (context, child) {
                    // Only animate first half (0.0 -> 0.5)
                    final progress = _flipAnimation.value;
                    if (progress > 0.5) return const SizedBox.shrink();

                    final angle =
                        progress * math.pi; // 0 to pi/2 mapped via 0->0.5
                    return Transform(
                      alignment: Alignment.bottomCenter,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, widget.perspective)
                        ..rotateX(-angle),
                      child: ClockDigitFace(
                        digit: _previousDigit,
                        fontSize: widget.fontSize,
                        width: widget.width,
                        height: halfHeight,
                        isTopHalf: true,
                        textStyle: widget.textStyle,
                        topColor: widget.panelTopColor,
                        bottomColor: widget.panelBottomColor,
                        digitColor: widget.digitColor,
                        cornerRadius: widget.cornerRadius,
                      ),
                    );
                  },
                ),
              ),

              // LOWER FLAP: Shows new digit, flips up into place
              Positioned(
                bottom: 0,
                child: AnimatedBuilder(
                  animation: _flipAnimation,
                  builder: (context, child) {
                    final progress = _flipAnimation.value;
                    if (progress < 0.5) {
                      // Show old digit on bottom, hasn't flipped yet
                      return ClockDigitFace(
                        digit: _previousDigit,
                        fontSize: widget.fontSize,
                        width: widget.width,
                        height: halfHeight,
                        isTopHalf: false,
                        textStyle: widget.textStyle,
                        topColor: widget.panelTopColor,
                        bottomColor: widget.panelBottomColor,
                        digitColor: widget.digitColor,
                        cornerRadius: widget.cornerRadius,
                      );
                    }

                    // Animate second half (0.5 -> 1.0)
                    final angle = (1.0 - progress) * math.pi; // pi to 0
                    return Transform(
                      alignment: Alignment.topCenter,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, widget.perspective)
                        ..rotateX(angle),
                      child: ClockDigitFace(
                        digit: _currentDigit,
                        fontSize: widget.fontSize,
                        width: widget.width,
                        height: halfHeight,
                        isTopHalf: false,
                        textStyle: widget.textStyle,
                        topColor: widget.panelTopColor,
                        bottomColor: widget.panelBottomColor,
                        digitColor: widget.digitColor,
                        cornerRadius: widget.cornerRadius,
                      ),
                    );
                  },
                ),
              ),

              // Shadow overlay for depth effect
              Positioned(
                bottom: 0,
                child: AnimatedBuilder(
                  animation: _flipAnimation,
                  builder: (context, child) {
                    final opacity = _flipAnimation.value < 0.5
                        ? _flipAnimation.value * 0.4
                        : (1.0 - _flipAnimation.value) * 0.4;
                    return IgnorePointer(
                      child: Container(
                        width: widget.width,
                        height: halfHeight,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: opacity),
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(8),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],

            // Divider line between top and bottom
            Positioned(
              top: halfHeight - 0.5,
              child: Container(
                width: widget.width,
                height: 1.0,
                color: widget.panelDividerColor,
              ),
            ),

            // Subtle side screws (decorative)
            if (widget.showScrews) ...[
              Positioned(
                top: halfHeight - 2,
                left: 2,
                child: Container(
                  width: 3,
                  height: 3,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.panelBottomColor.withValues(alpha: 0.7),
                  ),
                ),
              ),
              Positioned(
                top: halfHeight - 2,
                right: 2,
                child: Container(
                  width: 3,
                  height: 3,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.panelBottomColor.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StaticDigitFace extends StatelessWidget {
  final String digit;
  final double fontSize;
  final TextStyle? textStyle;
  final Color topColor;
  final Color bottomColor;
  final Color digitColor;
  final double cornerRadius;

  const _StaticDigitFace({
    required this.digit,
    required this.fontSize,
    required this.textStyle,
    required this.topColor,
    required this.bottomColor,
    required this.digitColor,
    required this.cornerRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [topColor, bottomColor],
        ),
        borderRadius: BorderRadius.circular(cornerRadius),
      ),
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
    );
  }
}

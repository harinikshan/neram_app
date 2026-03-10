import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'flip_panel.dart';

/// Full flip clock display: HH : MM : SS (or HH : MM)
class FlipClockWidget extends StatelessWidget {
  final String hourTens;
  final String hourOnes;
  final String minuteTens;
  final String minuteOnes;
  final String? secondTens;
  final String? secondOnes;
  final String? amPm;
  final bool showSeconds;
  final double digitFontSize;
  final double digitWidth;
  final double digitHeight;
  final double colonSize;
  final TextStyle? digitTextStyle;

  const FlipClockWidget({
    super.key,
    required this.hourTens,
    required this.hourOnes,
    required this.minuteTens,
    required this.minuteOnes,
    this.secondTens,
    this.secondOnes,
    this.amPm,
    this.showSeconds = true,
    this.digitFontSize = 56,
    this.digitWidth = 52,
    this.digitHeight = 76,
    this.colonSize = 32,
    this.digitTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Hours
        _buildDigitPair(hourTens, hourOnes),
        _buildColon(),
        // Minutes
        _buildDigitPair(minuteTens, minuteOnes),
        // Seconds (optional)
        if (showSeconds && secondTens != null && secondOnes != null) ...[
          _buildColon(),
          _buildDigitPair(secondTens!, secondOnes!),
        ],
        // AM/PM indicator
        if (amPm != null) ...[
          const SizedBox(width: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.clockFace,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppColors.clockFaceLight.withValues(alpha: 0.3),
                    width: 0.5,
                  ),
                ),
                child: Text(
                  amPm!,
                  style: TextStyle(
                    fontSize: digitFontSize * 0.25,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildDigitPair(String tens, String ones) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FlipPanel(
          digit: tens,
          fontSize: digitFontSize,
          width: digitWidth,
          height: digitHeight,
          textStyle: digitTextStyle,
        ),
        const SizedBox(width: 3),
        FlipPanel(
          digit: ones,
          fontSize: digitFontSize,
          width: digitWidth,
          height: digitHeight,
          textStyle: digitTextStyle,
        ),
      ],
    );
  }

  Widget _buildColon() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: _BlinkingColon(size: colonSize),
    );
  }
}

class _BlinkingColon extends StatefulWidget {
  final double size;
  const _BlinkingColon({required this.size});

  @override
  State<_BlinkingColon> createState() => _BlinkingColonState();
}

class _BlinkingColonState extends State<_BlinkingColon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 1.0, end: 0.3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: widget.size * 0.2,
            height: widget.size * 0.2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accent.withValues(alpha: 0.8),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.3),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          SizedBox(height: widget.size * 0.35),
          Container(
            width: widget.size * 0.2,
            height: widget.size * 0.2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accent.withValues(alpha: 0.8),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.3),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

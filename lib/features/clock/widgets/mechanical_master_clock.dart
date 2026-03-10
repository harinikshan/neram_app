import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'flip_clock/flip_panel.dart';

class MechanicalMasterClock extends StatelessWidget {
  final String hourTens;
  final String hourOnes;
  final String minuteTens;
  final String minuteOnes;
  final String? secondTens;
  final String? secondOnes;
  final String? amPm;
  final bool showSeconds;

  const MechanicalMasterClock({
    super.key,
    required this.hourTens,
    required this.hourOnes,
    required this.minuteTens,
    required this.minuteOnes,
    this.secondTens,
    this.secondOnes,
    this.amPm,
    this.showSeconds = true,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width;

        final compact = availableWidth < 380;
        final baseWidth = compact ? 320.0 : 420.0;
        final pillarWidth = baseWidth * 0.12;
        final bridgeGap = baseWidth * 0.02;
        final moduleWidth = (baseWidth - pillarWidth - (bridgeGap * 2)) / 2;

        final horizontalPadding = moduleWidth * 0.09;
        final digitGap = moduleWidth * 0.03;
        final usableDigitRowWidth = moduleWidth - (horizontalPadding * 2) - 4;
        final digitWidth = ((usableDigitRowWidth - digitGap) / 2)
            .clamp(44.0, 82.0)
            .toDouble();
        final digitHeight = digitWidth * 1.17;
        final moduleHeight = digitHeight + baseWidth * 0.09;
        final fontSize = digitHeight * 0.82;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: SizedBox(
                width: baseWidth,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _MountBar(width: baseWidth, centerWidth: pillarWidth + 14),
                    SizedBox(height: compact ? 3 : 6),
                    SizedBox(
                      width: baseWidth,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _ClockModule(
                            width: moduleWidth,
                            height: moduleHeight,
                            child: Stack(
                              children: [
                                _DigitRow(
                                  first: hourTens,
                                  second: hourOnes,
                                  digitWidth: digitWidth,
                                  digitHeight: digitHeight,
                                  digitGap: digitGap,
                                  fontSize: fontSize,
                                ),
                                if (amPm != null)
                                  Positioned(
                                    left: 4,
                                    bottom: 4,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: compact ? 5 : 6,
                                        vertical: compact ? 2 : 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0x40090A0C),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Text(
                                        amPm!,
                                        style: TextStyle(
                                          color: const Color(0xFFE8E8EA),
                                          fontSize: compact ? 12 : 14,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          SizedBox(width: bridgeGap),
                          _CenterPillar(
                            width: pillarWidth,
                            height: moduleHeight + (compact ? 8 : 10),
                          ),
                          SizedBox(width: bridgeGap),
                          _ClockModule(
                            width: moduleWidth,
                            height: moduleHeight,
                            child: _DigitRow(
                              first: minuteTens,
                              second: minuteOnes,
                              digitWidth: digitWidth,
                              digitHeight: digitHeight,
                              digitGap: digitGap,
                              fontSize: fontSize,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (showSeconds && secondTens != null && secondOnes != null) ...[
              SizedBox(height: compact ? 6 : 8),
              _SecondsStrip(
                secondTens: secondTens!,
                secondOnes: secondOnes!,
                compact: compact,
              ),
            ],
          ],
        );
      },
    );
  }
}

class _DigitRow extends StatelessWidget {
  final String first;
  final String second;
  final double digitWidth;
  final double digitHeight;
  final double digitGap;
  final double fontSize;

  const _DigitRow({
    required this.first,
    required this.second,
    required this.digitWidth,
    required this.digitHeight,
    required this.digitGap,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _digit(first, digitWidth, digitHeight, fontSize),
          SizedBox(width: digitGap),
          _digit(second, digitWidth, digitHeight, fontSize),
        ],
      ),
    );
  }

  Widget _digit(String value, double width, double height, double fontSize) {
    return FlipPanel(
      digit: value,
      width: width,
      height: height,
      fontSize: fontSize,
      cornerRadius: 3,
      panelTopColor: const Color(0xFF24252A),
      panelBottomColor: const Color(0xFF191A1E),
      panelDividerColor: const Color(0xFF0A0A0D),
      digitColor: const Color(0xFFF2F2F3),
      showScrews: false,
      perspective: 0.0033,
      duration: const Duration(milliseconds: 320),
    );
  }
}

class _MountBar extends StatelessWidget {
  final double width;
  final double centerWidth;

  const _MountBar({required this.width, required this.centerWidth});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Row(
        children: [
          const Expanded(
            child: _Rod(
              radius: BorderRadius.only(
                topLeft: Radius.circular(5),
                bottomLeft: Radius.circular(5),
              ),
            ),
          ),
          Container(
            width: centerWidth,
            height: 9,
            decoration: BoxDecoration(
              color: const Color(0xFF1B1C20),
              borderRadius: BorderRadius.circular(2),
              border: Border.all(color: const Color(0xFF2F3035), width: 0.7),
            ),
          ),
          const Expanded(
            child: _Rod(
              radius: BorderRadius.only(
                topRight: Radius.circular(5),
                bottomRight: Radius.circular(5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Rod extends StatelessWidget {
  final BorderRadius radius;

  const _Rod({required this.radius});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 8,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF505359), Color(0xFF272A30)],
        ),
      ),
    );
  }
}

class _ClockModule extends StatelessWidget {
  final double width;
  final double height;
  final Widget child;

  const _ClockModule({
    required this.width,
    required this.height,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.09,
        vertical: width * 0.05,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2E3035), Color(0xFF15161A)],
        ),
        border: Border.all(color: const Color(0xFF3A3D43), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0xA6000000),
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          child,
          Positioned(
            left: 0,
            right: 0,
            bottom: 5,
            child: Container(height: 1, color: const Color(0x20FFFFFF)),
          ),
        ],
      ),
    );
  }
}

class _CenterPillar extends StatelessWidget {
  final double width;
  final double height;

  const _CenterPillar({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2A2C31), Color(0xFF16171A)],
        ),
        border: Border.all(color: const Color(0xFF3A3C40), width: 1),
      ),
    );
  }
}

class _SecondsStrip extends StatelessWidget {
  final String secondTens;
  final String secondOnes;
  final bool compact;

  const _SecondsStrip({
    required this.secondTens,
    required this.secondOnes,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 9 : 12,
        vertical: compact ? 5 : 7,
      ),
      decoration: BoxDecoration(
        color: const Color(0x40101114),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.glassBorder.withValues(alpha: 0.16),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'SEC',
            style: TextStyle(
              color: const Color(0x99FFFFFF),
              fontSize: compact ? 10 : 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$secondTens$secondOnes',
            style: TextStyle(
              color: const Color(0xFFECECEE),
              fontSize: compact ? 17 : 20,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

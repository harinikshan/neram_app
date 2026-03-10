import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/time_tick_provider.dart';

class TimePreviewRotator extends StatefulWidget {
  final int offsetMinutes;
  final ValueChanged<int> onChanged;
  final VoidCallback onReset;

  const TimePreviewRotator({
    super.key,
    required this.offsetMinutes,
    required this.onChanged,
    required this.onReset,
  });

  @override
  State<TimePreviewRotator> createState() => _TimePreviewRotatorState();
}

class _TimePreviewRotatorState extends State<TimePreviewRotator> {
  double _dragAccumulator = 0;

  @override
  Widget build(BuildContext context) {
    final offset = _snap(widget.offsetMinutes);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Offset label
        Text(
          _formatShort(offset),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: offset == 0 ? AppColors.textSecondary : AppColors.accent,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          _formatLong(offset),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),

        // Horizontal slider
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final trackWidth = constraints.maxWidth - 16;
              return Listener(
                onPointerSignal: (event) {
                  if (event is PointerScrollEvent) {
                    final direction = event.scrollDelta.dy > 0 ? -1 : 1;
                    _changeOffset(direction * previewStepMinutes);
                  }
                },
                child: GestureDetector(
                  onHorizontalDragStart: (_) => _dragAccumulator = 0,
                  onHorizontalDragUpdate: (details) {
                    _dragAccumulator += details.delta.dx;
                    final minutesPerPx = (2 * previewMaxMinutes) / trackWidth;
                    final deltaMins = (_dragAccumulator * minutesPerPx).round();
                    final steps = (deltaMins / previewStepMinutes).truncate();
                    if (steps == 0) return;
                    _changeOffset(steps * previewStepMinutes);
                    _dragAccumulator -= (steps * previewStepMinutes) / minutesPerPx;
                  },
                  onHorizontalDragEnd: (_) => _dragAccumulator = 0,
                  onTapDown: (details) {
                    final tapX = details.localPosition.dx - 8;
                    final ratio = (tapX / trackWidth).clamp(0.0, 1.0);
                    final mins = ((ratio * 2 - 1) * previewMaxMinutes).round();
                    widget.onChanged(_snap(mins));
                    HapticFeedback.selectionClick();
                  },
                  child: SizedBox(
                    height: 52,
                    child: CustomPaint(
                      painter: _HorizontalSliderPainter(
                        offsetMinutes: offset,
                        maxMinutes: previewMaxMinutes,
                      ),
                      size: Size.infinite,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 4),

        // Control buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _StepButton(label: '-1h', onTap: () => _changeOffset(-60)),
            const SizedBox(width: 4),
            _StepButton(
              label: '-15m',
              onTap: () => _changeOffset(-previewStepMinutes),
            ),
            const SizedBox(width: 6),
            SizedBox(
              height: 30,
              child: TextButton(
                onPressed: offset == 0 ? null : widget.onReset,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  backgroundColor: offset != 0
                      ? AppColors.accent.withValues(alpha: 0.15)
                      : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'NOW',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: offset != 0 ? AppColors.accent : AppColors.textTertiary,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            _StepButton(
              label: '+15m',
              onTap: () => _changeOffset(previewStepMinutes),
            ),
            const SizedBox(width: 4),
            _StepButton(label: '+1h', onTap: () => _changeOffset(60)),
          ],
        ),
      ],
    );
  }

  void _changeOffset(int deltaMinutes) {
    final next = _snap(widget.offsetMinutes + deltaMinutes);
    if (next != widget.offsetMinutes) {
      HapticFeedback.selectionClick();
    }
    widget.onChanged(next);
  }

  int _snap(int minutes) {
    final clamped = minutes.clamp(-previewMaxMinutes, previewMaxMinutes);
    final snapped =
        ((clamped / previewStepMinutes).round()) * previewStepMinutes;
    return snapped.clamp(-previewMaxMinutes, previewMaxMinutes);
  }

  String _formatShort(int minutes) {
    if (minutes == 0) return 'NOW';
    final sign = minutes.isNegative ? '-' : '+';
    final absMinutes = minutes.abs();
    final hours = absMinutes ~/ 60;
    final mins = absMinutes % 60;
    if (mins == 0) return '$sign${hours}h';
    if (hours == 0) return '$sign${mins}m';
    return '$sign${hours}h ${mins}m';
  }

  String _formatLong(int minutes) {
    if (minutes == 0) return 'Live device time';
    final sign = minutes.isNegative ? '-' : '+';
    final absMinutes = minutes.abs();
    final hours = absMinutes ~/ 60;
    final mins = absMinutes % 60;
    if (mins == 0) return 'Offset $sign${hours}h';
    if (hours == 0) return 'Offset $sign${mins}m';
    return 'Offset $sign${hours}h ${mins}m';
  }
}

class _StepButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _StepButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _HorizontalSliderPainter extends CustomPainter {
  final int offsetMinutes;
  final int maxMinutes;

  const _HorizontalSliderPainter({
    required this.offsetMinutes,
    required this.maxMinutes,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final trackY = size.height / 2;
    const padding = 8.0;
    final trackLeft = padding;
    final trackRight = size.width - padding;
    final trackWidth = trackRight - trackLeft;

    // Track background
    final trackPaint = Paint()
      ..color = const Color(0x30FFFFFF)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(trackLeft, trackY),
      Offset(trackRight, trackY),
      trackPaint,
    );

    // Center mark (NOW)
    final centerX = trackLeft + trackWidth / 2;
    final centerPaint = Paint()
      ..color = AppColors.textTertiary.withValues(alpha: 0.5)
      ..strokeWidth = 1.5;
    canvas.drawLine(
      Offset(centerX, trackY - 10),
      Offset(centerX, trackY + 10),
      centerPaint,
    );

    // Tick marks with labels
    final tickPaint = Paint()
      ..color = const Color(0x40FFFFFF)
      ..strokeWidth = 1;
    final labelStyle = TextStyle(
      color: AppColors.textTertiary.withValues(alpha: 0.7),
      fontSize: 8,
      fontWeight: FontWeight.w500,
    );

    for (var h = -24; h <= 24; h += 3) {
      if (h == 0) continue;
      final ratio = (h * 60 + maxMinutes) / (2 * maxMinutes);
      final x = trackLeft + ratio * trackWidth;
      final isMajor = h % 6 == 0;
      final tickH = isMajor ? 7.0 : 4.0;

      canvas.drawLine(
        Offset(x, trackY - tickH),
        Offset(x, trackY + tickH),
        tickPaint,
      );

      if (isMajor) {
        final label = '${h > 0 ? '+' : ''}${h}h';
        final tp = TextPainter(
          text: TextSpan(text: label, style: labelStyle),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(x - tp.width / 2, trackY + 11));
      }
    }

    // Active segment from center to knob
    final knobRatio = (offsetMinutes / maxMinutes + 1) / 2;
    final knobX = trackLeft + knobRatio.clamp(0.0, 1.0) * trackWidth;

    if (offsetMinutes != 0) {
      final activePaint = Paint()
        ..color = AppColors.accent.withValues(alpha: 0.8)
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(centerX, trackY),
        Offset(knobX, trackY),
        activePaint,
      );
    }

    // Knob
    final knobColor = offsetMinutes == 0 ? AppColors.textTertiary : AppColors.accent;
    final shadowPaint = Paint()
      ..color = knobColor.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(Offset(knobX, trackY), 9, shadowPaint);

    final knobPaint = Paint()..color = knobColor;
    canvas.drawCircle(Offset(knobX, trackY), 8, knobPaint);

    final innerPaint = Paint()..color = const Color(0x40000000);
    canvas.drawCircle(Offset(knobX, trackY), 3, innerPaint);
  }

  @override
  bool shouldRepaint(covariant _HorizontalSliderPainter oldDelegate) {
    return oldDelegate.offsetMinutes != offsetMinutes;
  }
}

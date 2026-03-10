import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/datetime_extensions.dart';
import '../../../data/models/clock_model.dart';
import '../../../shared/widgets/glassmorphic_card.dart';
import '../providers/clock_list_provider.dart';
import '../providers/time_tick_provider.dart';
import 'mechanical_master_clock.dart';
import 'time_preview_rotator.dart';

class MasterClockDisplay extends ConsumerWidget {
  final ClockModel clock;
  final Widget? dragHandle;

  const MasterClockDisplay({super.key, required this.clock, this.dragHandle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(effectiveTimeProvider);
    final use24Hour = ref.watch(use24HourProvider);
    final showSeconds = ref.watch(showSecondsProvider);
    final previewOffset = ref.watch(timePreviewOffsetProvider);
    final previewOffsetMinutes = ref.watch(timePreviewOffsetMinutesProvider);

    return _buildClock(
      context,
      ref,
      now.add(previewOffset),
      use24Hour,
      showSeconds,
      previewOffsetMinutes,
    );
  }

  Widget _buildClock(
    BuildContext context,
    WidgetRef ref,
    DateTime now,
    bool use24Hour,
    bool showSeconds,
    int previewOffsetMinutes,
  ) {
    final currentTime = clock.currentTime(now);
    final hourDigits = use24Hour
        ? currentTime.hourDigits
        : currentTime.hour12Digits;
    final minuteDigits = currentTime.minuteDigits;
    final secondDigits = currentTime.secondDigits;

    final timeLabel = currentTime.formatTime(
      use24Hour: use24Hour,
      showSeconds: showSeconds,
    );

    return Semantics(
      label: 'Master clock, ${clock.displayName}, $timeLabel',
      child: GlassmorphicCard(
      blur: 10,
      opacity: 0.05,
      borderOpacity: 0.1,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      margin: const EdgeInsets.symmetric(horizontal: 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 380;
          final titleStyle = compact
              ? Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                )
              : Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                );

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: compact ? 24 : 26,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    _masterBadge(),
                    if (dragHandle != null)
                      Align(
                        alignment: Alignment.centerRight,
                        child: dragHandle!,
                      ),
                  ],
                ),
              ),
              SizedBox(height: compact ? 4 : 6),
              Text(
                clock.displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: titleStyle,
              ),
              const SizedBox(height: 2),
              Text(
                '${clock.abbreviation}  ${clock.utcOffsetString}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              SizedBox(height: compact ? 6 : 8),
              MechanicalMasterClock(
                hourTens: hourDigits[0],
                hourOnes: hourDigits[1],
                minuteTens: minuteDigits[0],
                minuteOnes: minuteDigits[1],
                secondTens: showSeconds ? secondDigits[0] : null,
                secondOnes: showSeconds ? secondDigits[1] : null,
                amPm: use24Hour ? null : currentTime.amPm,
                showSeconds: showSeconds,
              ),
              SizedBox(height: compact ? 4 : 6),
              Text(
                currentTime.formatDate(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: compact ? 4 : 6),
              TimePreviewRotator(
                offsetMinutes: previewOffsetMinutes,
                onChanged: (minutes) {
                  // Freeze base time when entering preview
                  if (previewOffsetMinutes == 0 && minutes != 0) {
                    ref.read(previewBaseTimeProvider.notifier).state =
                        DateTime.now();
                  }
                  ref.read(timePreviewOffsetMinutesProvider.notifier).state =
                      minutes;
                },
                onReset: () {
                  ref.read(timePreviewOffsetMinutesProvider.notifier).state = 0;
                  ref.read(previewBaseTimeProvider.notifier).state = null;
                },
              ),
            ],
          );
        },
      ),
    ),
    );
  }

  Widget _masterBadge() {
    return Semantics(
      label: 'Master clock badge',
      child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.masterBadge.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.masterBadge.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: 14, color: AppColors.masterBadge),
          const SizedBox(width: 4),
          Text(
            'MASTER',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.masterBadge,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    ),
    );
  }
}

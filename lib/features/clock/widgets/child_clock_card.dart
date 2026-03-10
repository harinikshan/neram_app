import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/datetime_extensions.dart';
import '../../../data/models/clock_model.dart';
import '../../../shared/widgets/glassmorphic_card.dart';
import '../providers/clock_list_provider.dart';
import '../providers/time_tick_provider.dart';
import 'flip_clock/flip_clock_widget.dart';

class ChildClockCard extends ConsumerWidget {
  final ClockModel clock;
  final int index;
  final Widget? dragHandle;

  const ChildClockCard({
    super.key,
    required this.clock,
    required this.index,
    this.dragHandle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(effectiveTimeProvider);
    final use24Hour = ref.watch(use24HourProvider);
    final showSeconds = ref.watch(showSecondsProvider);
    final previewOffset = ref.watch(timePreviewOffsetProvider);
    final master = ref.watch(masterClockProvider);

    return _buildCard(
      context,
      ref,
      now.add(previewOffset),
      use24Hour,
      showSeconds,
      master,
    );
  }

  Widget _buildCard(
    BuildContext context,
    WidgetRef ref,
    DateTime now,
    bool use24Hour,
    bool showSeconds,
    ClockModel? master,
  ) {
    final currentTime = clock.currentTime(now);
    final hourDigits = use24Hour
        ? currentTime.hourDigits
        : currentTime.hour12Digits;
    final minuteDigits = currentTime.minuteDigits;
    final secondDigits = currentTime.secondDigits;

    final offsetStr = master != null ? clock.offsetString(master) : '';
    final dayOffset = master != null
        ? currentTime.dayOffsetString(master.currentTime(now))
        : '';

    final timeLabel = currentTime.formatTime(
      use24Hour: use24Hour,
      showSeconds: showSeconds,
    );

    return Semantics(
      label: '${clock.displayName}, $timeLabel, ${clock.abbreviation}${offsetStr.isNotEmpty ? ', $offsetStr from master' : ''}',
      child: GlassmorphicCard(
      blur: 8,
      opacity: 0.05,
      borderOpacity: 0.1,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      onLongPress: () {
        HapticFeedback.mediumImpact();
        _showOptions(context, ref);
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 380;
          final clockWidget = Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0x260A0A0D),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.glassBorder.withValues(alpha: 0.14),
                width: 0.5,
              ),
            ),
            child: FlipClockWidget(
              hourTens: hourDigits[0],
              hourOnes: hourDigits[1],
              minuteTens: minuteDigits[0],
              minuteOnes: minuteDigits[1],
              secondTens: showSeconds ? secondDigits[0] : null,
              secondOnes: showSeconds ? secondDigits[1] : null,
              amPm: use24Hour ? null : currentTime.amPm,
              showSeconds: showSeconds,
              digitFontSize: compact ? 20 : 24,
              digitWidth: compact ? 20 : 24,
              digitHeight: compact ? 30 : 36,
              colonSize: compact ? 14 : 16,
            ),
          );

          final metadata = Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                clock.abbreviation,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (offsetStr.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    offsetStr,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accent,
                    ),
                  ),
                ),
              if (dayOffset.isNotEmpty)
                Text(
                  dayOffset,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppColors.masterBadge,
                  ),
                ),
            ],
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        clock.displayName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (dragHandle != null) ...[
                      const SizedBox(width: 8),
                      dragHandle!,
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                metadata,
                const SizedBox(height: 8),
                Align(alignment: Alignment.centerRight, child: clockWidget),
              ],
            );
          }

          return Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      clock.displayName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    metadata,
                  ],
                ),
              ),
              const SizedBox(width: 8),
              clockWidget,
              if (dragHandle != null) ...[
                const SizedBox(width: 8),
                dragHandle!,
              ],
            ],
          );
        },
      ),
    ),
    );
  }

  void _showOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundMid,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textTertiary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  clock.displayName,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text(
                  '${clock.abbreviation} ${clock.utcOffsetString}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(
                    Icons.star_rounded,
                    color: AppColors.masterBadge,
                  ),
                  title: const Text('Set as Master'),
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    ref.read(clockListProvider.notifier).setAsMaster(clock.id);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.delete_outline,
                    color: AppColors.danger,
                  ),
                  title: const Text('Remove'),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    ref.read(clockListProvider.notifier).removeClock(clock.id);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

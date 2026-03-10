import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/clock_list_provider.dart';
import 'child_clock_card.dart';
import 'master_clock_display.dart';

class ClockListView extends ConsumerWidget {
  const ClockListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clocks = ref.watch(clockListProvider);

    if (clocks.isEmpty) {
      return _LoadingSkeleton();
    }

    // Show the list with optional first-launch hint
    final showHint = clocks.length == 1;

    return ReorderableListView.builder(
      padding: const EdgeInsets.only(top: 12, bottom: 72),
      buildDefaultDragHandles: false,
      proxyDecorator: (child, index, animation) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            final scale = lerpDouble(1.0, 1.03, animation.value)!;
            return Transform.scale(
              scale: scale,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withValues(
                        alpha: 0.15 * animation.value,
                      ),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: child,
              ),
            );
          },
          child: child,
        );
      },
      onReorder: (oldIndex, newIndex) {
        HapticFeedback.lightImpact();
        if (newIndex > oldIndex) newIndex -= 1;
        ref.read(clockListProvider.notifier).reorder(oldIndex, newIndex);
      },
      itemCount: clocks.length + (showHint ? 1 : 0),
      itemBuilder: (context, index) {
        // Show first-launch hint after the single master clock
        if (showHint && index == clocks.length) {
          return Padding(
            key: const ValueKey('__first_launch_hint__'),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: Column(
              children: [
                Icon(
                  Icons.add_circle_outline_rounded,
                  color: AppColors.accent.withValues(alpha: 0.5),
                  size: 24,
                ),
                const SizedBox(height: 6),
                Text(
                  'Tap + to add more timezones',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Compare times across the world',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
                ),
              ],
            ),
          );
        }

        final clock = clocks[index];
        final dragHandle = Semantics(
          label: 'Drag to reorder',
          child: ReorderableDragStartListener(
            index: index,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: AppColors.glassFill.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.glassBorder.withValues(alpha: 0.25),
                  width: 0.5,
                ),
              ),
              child: Icon(
                Icons.drag_indicator_rounded,
                color: AppColors.textTertiary,
                size: 18,
              ),
            ),
          ),
        );

        if (index == 0) {
          return MasterClockDisplay(
            key: ValueKey(clock.id),
            clock: clock,
            dragHandle: dragHandle,
          );
        }

        return ChildClockCard(
          key: ValueKey(clock.id),
          clock: clock,
          index: index,
          dragHandle: dragHandle,
        );
      },
    );
  }
}

class _LoadingSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 72),
      child: Column(
        children: [
          // Master clock skeleton
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.glassFill.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.glassBorder.withValues(alpha: 0.1),
                width: 0.5,
              ),
            ),
            child: Column(
              children: [
                _shimmerBar(80, 20),
                const SizedBox(height: 12),
                _shimmerBar(140, 24),
                const SizedBox(height: 8),
                _shimmerBar(100, 14),
                const SizedBox(height: 16),
                _shimmerBar(280, 80),
                const SizedBox(height: 12),
                _shimmerBar(120, 16),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Child skeleton x2
          for (var i = 0; i < 2; i++) ...[
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.glassFill.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.glassBorder.withValues(alpha: 0.08),
                  width: 0.5,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _shimmerBar(120, 18),
                        const SizedBox(height: 6),
                        _shimmerBar(80, 12),
                      ],
                    ),
                  ),
                  _shimmerBar(100, 36),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  static Widget _shimmerBar(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.glassFill.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/datetime_extensions.dart';
import '../../../shared/widgets/animated_gradient_background.dart';
import '../../../shared/widgets/glassmorphic_card.dart';
import '../../../shared/widgets/glassmorphic_button.dart';
import '../../clock/providers/clock_list_provider.dart';
import '../../clock/providers/time_tick_provider.dart';
import '../../../core/utils/share_utils.dart';

class ComposeMessageScreen extends ConsumerStatefulWidget {
  const ComposeMessageScreen({super.key});

  @override
  ConsumerState<ComposeMessageScreen> createState() =>
      _ComposeMessageScreenState();
}

class _ComposeMessageScreenState extends ConsumerState<ComposeMessageScreen> {
  final _messageController = TextEditingController();
  bool _includeAllClocks = true;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clocks = ref.watch(clockListProvider);
    final use24Hour = ref.watch(use24HourProvider);
    final timeAsync = ref.watch(timeTickProvider);
    final previewOffset = ref.watch(timePreviewOffsetProvider);
    final previewMinutes = ref.watch(timePreviewOffsetMinutesProvider);

    return AnimatedGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Share Times'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SizedBox(height: 8),

              // Current times preview
              GlassmorphicCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          color: AppColors.accent,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Current Times',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    timeAsync.when(
                      data: (now) => Column(
                        children: clocks.map((clock) {
                          final time = clock.currentTime(
                            now.add(previewOffset),
                          );
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: Row(
                              children: [
                                if (clock.isMaster)
                                  Icon(
                                    Icons.star_rounded,
                                    size: 14,
                                    color: AppColors.masterBadge,
                                  )
                                else
                                  const SizedBox(width: 14),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    clock.displayName,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                ),
                                Text(
                                  time.formatTime(
                                    use24Hour: use24Hour,
                                    showSeconds: false,
                                  ),
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontFamily: 'monospace'),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                    if (previewMinutes != 0) ...[
                      const SizedBox(height: 10),
                      Text(
                        'Preview offset active',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Message input
              GlassmorphicCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Message (optional)',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _messageController,
                      maxLines: 4,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        hintText: 'Add a note to your shared times...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Options
              GlassmorphicCard(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Include all clocks',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Switch.adaptive(
                      value: _includeAllClocks,
                      activeThumbColor: AppColors.accent,
                      activeTrackColor: AppColors.accent.withValues(
                        alpha: 0.45,
                      ),
                      onChanged: (v) => setState(() => _includeAllClocks = v),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Share buttons
              Row(
                children: [
                  Expanded(
                    child: GlassmorphicButton(
                      onPressed: () => _shareFormatted(context),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.share_rounded,
                            color: AppColors.textPrimary,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Share Formatted',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GlassmorphicButton(
                      onPressed: () => _shareRaw(context),
                      accentColor: AppColors.accentSecondary,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.text_fields_rounded,
                            color: AppColors.textPrimary,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Share Raw',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Copy to clipboard
              Center(
                child: TextButton.icon(
                  onPressed: () => _copyToClipboard(context),
                  icon: Icon(Icons.copy_rounded, size: 16, color: AppColors.textSecondary),
                  label: Text(
                    'Copy to Clipboard',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  void _copyToClipboard(BuildContext context) {
    final clocks = ref.read(clockListProvider);
    final use24Hour = ref.read(use24HourProvider);
    final previewOffset = ref.read(timePreviewOffsetProvider);
    final message = _messageController.text.trim();

    final clocksToShare = _includeAllClocks ? clocks : [clocks.first];

    final text = ShareUtils.generateShareText(
      clocks: clocksToShare,
      now: DateTime.now().add(previewOffset),
      use24Hour: use24Hour,
      message: message,
    );

    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Copied to clipboard'),
        backgroundColor: AppColors.backgroundMid,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _shareFormatted(BuildContext context) {
    final clocks = ref.read(clockListProvider);
    final use24Hour = ref.read(use24HourProvider);
    final previewOffset = ref.read(timePreviewOffsetProvider);
    final message = _messageController.text.trim();

    final clocksToShare = _includeAllClocks ? clocks : [clocks.first];

    final text = ShareUtils.generateShareText(
      clocks: clocksToShare,
      now: DateTime.now().add(previewOffset),
      use24Hour: use24Hour,
      message: message,
    );

    _shareOrCopy(context, text);
  }

  void _shareRaw(BuildContext context) {
    final clocks = ref.read(clockListProvider);
    final use24Hour = ref.read(use24HourProvider);
    final previewOffset = ref.read(timePreviewOffsetProvider);
    final message = _messageController.text.trim();

    final clocksToShare = _includeAllClocks ? clocks : [clocks.first];

    final text = ShareUtils.generateRawText(
      clocks: clocksToShare,
      now: DateTime.now().add(previewOffset),
      use24Hour: use24Hour,
      message: message,
    );

    _shareOrCopy(context, text);
  }

  void _shareOrCopy(BuildContext context, String text) {
    if (kIsWeb) {
      Clipboard.setData(ClipboardData(text: text));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Copied to clipboard'),
          backgroundColor: AppColors.backgroundMid,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      ShareUtils.shareText(text);
    }
  }
}

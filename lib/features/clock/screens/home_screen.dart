import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/animated_gradient_background.dart';
import '../providers/clock_list_provider.dart';
import '../providers/time_tick_provider.dart';
import '../widgets/clock_list_view.dart';
import '../../search/screens/timezone_search_screen.dart';
import '../../settings/screens/settings_screen.dart';
import '../../bookmarks/screens/bookmarks_screen.dart';
import '../../messaging/screens/compose_message_screen.dart';
import '../../../core/utils/screenshot_utils.dart';
import '../../../core/utils/share_utils.dart';

enum _HomeMenuAction { shareMessage, bookmarks, settings }

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize clocks after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(clockListProvider.notifier).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final clocks = ref.watch(clockListProvider);
    final compactTopBar = MediaQuery.of(context).size.width < 430;

    return AnimatedGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: false,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          titleSpacing: 12,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.access_time_filled_rounded,
                color: AppColors.accent,
                size: 22,
              ),
              const SizedBox(width: 8),
              const Text(
                AppConstants.appName,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          actions: compactTopBar
              ? [
                  IconButton(
                    icon: const Icon(Icons.camera_alt_outlined, size: 20),
                    tooltip: 'Share Screenshot',
                    onPressed: () => _shareScreenshot(context),
                  ),
                  PopupMenuButton<_HomeMenuAction>(
                    icon: const Icon(Icons.more_horiz_rounded, size: 22),
                    onSelected: (action) => _handleMenuAction(context, action),
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: _HomeMenuAction.shareMessage,
                        child: Text('Share Message'),
                      ),
                      PopupMenuItem(
                        value: _HomeMenuAction.bookmarks,
                        child: Text('Bookmarks'),
                      ),
                      PopupMenuItem(
                        value: _HomeMenuAction.settings,
                        child: Text('Settings'),
                      ),
                    ],
                  ),
                ]
              : [
                  IconButton(
                    icon: const Icon(Icons.camera_alt_outlined, size: 20),
                    tooltip: 'Share Screenshot',
                    onPressed: () => _shareScreenshot(context),
                  ),
                  IconButton(
                    icon: const Icon(Icons.message_outlined, size: 20),
                    tooltip: 'Share Message',
                    onPressed: () => _openComposeMessage(context),
                  ),
                  IconButton(
                    icon: const Icon(Icons.bookmark_outline_rounded, size: 20),
                    tooltip: 'Bookmarks',
                    onPressed: () => _openBookmarks(context),
                  ),
                  IconButton(
                    icon: const Icon(Icons.tune_rounded, size: 20),
                    tooltip: 'Settings',
                    onPressed: () => _openSettings(context),
                  ),
                ],
        ),
        body: RepaintBoundary(
          key: ScreenshotUtils.screenshotKey,
          child: const ClockListView(),
        ),
        floatingActionButton: clocks.length < AppConstants.maxTotalClocks
            ? FloatingActionButton(
                onPressed: () => _showTimezoneSearch(context),
                child: const Icon(Icons.add_rounded),
              )
            : null,
      ),
    );
  }

  void _handleMenuAction(BuildContext context, _HomeMenuAction action) {
    switch (action) {
      case _HomeMenuAction.shareMessage:
        _openComposeMessage(context);
        break;
      case _HomeMenuAction.bookmarks:
        _openBookmarks(context);
        break;
      case _HomeMenuAction.settings:
        _openSettings(context);
        break;
    }
  }

  void _openComposeMessage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ComposeMessageScreen()),
    );
  }

  void _openBookmarks(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const BookmarksScreen()),
    );
  }

  void _openSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  void _showTimezoneSearch(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const TimezoneSearchScreen(),
    );
  }

  Future<void> _shareScreenshot(BuildContext context) async {
    final clocks = ref.read(clockListProvider);
    final use24Hour = ref.read(use24HourProvider);
    final previewOffset = ref.read(timePreviewOffsetProvider);
    final messenger = ScaffoldMessenger.of(context);

    if (clocks.isEmpty) return;

    // Show loading
    messenger.showSnackBar(
      SnackBar(
        content: const Text('Preparing screenshot...'),
        backgroundColor: AppColors.backgroundMid,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 1),
      ),
    );

    await Future<void>.delayed(const Duration(milliseconds: 100));
    await WidgetsBinding.instance.endOfFrame;

    final text = ShareUtils.generateShareText(
      clocks: clocks,
      now: DateTime.now().add(previewOffset),
      use24Hour: use24Hour,
    );

    final bytes = await ScreenshotUtils.captureAsBytes(
      pixelRatio: AppConstants.screenshotPixelRatio,
    );

    if (bytes != null && bytes.isNotEmpty) {
      if (!context.mounted) return;
      // Show preview dialog
      final shouldShare = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.backgroundMid,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Screenshot Preview'),
          content: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(bytes, fit: BoxFit.contain),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Share', style: TextStyle(color: AppColors.accent)),
            ),
          ],
        ),
      );

      if (shouldShare == true) {
        if (kIsWeb) {
          // On web, copy text since image sharing needs HTTPS
          Clipboard.setData(ClipboardData(text: text));
          if (context.mounted) {
            messenger.showSnackBar(
              SnackBar(
                content: const Text('Times copied to clipboard'),
                backgroundColor: AppColors.backgroundMid,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        } else {
          await ShareUtils.shareImage(
            bytes,
            text: 'Current world times from Neram',
          );
        }
      }
      return;
    }

    // Fallback: share as text
    if (kIsWeb) {
      Clipboard.setData(ClipboardData(text: text));
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: const Text('Times copied to clipboard'),
          backgroundColor: AppColors.backgroundMid,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      await ShareUtils.shareText(text);
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: const Text('Screenshot unavailable, shared text instead.'),
          backgroundColor: AppColors.backgroundMid,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/animated_gradient_background.dart';
import '../../../shared/widgets/glassmorphic_card.dart';
import '../../clock/providers/clock_list_provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final use24Hour = ref.watch(use24HourProvider);
    final showSeconds = ref.watch(showSecondsProvider);
    final settings = ref.read(settingsActionsProvider);

    return AnimatedGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Settings'),
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

              // Time Format Section
              _SectionHeader(title: 'Time Format'),
              const SizedBox(height: 8),
              GlassmorphicCard(
                child: Column(
                  children: [
                    _SettingsTile(
                      icon: Icons.schedule_rounded,
                      title: '24-Hour Format',
                      subtitle: use24Hour ? '14:30' : '2:30 PM',
                      trailing: Switch.adaptive(
                        value: use24Hour,
                        activeThumbColor: AppColors.accent,
                        activeTrackColor: AppColors.accent.withValues(
                          alpha: 0.45,
                        ),
                        onChanged: (v) => settings.toggle24Hour(v),
                      ),
                    ),
                    const Divider(height: 1),
                    _SettingsTile(
                      icon: Icons.timer_outlined,
                      title: 'Show Seconds',
                      subtitle: showSeconds ? 'HH:MM:SS' : 'HH:MM',
                      trailing: Switch.adaptive(
                        value: showSeconds,
                        activeThumbColor: AppColors.accent,
                        activeTrackColor: AppColors.accent.withValues(
                          alpha: 0.45,
                        ),
                        onChanged: (v) => settings.toggleShowSeconds(v),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Actions Section
              _SectionHeader(title: 'Actions'),
              const SizedBox(height: 8),
              GlassmorphicCard(
                child: Column(
                  children: [
                    _SettingsTile(
                      icon: Icons.restore_rounded,
                      title: 'Reset to Device Time',
                      subtitle: 'Remove all clocks, keep only device timezone',
                      onTap: () => _confirmReset(context, ref, settings),
                    ),
                    const Divider(height: 1),
                    _SettingsTile(
                      icon: Icons.delete_sweep_outlined,
                      title: 'Reset All Data',
                      subtitle: 'Clear all settings, bookmarks, and clocks',
                      iconColor: AppColors.danger,
                      onTap: () => _confirmResetAll(context, ref, settings),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // About Section
              _SectionHeader(title: 'About'),
              const SizedBox(height: 8),
              GlassmorphicCard(
                child: Column(
                  children: [
                    _SettingsTile(
                      icon: Icons.access_time_filled_rounded,
                      title: AppConstants.appName,
                      subtitle: AppConstants.appTagline,
                      iconColor: AppColors.accent,
                    ),
                    const Divider(height: 1),
                    _SettingsTile(
                      icon: Icons.info_outline_rounded,
                      title: 'Version',
                      subtitle: '1.0.0',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmReset(
    BuildContext context,
    WidgetRef ref,
    SettingsActions settings,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset to Device Time?'),
        content: const Text(
          'This will remove all added timezones and keep only your device timezone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              settings.resetToDeviceTime();
              Navigator.pop(context);
            },
            child: Text('Reset', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }

  void _confirmResetAll(
    BuildContext context,
    WidgetRef ref,
    SettingsActions settings,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset All Data?'),
        content: const Text(
          'This will clear all settings, bookmarks, and clock configurations. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              settings.resetAllData();
              Navigator.pop(context);
            },
            child: Text('Reset All', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textTertiary,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      leading: Icon(
        icon,
        color: iconColor ?? AppColors.textSecondary,
        size: 22,
      ),
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      trailing: trailing,
    );
  }
}

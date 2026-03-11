import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/app_routes.dart';
import '../../../config/app_theme.dart';
import '../../../providers/settings_provider.dart';
import '../../../widgets/common/async_value_widget.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontFamily: 'Sora',
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimaryLight,
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.borderLight),
        ),
      ),
      body: AsyncValueWidget<AppSettings>(
        value: settingsAsync,
        data: (settings) => _SettingsBody(settings: settings),
      ),
    );
  }
}

// ── Body ───────────────────────────────────────────────────────────────────────
class _SettingsBody extends ConsumerWidget {
  const _SettingsBody({required this.settings});
  final AppSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(settingsProvider.notifier);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── Appearance ─────────────────────────────────────────────────────
        const _SectionTitle(title: 'Appearance'),
        const SizedBox(height: 8),
        _Card(
          children: [
            _SwitchTile(
              icon: Icons.dark_mode_outlined,
              label: 'Dark Mode',
              subtitle: 'Switch to dark theme',
              value: settings.isDarkMode,
              onChanged: (_) => notifier.toggleDarkMode(),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // ── Notifications ──────────────────────────────────────────────────
        _SectionTitle(title: 'Notifications'),
        const SizedBox(height: 8),
        _Card(
          children: [
            _SwitchTile(
              icon: Icons.notifications_outlined,
              label: 'Push Notifications',
              subtitle: 'Receive alerts on your device',
              value: settings.notificationsEnabled,
              onChanged: (v) => notifier.setNotificationsEnabled(v),
            ),
            const Divider(height: 1, indent: 46, color: AppColors.borderLight),
            _LinkTile(
              icon: Icons.tune_rounded,
              label: 'Notification Preferences',
              subtitle: 'Manage what you get notified about',
              onTap: () => context.push(AppRoutes.notificationSettings),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // ── About ──────────────────────────────────────────────────────────
        const _SectionTitle(title: 'About'),
        const SizedBox(height: 8),
        _Card(
          children: [
            const _InfoTile(
              icon: Icons.info_outline_rounded,
              label: 'App Version',
              value: '1.0.0',
            ),
            const Divider(height: 1, indent: 46, color: AppColors.borderLight),
            _LinkTile(
              icon: Icons.privacy_tip_outlined,
              label: 'Privacy Policy',
              onTap: () {},
            ),
            const Divider(height: 1, indent: 46, color: AppColors.borderLight),
            _LinkTile(
              icon: Icons.description_outlined,
              label: 'Terms of Service',
              onTap: () {},
            ),
          ],
        ),

        const SizedBox(height: 32),
      ],
    );
  }
}

// ── Shared tile widgets ────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) => Text(
    title,
    style: const TextStyle(
      fontFamily: 'Sora',
      fontSize: 13,
      fontWeight: FontWeight.w700,
      color: AppColors.textSecondaryLight,
    ),
  );
}

class _Card extends StatelessWidget {
  const _Card({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.borderLight),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(children: children),
  );
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondaryLight),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 11,
                      color: AppColors.textHintLight,
                    ),
                  ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.orangeBright,
          ),
        ],
      ),
    );
  }
}

class _LinkTile extends StatelessWidget {
  const _LinkTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.textSecondaryLight),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 11,
                        color: AppColors.textHintLight,
                      ),
                    ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: AppColors.textHintLight,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondaryLight),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Sora',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimaryLight,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 13,
              color: AppColors.textHintLight,
            ),
          ),
        ],
      ),
    );
  }
}

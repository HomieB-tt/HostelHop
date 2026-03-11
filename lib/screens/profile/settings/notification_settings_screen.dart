import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/app_theme.dart';
import '../../../providers/settings_provider.dart';
import '../../../widgets/common/async_value_widget.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Notifications',
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
        data: (settings) => _NotifBody(settings: settings),
      ),
    );
  }
}

// ── Body ───────────────────────────────────────────────────────────────────────
class _NotifBody extends ConsumerWidget {
  const _NotifBody({required this.settings});
  final AppSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(settingsProvider.notifier);
    final masterOn = settings.notificationsEnabled;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── Master switch ──────────────────────────────────────────────────
        _Card(
          children: [
            _SwitchTile(
              icon: Icons.notifications_rounded,
              label: 'Push Notifications',
              subtitle: masterOn
                  ? 'All notifications are enabled'
                  : 'All notifications are paused',
              value: masterOn,
              onChanged: (v) => notifier.setNotificationsEnabled(v),
              activeColor: AppColors.orangeBright,
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Master off note
        if (!masterOn)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 14,
                  color: AppColors.textHintLight,
                ),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Enable push notifications above to '
                    'configure individual alert types.',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 11,
                      color: AppColors.textHintLight,
                    ),
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 16),

        // ── Alert types ────────────────────────────────────────────────────
        const _SectionTitle(title: 'Alert Types'),
        const SizedBox(height: 8),
        _Card(
          children: [
            // Booking alerts
            _SwitchTile(
              icon: Icons.book_online_outlined,
              label: 'Booking Alerts',
              subtitle: 'Confirmation, cancellation & reminders',
              value: masterOn && settings.bookingAlertsEnabled,
              onChanged: masterOn
                  ? (v) => notifier.setBookingAlertsEnabled(v)
                  : null,
              activeColor: AppColors.blueLight,
            ),
            const Divider(height: 1, indent: 46, color: AppColors.borderLight),

            // Promo alerts
            _SwitchTile(
              icon: Icons.local_offer_outlined,
              label: 'Promotions & Deals',
              subtitle: 'Discounts and special offers from hostels',
              value: masterOn && settings.promoAlertsEnabled,
              onChanged: masterOn
                  ? (v) => notifier.setPromoAlertsEnabled(v)
                  : null,
              activeColor: AppColors.blueLight,
            ),
          ],
        ),

        const SizedBox(height: 16),

        // ── Info banner ────────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.blueLight.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.blueLight.withValues(alpha: 0.2),
            ),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 16,
                color: AppColors.blueLight,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'You can also manage notification permissions '
                  'for HostelHop in your device Settings.',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 12,
                    color: AppColors.textSecondaryLight,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),
      ],
    );
  }
}

// ── Shared helpers ─────────────────────────────────────────────────────────────

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
    this.activeColor,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeColor;

  @override
  Widget build(BuildContext context) {
    final enabled = onChanged != null;

    return Opacity(
      opacity: enabled ? 1.0 : 0.45,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: value && enabled
                  ? (activeColor ?? AppColors.orangeBright)
                  : AppColors.textSecondaryLight,
            ),
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
              activeThumbColor: activeColor ?? AppColors.orangeBright,
            ),
          ],
        ),
      ),
    );
  }
}

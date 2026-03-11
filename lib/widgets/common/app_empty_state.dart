import 'package:flutter/material.dart';

import '../../../config/app_theme.dart';

/// Reusable empty state widget.
///
/// Usage — simple:
///   AppEmptyState(
///     emoji: '🏚️',
///     title: 'No hostels found',
///     subtitle: 'Check back soon.',
///   )
///
/// Usage — with CTA:
///   AppEmptyState(
///     emoji: '📋',
///     title: 'No bookings yet',
///     subtitle: 'Start by browsing available hostels.',
///     ctaLabel: 'Browse Hostels',
///     onCta: () => context.go(AppRoutes.home),
///   )
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.emoji,
    required this.title,
    this.subtitle,
    this.ctaLabel,
    this.onCta,
    this.padding = const EdgeInsets.symmetric(vertical: 60, horizontal: 32),
  });

  final String emoji;
  final String title;
  final String? subtitle;
  final String? ctaLabel;
  final VoidCallback? onCta;
  final EdgeInsets padding;

  // ── Preset factories ───────────────────────────────────────────────────────
  factory AppEmptyState.noHostels() => const AppEmptyState(
    emoji: '🏚️',
    title: 'No hostels found',
    subtitle: 'Check back soon — new hostels are being added.',
  );

  factory AppEmptyState.noBookings() => const AppEmptyState(
    emoji: '📋',
    title: 'No bookings yet',
    subtitle: 'Browse hostels to find your perfect room.',
  );

  factory AppEmptyState.noPastBookings() => const AppEmptyState(
    emoji: '🗂️',
    title: 'No past bookings',
    subtitle: 'Your completed stays will appear here.',
  );

  factory AppEmptyState.noCancelledBookings() => const AppEmptyState(
    emoji: '✅',
    title: 'No cancellations',
    subtitle: "You haven't cancelled any bookings.",
  );

  factory AppEmptyState.noReviews() => const AppEmptyState(
    emoji: '💬',
    title: 'No reviews yet',
    subtitle: 'Be the first to share your experience.',
  );

  factory AppEmptyState.noResults({Null Function()? onCta}) =>
      const AppEmptyState(
        emoji: '🔍',
        title: 'No results found',
        subtitle: 'Try adjusting your search or filters.',
      );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Sora',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimaryLight,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontSize: 13,
                color: AppColors.textSecondaryLight,
                height: 1.5,
              ),
            ),
          ],
          if (ctaLabel != null && onCta != null) ...[
            const SizedBox(height: 24),
            FilledButton(
              onPressed: onCta,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.orangeBright,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 12,
                ),
                shape: const StadiumBorder(),
              ),
              child: Text(
                ctaLabel!,
                style: const TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

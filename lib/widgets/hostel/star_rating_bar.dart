import 'package:flutter/material.dart';

import '../../../config/app_theme.dart';

/// A row of 5 stars with a numeric rating label and optional review count.
///
/// Usage:
///   StarRatingBar(rating: 4.3)
///   StarRatingBar(rating: 4.3, reviewCount: 28)
///   StarRatingBar(rating: 4.3, reviewCount: 28, size: 16)
///   StarRatingBar(rating: 4.3, showCount: false)  // stars + number only
class StarRatingBar extends StatelessWidget {
  const StarRatingBar({
    super.key,
    required this.rating,
    this.reviewCount,
    this.size = 13.0,
    this.showCount = true,
  });

  final double rating;
  final int? reviewCount;
  final double size;
  final bool showCount;

  @override
  Widget build(BuildContext context) {
    final filled = rating.floor();
    final hasHalf = (rating - filled) >= 0.5;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Stars ──────────────────────────────────────────────────────────────
        for (int i = 0; i < 5; i++)
          Icon(
            i < filled
                ? Icons.star_rounded
                : (i == filled && hasHalf)
                    ? Icons.star_half_rounded
                    : Icons.star_outline_rounded,
            size: size,
            color: const Color(0xFFFFB300),
          ),

        const SizedBox(width: 4),

        // ── Numeric rating ─────────────────────────────────────────────────────
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            fontFamily: 'Sora',
            fontSize: size * 0.85,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimaryLight,
          ),
        ),

        // ── Review count ───────────────────────────────────────────────────────
        if (showCount && reviewCount != null)
          Text(
            ' (${reviewCount})',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: size * 0.77,
              color: AppColors.textHintLight,
            ),
          ),
      ],
    );
  }
}

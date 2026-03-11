import 'package:flutter/material.dart';

import '../../../config/app_theme.dart';
import '../../../models/review_model.dart';
import '../common/app_network_image.dart';
import '../hostel/star_rating_bar.dart';

/// A single review card — used in hostel_detail_screen (preview)
/// and hostel_reviews_screen (full list).
///
///   ReviewCard(review: review)
///   ReviewCard(review: review, showOwnerReply: true)
class ReviewCard extends StatelessWidget {
  const ReviewCard({
    super.key,
    required this.review,
    this.showOwnerReply = true,
    this.onHelpful,
    this.onOwnerReply,
  });

  final ReviewModel review;
  final bool showOwnerReply;
  final VoidCallback? onHelpful;

  /// Called when an owner taps "Reply" on a review that has no reply yet.
  final VoidCallback? onOwnerReply;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Reviewer row ────────────────────────────────────────────────────
          Row(
            children: [
              // Avatar
              _Avatar(review: review),
              const SizedBox(width: 10),

              // Name + date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: const TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      review.timeAgoLabel,
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 11,
                        color: AppColors.textHintLight,
                      ),
                    ),
                  ],
                ),
              ),

              // Star rating
              StarRatingBar(rating: review.rating, showCount: false, size: 12),
            ],
          ),

          const SizedBox(height: 10),

          // ── Comment ─────────────────────────────────────────────────────────
          Text(
            review.comment,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 13,
              color: AppColors.textSecondaryLight,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 10),

          // ── Helpful row ─────────────────────────────────────────────────────
          Row(
            children: [
              if (review.helpfulCount > 0) ...[
                Text(
                  '👍 ${review.helpfulCount} found this helpful',
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 11,
                    color: AppColors.textHintLight,
                  ),
                ),
              ],
              const Spacer(),
              if (onOwnerReply != null) ...[
                GestureDetector(
                  onTap: onOwnerReply,
                  child: const Text(
                    'Reply',
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.blueLight,
                    ),
                  ),
                ),
                if (onHelpful != null) const SizedBox(width: 12),
              ],
              if (onHelpful != null)
                GestureDetector(
                  onTap: onHelpful,
                  child: const Text(
                    'Helpful',
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.orangeBright,
                    ),
                  ),
                ),
            ],
          ),

          // ── Owner reply ─────────────────────────────────────────────────────
          if (showOwnerReply && review.hasOwnerReply) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.apartment_rounded,
                        size: 13,
                        color: AppColors.orangeBright,
                      ),
                      SizedBox(width: 5),
                      Text(
                        'Owner replied',
                        style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.orangeBright,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    review.ownerReply!,
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 12,
                      color: AppColors.textSecondaryLight,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Avatar ──────────────────────────────────────────────────────────────────────
class _Avatar extends StatelessWidget {
  const _Avatar({required this.review});
  final ReviewModel review;

  @override
  Widget build(BuildContext context) {
    if (review.userAvatarUrl != null) {
      return AppNetworkImage.avatar(url: review.userAvatarUrl, size: 38, initials: null, radius: ,);
    }

    // Fallback: initial letter circle
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: AppColors.orangeBright.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          review.userInitial,
          style: const TextStyle(
            fontFamily: 'Sora',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.orangeBright,
          ),
        ),
      ),
    );
  }
}

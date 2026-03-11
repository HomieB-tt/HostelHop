import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/app_theme.dart';
import '../../models/review_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/hostel_provider.dart';
import '../../providers/review_provider.dart';
import '../../widgets/common/async_value_widget.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_empty_state.dart';
import '../../widgets/hostel/star_rating_bar.dart';
import '../../widgets/review/review_card.dart';
import '../../widgets/review/review_input_form.dart';

/// Full reviews screen for a hostel.
/// Shows a rating summary, sort controls, the review list,
/// and a "Write a Review" sheet for logged-in students.
///
/// Route: AppRoutes.hostelReviews(hostelId)
class HostelReviewsScreen extends ConsumerStatefulWidget {
  const HostelReviewsScreen({super.key, required this.hostelId});
  final String hostelId;

  @override
  ConsumerState<HostelReviewsScreen> createState() =>
      _HostelReviewsScreenState();
}

class _HostelReviewsScreenState extends ConsumerState<HostelReviewsScreen> {
  _SortOrder _sort = _SortOrder.newest;

  List<ReviewModel> _sorted(List<ReviewModel> reviews) {
    final list = List<ReviewModel>.from(reviews);
    switch (_sort) {
      case _SortOrder.newest:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case _SortOrder.highest:
        list.sort((a, b) => b.rating.compareTo(a.rating));
      case _SortOrder.lowest:
        list.sort((a, b) => a.rating.compareTo(b.rating));
      case _SortOrder.helpful:
        list.sort((a, b) => b.helpfulCount.compareTo(a.helpfulCount));
    }
    return list;
  }

  void _showWriteReviewSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _WriteReviewSheet(hostelId: widget.hostelId),
    );
  }

  void _showOwnerReplySheet(ReviewModel review) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) =>
          _OwnerReplySheet(hostelId: widget.hostelId, review: review),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hostelAsync = ref.watch(hostelDetailProvider(widget.hostelId));
    final reviewsAsync = ref.watch(hostelReviewsProvider(widget.hostelId));
    final auth = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          // ── App bar ────────────────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.white,
            foregroundColor: AppColors.textPrimaryLight,
            elevation: 0,
            title: hostelAsync.when(
              loading: () => const Text('Reviews'),
              error: (_, __) => const Text('Reviews'),
              data: (h) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Reviews',
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    h.name,
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 11,
                      color: AppColors.textHintLight,
                    ),
                  ),
                ],
              ),
            ),
            bottom: const PreferredSize(
              preferredSize: Size.fromHeight(1),
              child: Divider(height: 1, color: AppColors.borderLight),
            ),
          ),

          // ── Rating summary ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: hostelAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (hostel) => _RatingSummary(
                rating: hostel.rating,
                reviewCount: hostel.reviewCount,
                reviews: reviewsAsync.valueOrNull ?? [],
              ),
            ),
          ),

          // ── Sort bar + write button ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Row(
                children: [
                  // Sort dropdown
                  _SortDropdown(
                    value: _sort,
                    onChanged: (s) => setState(() => _sort = s),
                  ),
                  const Spacer(),
                  // Write review — only for non-owners
                  if (!auth.isOwner)
                    AppButton(
                      label: 'Write a Review',
                      onPressed: _showWriteReviewSheet,
                      fullWidth: false,
                      icon: Icons.rate_review_outlined,
                      height: 38,
                    ),
                ],
              ),
            ),
          ),

          // ── Reviews list ───────────────────────────────────────────────────
          SliverAsyncValueWidget<List<ReviewModel>>(
            value: reviewsAsync,
            isEmpty: (r) => r.isEmpty,
            empty: const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: AppEmptyState(
                  emoji: '💬',
                  title: 'No reviews yet',
                  subtitle: 'Be the first to share your experience.',
                ),
              ),
            ),
            data: (reviews) {
              final sorted = _sorted(reviews);
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ReviewCard(
                        review: sorted[i],
                        showOwnerReply: true,
                        onHelpful: () => ref
                            .read(
                              hostelReviewsProvider(widget.hostelId).notifier,
                            )
                            .markHelpful(sorted[i].id, widget.hostelId),
                        // Owner reply action (only for owners)
                        onOwnerReply: auth.isOwner && !sorted[i].hasOwnerReply
                            ? () => _showOwnerReplySheet(sorted[i])
                            : null,
                      ),
                    ),
                    childCount: sorted.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

extension on AsyncValue<List<ReviewModel>> {
  List<ReviewModel>? get valueOrNull => null;
}

// ── Rating summary ─────────────────────────────────────────────────────────────
class _RatingSummary extends StatelessWidget {
  const _RatingSummary({
    required this.rating,
    required this.reviewCount,
    required this.reviews,
  });

  final double rating;
  final int reviewCount;
  final List<ReviewModel> reviews;

  /// Count of reviews per star (5 → 1)
  Map<int, int> get _breakdown {
    final map = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (final r in reviews) {
      final star = r.rating.round().clamp(1, 5);
      map[star] = (map[star] ?? 0) + 1;
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final breakdown = _breakdown;
    final total = reviewCount > 0 ? reviewCount : 1;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Big rating number
          Column(
            children: [
              Text(
                rating.toStringAsFixed(1),
                style: const TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimaryLight,
                  height: 1,
                ),
              ),
              const SizedBox(height: 6),
              StarRatingBar(rating: rating, showCount: false, size: 14),
              const SizedBox(height: 4),
              Text(
                '$reviewCount review${reviewCount == 1 ? '' : 's'}',
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 11,
                  color: AppColors.textHintLight,
                ),
              ),
            ],
          ),

          const SizedBox(width: 20),
          const VerticalDivider(width: 1, color: AppColors.borderLight),
          const SizedBox(width: 20),

          // Star breakdown bars
          Expanded(
            child: Column(
              children: [5, 4, 3, 2, 1].map((star) {
                final count = breakdown[star] ?? 0;
                final fraction = count / total;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Text(
                        '$star',
                        style: const TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.star_rounded,
                        size: 11,
                        color: Color(0xFFFFB300),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: fraction,
                            minHeight: 7,
                            backgroundColor: AppColors.borderLight,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFFFFB300),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      SizedBox(
                        width: 20,
                        child: Text(
                          '$count',
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 11,
                            color: AppColors.textHintLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sort dropdown ──────────────────────────────────────────────────────────────
enum _SortOrder { newest, highest, lowest, helpful }

class _SortDropdown extends StatelessWidget {
  const _SortDropdown({required this.value, required this.onChanged});

  final _SortOrder value;
  final ValueChanged<_SortOrder> onChanged;

  static const _labels = {
    _SortOrder.newest: 'Newest first',
    _SortOrder.highest: 'Highest rated',
    _SortOrder.lowest: 'Lowest rated',
    _SortOrder.helpful: 'Most helpful',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<_SortOrder>(
          value: value,
          isDense: true,
          style: const TextStyle(
            fontFamily: 'Sora',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryLight,
          ),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 16,
            color: AppColors.textHintLight,
          ),
          items: _SortOrder.values
              .map((s) => DropdownMenuItem(value: s, child: Text(_labels[s]!)))
              .toList(),
          onChanged: (s) {
            if (s != null) onChanged(s);
          },
        ),
      ),
    );
  }
}

// ── Write review bottom sheet ──────────────────────────────────────────────────
class _WriteReviewSheet extends ConsumerWidget {
  const _WriteReviewSheet({required this.hostelId});
  final String hostelId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(hostelReviewsProvider(hostelId)).isLoading;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Write a Review',
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 16),
            ReviewInputForm(
              isLoading: isLoading,
              onSubmit: (rating, comment) async {
                await ref
                    .read(hostelReviewsProvider(hostelId).notifier)
                    .submitReview(
                      hostelId: hostelId,
                      rating: rating,
                      comment: comment,
                    );
                if (context.mounted) Navigator.pop(context);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ── Owner reply bottom sheet ───────────────────────────────────────────────────
class _OwnerReplySheet extends ConsumerStatefulWidget {
  const _OwnerReplySheet({required this.hostelId, required this.review});

  final String hostelId;
  final ReviewModel review;

  @override
  ConsumerState<_OwnerReplySheet> createState() => _OwnerReplySheetState();
}

class _OwnerReplySheetState extends ConsumerState<_OwnerReplySheet> {
  final _ctrl = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_ctrl.text.trim().isEmpty) return;
    setState(() => _isSaving = true);

    try {
      await ref
          .read(hostelReviewsProvider(widget.hostelId).notifier)
          .replyToReview(
            hostelId: widget.hostelId,
            reviewId: widget.review.id,
            reply: _ctrl.text.trim(),
          );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Reply to Review',
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '"${widget.review.comment.length > 80 ? '${widget.review.comment.substring(0, 80)}…' : widget.review.comment}"',
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontSize: 12,
                color: AppColors.textHintLight,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),

            // Reply field
            TextFormField(
              controller: _ctrl,
              minLines: 3,
              maxLines: 5,
              autofocus: true,
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontSize: 14,
                color: AppColors.textPrimaryLight,
              ),
              decoration: InputDecoration(
                hintText: 'Thank the reviewer or address their concern…',
                hintStyle: const TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 13,
                  color: AppColors.textHintLight,
                ),
                filled: true,
                fillColor: AppColors.backgroundLight,
                contentPadding: const EdgeInsets.all(14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.borderLight),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.borderLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.orangeBright,
                    width: 1.5,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            AppButton(
              label: 'Post Reply',
              onPressed: _isSaving ? null : _submit,
              isLoading: _isSaving,
              icon: Icons.reply_rounded,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

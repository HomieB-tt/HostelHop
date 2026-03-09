import 'package:flutter/material.dart';

import '../../../config/app_theme.dart';
import '../common/app_button.dart';

/// A form widget for submitting a hostel review.
/// Includes an interactive star selector and a comment text field.
///
/// Usage:
///   ReviewInputForm(
///     onSubmit: (rating, comment) => ref
///       .read(reviewProvider(hostelId).notifier)
///       .submitReview(rating: rating, comment: comment),
///     isLoading: state.isLoading,
///   )
class ReviewInputForm extends StatefulWidget {
  const ReviewInputForm({
    super.key,
    required this.onSubmit,
    this.isLoading = false,
    this.initialRating = 0,
    this.initialComment = '',
  });

  final Future<void> Function(double rating, String comment) onSubmit;
  final bool isLoading;
  final double initialRating;
  final String initialComment;

  @override
  State<ReviewInputForm> createState() => _ReviewInputFormState();
}

class _ReviewInputFormState extends State<ReviewInputForm> {
  final _formKey = GlobalKey<FormState>();
  late double _rating;
  late final TextEditingController _commentController;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;
    _commentController =
        TextEditingController(text: widget.initialComment);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a star rating.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await widget.onSubmit(_rating, _commentController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Star selector ─────────────────────────────────────────────────
          const Text(
            'Your Rating',
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final starValue = (i + 1).toDouble();
              return GestureDetector(
                onTap: () => setState(() => _rating = starValue),
                child: AnimatedScale(
                  scale: _rating >= starValue ? 1.15 : 1.0,
                  duration: const Duration(milliseconds: 150),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(
                      _rating >= starValue
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 38,
                      color: _rating >= starValue
                          ? const Color(0xFFFFB300)
                          : AppColors.borderLight,
                    ),
                  ),
                ),
              );
            }),
          ),

          // Rating label
          if (_rating > 0) ...[
            const SizedBox(height: 8),
            Center(
              child: Text(
                _ratingLabel(_rating),
                style: const TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.orangeBright,
                ),
              ),
            ),
          ],

          const SizedBox(height: 20),

          // ── Comment field ─────────────────────────────────────────────────
          const Text(
            'Your Review',
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 6),

          TextFormField(
            controller: _commentController,
            minLines: 3,
            maxLines: 6,
            maxLength: 500,
            textInputAction: TextInputAction.newline,
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Please write a short review.';
              }
              if (v.trim().length < 20) {
                return 'Review must be at least 20 characters.';
              }
              return null;
            },
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 14,
              color: AppColors.textPrimaryLight,
            ),
            decoration: InputDecoration(
              hintText:
                  'Share your experience — cleanliness, location, value…',
              hintStyle: const TextStyle(
                fontFamily: 'Roboto',
                fontSize: 13,
                color: AppColors.textHintLight,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
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
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.error),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppColors.error, width: 1.5),
              ),
              counterStyle: const TextStyle(
                fontFamily: 'Roboto',
                fontSize: 11,
                color: AppColors.textHintLight,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── Submit button ─────────────────────────────────────────────────
          AppButton(
            label: 'Submit Review',
            onPressed: widget.isLoading ? null : _submit,
            isLoading: widget.isLoading,
            icon: Icons.rate_review_outlined,
          ),
        ],
      ),
    );
  }

  String _ratingLabel(double rating) {
    switch (rating.toInt()) {
      case 1:
        return '😞 Poor';
      case 2:
        return '😐 Fair';
      case 3:
        return '🙂 Good';
      case 4:
        return '😊 Very Good';
      case 5:
        return '🤩 Excellent!';
      default:
        return '';
    }
  }
}

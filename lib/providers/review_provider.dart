import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/review_model.dart';
import '../../repositories/review_repository.dart';

part 'review_provider.g.dart';

// ── Reviews for a hostel (family) ──────────────────────────────────────────────
/// Watched by hostel_reviews_screen as:
///   final reviewsAsync = ref.watch(hostelReviewsProvider(hostelId));
@riverpod
class HostelReviews extends _$HostelReviews {
  late final ReviewRepository _repo;

  @override
  Future<List<ReviewModel>> build(String hostelId) async {
    _repo = const ReviewRepository();
    return _repo.fetchByHostel(hostelId);
  }

  // ── Refresh ────────────────────────────────────────────────────────────────
  Future<void> refresh(String hostelId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.fetchByHostel(hostelId));
  }

  // ── Submit review ──────────────────────────────────────────────────────────
  Future<void> submitReview({
    required String hostelId,
    required double rating,
    required String comment,
  }) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    await _repo.create({
      'hostel_id': hostelId,
      'user_id': userId,
      'rating': rating,
      'comment': comment,
    });

    // Refresh list after submit
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.fetchByHostel(hostelId));
  }

  // ── Owner reply ────────────────────────────────────────────────────────────
  Future<void> replyToReview({
    required String hostelId,
    required String reviewId,
    required String reply,
  }) async {
    await _repo.addOwnerReply(reviewId: reviewId, reply: reply);

    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.fetchByHostel(hostelId));
  }

  // ── Mark helpful ───────────────────────────────────────────────────────────
  Future<void> markHelpful(String reviewId, String hostelId) async {
    await _repo.markHelpful(reviewId);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.fetchByHostel(hostelId));
  }
}

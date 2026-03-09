import '../../models/review_model.dart';
import '../../supabase/supabase_client.dart';

class ReviewRepository {
  const ReviewRepository();

  static const _table = 'reviews';

  // ── Fetch all reviews for a hostel ────────────────────────────────────────
  Future<List<ReviewModel>> fetchByHostel(String hostelId) async {
    final response = await supabase
        .from(_table)
        .select()
        .eq('hostel_id', hostelId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Fetch single review ────────────────────────────────────────────────────
  Future<ReviewModel> fetchById(String reviewId) async {
    final response = await supabase
        .from(_table)
        .select()
        .eq('id', reviewId)
        .single();

    return ReviewModel.fromJson(response);
  }

  // ── Fetch reviews by user ──────────────────────────────────────────────────
  Future<List<ReviewModel>> fetchByUser(String userId) async {
    final response = await supabase
        .from(_table)
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Create review ──────────────────────────────────────────────────────────
  Future<ReviewModel> create(Map<String, dynamic> data) async {
    final response = await supabase
        .from(_table)
        .insert(data)
        .select()
        .single();

    return ReviewModel.fromJson(response);
  }

  // ── Owner reply to a review ────────────────────────────────────────────────
  Future<ReviewModel> addOwnerReply({
    required String reviewId,
    required String reply,
  }) async {
    final response = await supabase
        .from(_table)
        .update({
          'owner_reply': reply,
          'owner_reply_at': DateTime.now().toIso8601String(),
        })
        .eq('id', reviewId)
        .select()
        .single();

    return ReviewModel.fromJson(response);
  }

  // ── Mark review as helpful ─────────────────────────────────────────────────
  Future<void> markHelpful(String reviewId) async {
    await supabase.rpc(
      'increment_review_helpful',
      params: {'review_id': reviewId},
    );
  }

  // ── Delete review ──────────────────────────────────────────────────────────
  Future<void> delete(String reviewId) async {
    await supabase.from(_table).delete().eq('id', reviewId);
  }

  // ── Realtime stream — reviews for a hostel ────────────────────────────────
  Stream<List<ReviewModel>> streamByHostel(String hostelId) {
    return supabase
        .from(_table)
        .stream(primaryKey: ['id'])
        .eq('hostel_id', hostelId)
        .map((rows) => rows
            .map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
            .toList());
  }
}

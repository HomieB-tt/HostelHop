import '../../models/booking_model.dart';
import '../../supabase/supabase_client.dart';

class BookingRepository {
  const BookingRepository();

  static const _table = 'bookings';

  // ── Fetch all bookings for the current user ────────────────────────────────
  Future<List<BookingModel>> fetchByUser(String userId) async {
    final response = await supabase
        .from(_table)
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((e) => BookingModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Fetch single booking by id ─────────────────────────────────────────────
  Future<BookingModel> fetchById(String bookingId) async {
    final response = await supabase
        .from(_table)
        .select()
        .eq('id', bookingId)
        .single();

    return BookingModel.fromJson(response);
  }

  // ── Fetch bookings by hostel (owner view) ──────────────────────────────────
  Future<List<BookingModel>> fetchByHostel(String hostelId) async {
    final response = await supabase
        .from(_table)
        .select()
        .eq('hostel_id', hostelId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((e) => BookingModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Create booking ─────────────────────────────────────────────────────────
  Future<BookingModel> create(Map<String, dynamic> data) async {
    final response = await supabase
        .from(_table)
        .insert(data)
        .select()
        .single();

    return BookingModel.fromJson(response);
  }

  // ── Update booking status ─────────────────────────────────────────────────
  Future<BookingModel> updateStatus(
    String bookingId,
    BookingStatus status,
  ) async {
    final response = await supabase
        .from(_table)
        .update({'status': status.value})
        .eq('id', bookingId)
        .select()
        .single();

    return BookingModel.fromJson(response);
  }

  // ── Record commitment fee payment ─────────────────────────────────────────
  Future<BookingModel> recordCommitmentPayment({
    required String bookingId,
    required int amount,
    required String paymentMethod,
    required String paymentPhone,
  }) async {
    final response = await supabase
        .from(_table)
        .update({
          'commitment_fee_paid': amount,
          'payment_method': paymentMethod,
          'payment_phone': paymentPhone,
          'status': BookingStatus.confirmed.value,
        })
        .eq('id', bookingId)
        .select()
        .single();

    return BookingModel.fromJson(response);
  }

  // ── Cancel booking ─────────────────────────────────────────────────────────
  Future<BookingModel> cancel(String bookingId) async {
    return updateStatus(bookingId, BookingStatus.cancelled);
  }

  // ── Complete booking ───────────────────────────────────────────────────────
  Future<BookingModel> complete(String bookingId) async {
    return updateStatus(bookingId, BookingStatus.completed);
  }

  // ── Realtime stream — user bookings ───────────────────────────────────────
  Stream<List<BookingModel>> streamByUser(String userId) {
    return supabase
        .from(_table)
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .map((rows) => rows
            .map((e) => BookingModel.fromJson(e as Map<String, dynamic>))
            .toList());
  }
}

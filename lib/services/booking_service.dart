import '../../models/booking_model.dart';
import '../../repositories/booking_repository.dart';
import '../../repositories/hostel_repository.dart';
import '../../repositories/room_repository.dart';
import '../../supabase/supabase_client.dart';

/// Orchestrates multi-step booking operations.
/// Coordinates BookingRepository + RoomRepository + HostelRepository
/// so providers never have to touch multiple repos directly.
class BookingService {
  BookingService({
    BookingRepository? bookingRepository,
    RoomRepository? roomRepository,
    HostelRepository? hostelRepository,
  }) : _bookingRepo = bookingRepository ?? const BookingRepository(),
       _roomRepo = roomRepository ?? const RoomRepository(),
       _hostelRepo = hostelRepository ?? const HostelRepository();

  final BookingRepository _bookingRepo;
  final RoomRepository _roomRepo;
  final HostelRepository _hostelRepo;

  // ── Create a pending booking (called from BookingScreen) ──────────────────
  /// Creates the booking row with status=pending.
  /// Does NOT decrement room slots yet — that happens after payment confirms.
  Future<BookingModel> createPendingBooking({
    required String hostelId,
    required String roomId,
    required String hostelName,
    required String roomType,
    required int totalAmount,
    required int commitmentFee,
    required DateTime moveInDate,
    required DateTime moveOutDate,
  }) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    // Verify room still has availability
    final room = await _roomRepo.fetchById(roomId);
    if (room.availableSlots <= 0) {
      throw Exception(
        'This room is no longer available. Please choose another.',
      );
    }

    final reference = _generateReference();

    return _bookingRepo.create({
      'user_id': userId,
      'hostel_id': hostelId,
      'room_id': roomId,
      'hostel_name': hostelName,
      'room_type': roomType,
      'reference': reference,
      'status': BookingStatus.pending.value,
      'total_amount': totalAmount,
      'commitment_fee_amount': commitmentFee,
      'commitment_fee_paid': 0,
      'check_in_date': moveInDate.toIso8601String(),
      'check_out_date': moveOutDate.toIso8601String(),
    });
  }

  // ── Initiate payment (called from PaymentScreen) ──────────────────────────
  /// Records the payment details and marks booking as confirmed.
  /// Also decrements room slots and hostel rooms_available.
  Future<BookingModel> initiatePayment({
    required String bookingId,
    required String paymentMethod,
    required String paymentPhone,
  }) async {
    // Fetch booking to get the commitment fee amount
    final booking = await _bookingRepo.fetchById(bookingId);

    if (booking.status == BookingStatus.confirmed) {
      throw Exception('This booking has already been paid.');
    }
    if (booking.status == BookingStatus.cancelled) {
      throw Exception('This booking has been cancelled and cannot be paid.');
    }

    // Record payment + confirm booking
    final confirmed = await _bookingRepo.recordCommitmentPayment(
      bookingId: bookingId,
      amount: booking.commitmentFee,
      paymentMethod: paymentMethod,
      paymentPhone: paymentPhone,
    );

    // Decrement availability — best effort, don't fail the booking if this errors
    try {
      await _roomRepo.decrementAvailableSlots(booking.roomId ?? '');
      await _hostelRepo.decrementRoomsAvailable(booking.hostelId);
    } catch (_) {
      // Log in production; non-fatal for the booking flow
    }

    return confirmed;
  }

  // ── Cancel a booking ───────────────────────────────────────────────────────
  Future<BookingModel> cancelBooking(String bookingId) async {
    final booking = await _bookingRepo.fetchById(bookingId);

    if (booking.status == BookingStatus.completed) {
      throw Exception('Completed bookings cannot be cancelled.');
    }
    if (booking.status == BookingStatus.cancelled) {
      throw Exception('This booking is already cancelled.');
    }

    return _bookingRepo.cancel(bookingId);
  }

  // ── Fetch user bookings by status ─────────────────────────────────────────
  Future<List<BookingModel>> fetchUserBookings(String userId) =>
      _bookingRepo.fetchByUser(userId);

  Future<List<BookingModel>> fetchActiveBookings(String userId) async {
    final all = await _bookingRepo.fetchByUser(userId);
    return all
        .where(
          (b) =>
              b.status == BookingStatus.confirmed ||
              b.status == BookingStatus.pending,
        )
        .toList();
  }

  Future<List<BookingModel>> fetchPastBookings(String userId) async {
    final all = await _bookingRepo.fetchByUser(userId);
    return all.where((b) => b.status == BookingStatus.completed).toList();
  }

  Future<List<BookingModel>> fetchCancelledBookings(String userId) async {
    final all = await _bookingRepo.fetchByUser(userId);
    return all.where((b) => b.status == BookingStatus.cancelled).toList();
  }

  // ── Fetch single hostel (used by BookingNotifier) ─────────────────────────
  Future<HostelModel> fetchHostelDetails(String hostelId) =>
      _hostelRepo.fetchById(hostelId);

  // ── Fetch single booking ───────────────────────────────────────────────────
  Future<BookingModel> fetchBookingById(String bookingId) =>
      _bookingRepo.fetchById(bookingId);

  // ── Owner: fetch bookings for a hostel ────────────────────────────────────
  Future<List<BookingModel>> fetchHostelBookings(String hostelId) =>
      _bookingRepo.fetchByHostel(hostelId);

  // ── Realtime stream ────────────────────────────────────────────────────────
  Stream<List<BookingModel>> streamUserBookings(String userId) =>
      _bookingRepo.streamByUser(userId);

  // ── Internal helpers ───────────────────────────────────────────────────────
  String _generateReference() {
    final now = DateTime.now();
    final ts = now.millisecondsSinceEpoch.toString().substring(7);
    return 'HH-$ts';
  }
}

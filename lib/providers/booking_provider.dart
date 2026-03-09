import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/booking_model.dart';
import '../../services/booking_service.dart';

part 'booking_provider.g.dart';

// ── Booking notifier — actions (create, pay, cancel) ──────────────────────────
/// Use `ref.read(bookingProvider.notifier)` to call actions.
/// State is the last created/updated booking — mainly used for loading guards.
@riverpod
class Booking extends _$Booking {
  late final BookingService _service;

  @override
  AsyncValue<BookingModel?> build() {
    _service = BookingService();
    return const AsyncData(null);
  }

  // ── Create pending booking (BookingScreen) ─────────────────────────────────
  /// Returns the new booking ID so the screen can navigate to payment.
  /// All booking details are passed in by the screen — provider does not
  /// second-guess what room/price the user selected.
  Future<String> createBooking({
    required String hostelId,
    required String hostelName,
    required String roomId,
    required String roomType,
    required int totalAmount,
    required int commitmentFee,
    required DateTime moveInDate,
    required DateTime moveOutDate,
  }) async {
    state = const AsyncLoading();

    final booking = await _service.createPendingBooking(
      hostelId: hostelId,
      roomId: roomId,
      hostelName: hostelName,
      roomType: roomType,
      totalAmount: totalAmount,
      commitmentFee: commitmentFee,
      moveInDate: moveInDate,
      moveOutDate: moveOutDate,
    );

    state = AsyncData(booking);

    // Invalidate the user's booking list so it refreshes
    ref.invalidate(myBookingsProvider);

    return booking.id;
  }

  // ── Initiate payment (PaymentScreen) ──────────────────────────────────────
  Future<void> initiatePayment({
    required String bookingId,
    required String phone,
    required String provider,
  }) async {
    state = const AsyncLoading();

    final confirmed = await _service.initiatePayment(
      bookingId: bookingId,
      paymentMethod: provider,
      paymentPhone: phone,
    );

    state = AsyncData(confirmed);

    // Invalidate both the detail and list providers
    ref.invalidate(myBookingsProvider);
    ref.invalidate(bookingDetailProvider(bookingId));
  }

  // ── Cancel booking ─────────────────────────────────────────────────────────
  Future<void> cancelBooking(String bookingId) async {
    state = const AsyncLoading();

    final cancelled = await _service.cancelBooking(bookingId);
    state = AsyncData(cancelled);

    ref.invalidate(myBookingsProvider);
    ref.invalidate(bookingDetailProvider(bookingId));
  }
}

// ── Single booking detail (family) ────────────────────────────────────────────
/// Watched by payment_screen and booking_confirmation_screen as:
///   final bookingAsync = ref.watch(bookingDetailProvider(bookingId));
@riverpod
Future<BookingModel> bookingDetail(
  BookingDetailRef ref,
  String bookingId,
) async {
  return BookingService().fetchBookingById(bookingId);
}

// ── Current user's booking list ───────────────────────────────────────────────
/// Watched by my_bookings_screen as:
///   final bookingsAsync = ref.watch(myBookingsProvider);
@riverpod
Future<List<BookingModel>> myBookings(MyBookingsRef ref) async {
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) return [];
  return BookingService().fetchUserBookings(userId);
}

// ── Convenience aliases matching screen import names ──────────────────────────
final bookingProvider = bookingNotifierProvider;

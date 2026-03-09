/// Central registry of all named routes and path helpers.
/// Import this file wherever you need to navigate — never hardcode path strings.
abstract final class AppRoutes {
  AppRoutes._();

  // ── Auth ───────────────────────────────────────────────────────────────────
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const ownerLogin = '/owner-login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';

  // ── Main tabs ──────────────────────────────────────────────────────────────
  static const home = '/home';
  static const search = '/search';
  static const myBookings = '/bookings';
  static const profile = '/profile';

  // ── Hostel ─────────────────────────────────────────────────────────────────
  static const _hostelDetail = '/hostel/:hostelId';
  static const _hostelGallery = '/hostel/:hostelId/gallery';
  static const _hostelReviews = '/hostel/:hostelId/reviews';

  static String hostelDetail(String hostelId) => '/hostel/$hostelId';
  static String hostelGallery(String hostelId) => '/hostel/$hostelId/gallery';
  static String hostelReviews(String hostelId) => '/hostel/$hostelId/reviews';

  // ── Booking flow ───────────────────────────────────────────────────────────
  static const _booking = '/booking/:hostelId';
  static const _payment = '/payment/:bookingId';
  static const _bookingConfirmation = '/booking-confirmation/:bookingId';

  static String booking(String hostelId) => '/booking/$hostelId';
  static String payment(String bookingId) => '/payment/$bookingId';
  static String bookingConfirmation(String bookingId) =>
      '/booking-confirmation/$bookingId';

  // ── Profile ────────────────────────────────────────────────────────────────
  static const editProfile = '/profile/edit';
  static const settings = '/profile/settings';
  static const notificationSettings = '/profile/settings/notifications';

  // ── Owner ──────────────────────────────────────────────────────────────────
  static const ownerDashboard = '/owner/dashboard';
  static const manageHostel = '/owner/hostel';
  static const manageRooms = '/owner/rooms';
  static const manageBookings = '/owner/bookings';

  // ── Internal path templates (used by GoRouter only) ───────────────────────
  // Exposed so app_router.dart can reference them without re-declaring strings.
  static const pathHostelDetail = _hostelDetail;
  static const pathHostelGallery = _hostelGallery;
  static const pathHostelReviews = _hostelReviews;
  static const pathBooking = _booking;
  static const pathPayment = _payment;
  static const pathBookingConfirmation = _bookingConfirmation;
}

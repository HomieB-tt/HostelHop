/// App-wide constants — magic numbers and strings in one place.
/// Import this wherever you'd otherwise write a raw literal.
abstract final class AppConstants {
  AppConstants._();

  // ── App info ───────────────────────────────────────────────────────────────
  static const appName        = 'HostelHop';
  static const appVersion     = '1.0.0';
  static const supportEmail   = 'support@hostelhop.app';
  static const supportPhone   = '+256700000000';

  // ── Booking ────────────────────────────────────────────────────────────────
  /// Default semester duration in days (≈ 5 months)
  static const semesterDays = 150;

  /// Default move-in offset from today (days)
  static const defaultMoveInOffsetDays = 7;

  /// Commitment fee cancellation window (hours)
  static const cancellationWindowHours = 48;

  // ── Pagination ─────────────────────────────────────────────────────────────
  static const hostelPageSize  = 20;
  static const reviewPageSize  = 10;
  static const bookingPageSize = 15;

  // ── Image ──────────────────────────────────────────────────────────────────
  static const maxGalleryImages  = 8;
  static const avatarMaxWidth    = 512.0;
  static const hostelImageWidth  = 1200.0;
  static const imageQuality      = 85;

  // ── Animation durations ────────────────────────────────────────────────────
  static const splashDuration         = Duration(milliseconds: 3000);
  static const pageTransitionDuration = Duration(milliseconds: 300);
  static const shimmerDuration        = Duration(milliseconds: 1200);

  // ── Supabase table names (single source of truth) ─────────────────────────
  static const tableHostels  = 'hostels';
  static const tableRooms    = 'rooms';
  static const tableBookings = 'bookings';
  static const tableReviews  = 'reviews';
  static const tableProfiles = 'profiles';

  // ── Hive box names ─────────────────────────────────────────────────────────
  static const hiveBoxSettings = 'settings';
  static const hiveBoxCache    = 'cache';

  // ── Uganda phone ───────────────────────────────────────────────────────────
  static const ugandaDialCode = '+256';
  static const mtnPrefixes    = ['077', '078', '076', '039'];
  static const airtelPrefixes = ['070', '075', '074'];
}

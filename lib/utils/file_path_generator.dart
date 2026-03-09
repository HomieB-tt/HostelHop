/// Generates consistent file path strings for Supabase Storage uploads.
/// Mirrors the path convention in supabase_buckets.dart but is available
/// to any layer without importing the supabase package.
///
/// Usage:
///   FilePathGenerator.hostelCover('abc123')     → 'hostel_abc123/cover.jpg'
///   FilePathGenerator.userAvatar('uid99')        → 'user_uid99/avatar.jpg'
///   FilePathGenerator.galleryImage('h1', 0)      → 'hostel_h1/gallery_0.jpg'
abstract final class FilePathGenerator {
  FilePathGenerator._();

  // ── Hostel images ──────────────────────────────────────────────────────────
  static String hostelCover(String hostelId) =>
      'hostel_$hostelId/cover.jpg';

  static String galleryImage(String hostelId, int index) =>
      'hostel_$hostelId/gallery_$index.jpg';

  static String galleryImageTimestamped(String hostelId) {
    final ts = DateTime.now().millisecondsSinceEpoch;
    return 'hostel_$hostelId/gallery_$ts.jpg';
  }

  // ── User avatar ────────────────────────────────────────────────────────────
  static String userAvatar(String userId, [String ext = 'jpg']) =>
      'user_$userId/avatar.$ext';

  // ── Owner documents ────────────────────────────────────────────────────────
  static String ownerDocument(String userId, String docType) {
    final ts = DateTime.now().millisecondsSinceEpoch;
    return 'user_$userId/${docType}_$ts.jpg';
  }

  // ── Booking reference ──────────────────────────────────────────────────────
  /// Generates a short human-readable booking reference.
  /// Format: HH-XXXXXXX (7 digits from current ms timestamp)
  static String bookingReference() {
    final ts = DateTime.now().millisecondsSinceEpoch.toString();
    return 'HH-${ts.substring(ts.length - 7)}';
  }

  // ── Cache key ─────────────────────────────────────────────────────────────
  static String hostelCacheKey(String hostelId) => 'hostel:$hostelId';
  static String hostelListCacheKey()             => 'hostel:list';
  static String bookingCacheKey(String bookingId) => 'booking:$bookingId';
  static String userCacheKey(String userId)       => 'user:$userId';
}

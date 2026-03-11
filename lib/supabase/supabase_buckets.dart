import '../config/env.dart';

/// Central registry of all Supabase Storage bucket names and path builders.
/// Never hardcode bucket names or path patterns outside this file.
abstract final class SupabaseBuckets {
  SupabaseBuckets._();

  // ── Bucket names ───────────────────────────────────────────────────────────
  static const hostels = 'hostel_images';
  static const avatars = 'avatars';
  static const documents = 'documents';

  // ── Hostel image paths ─────────────────────────────────────────────────────
  /// e.g. hostel-images/hostel_abc123/cover.jpg
  static String hostelImage(String hostelId, String fileName) =>
      'hostel_$hostelId/$fileName';

  /// e.g. hostel-images/hostel_abc123/gallery/img_01.jpg
  static String hostelGalleryImage(String hostelId, String fileName) =>
      'hostel_$hostelId/gallery/$fileName';

  // ── Avatar paths ───────────────────────────────────────────────────────────
  /// e.g. avatars/user_abc123/avatar.jpg
  static String userAvatar(String userId, String fileName) =>
      'user_$userId/$fileName';

  // ── Document paths ─────────────────────────────────────────────────────────
  /// e.g. documents/user_abc123/id_front.jpg
  static String userDocument(String userId, String fileName) =>
      'user_$userId/$fileName';

  // ── Public URL helper ──────────────────────────────────────────────────────
  /// Builds the full public URL for a file in a public bucket.
  /// Usage: SupabaseBuckets.publicUrl(SupabaseBuckets.hostels, path)
  static String publicUrl(String bucket, String path) =>
      '${_storageBase()}/$bucket/$path';

  static String _storageBase() {
    // Derives storage URL from the Supabase project URL.
    // e.g. https://xxxx.supabase.co
    //   →  https://xxxx.supabase.co/storage/v1/object/public
    final projectUrl = Env.supabaseUrl.replaceAll(RegExp(r'/$'), '');
    return '$projectUrl/storage/v1/object/public';
  }
}

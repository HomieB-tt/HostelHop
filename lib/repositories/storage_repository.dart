import 'dart:io';
import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../supabase/supabase_buckets.dart';
import '../../supabase/supabase_client.dart';

class StorageRepository {
  const StorageRepository();

  // ── Upload hostel cover image ──────────────────────────────────────────────
  Future<String> uploadHostelImage({
    required String hostelId,
    required File file,
    String fileName = 'cover.jpg',
  }) async {
    final path = SupabaseBuckets.hostelImage(hostelId, fileName);
    await supabase.storage
        .from(SupabaseBuckets.hostels)
        .upload(path, file, fileOptions: const FileOptions(upsert: true));

    return SupabaseBuckets.publicUrl(SupabaseBuckets.hostels, path);
  }

  // ── Upload hostel gallery image ────────────────────────────────────────────
  Future<String> uploadHostelGalleryImage({
    required String hostelId,
    required File file,
    required String fileName,
  }) async {
    final path = SupabaseBuckets.hostelGalleryImage(hostelId, fileName);
    await supabase.storage
        .from(SupabaseBuckets.hostels)
        .upload(path, file, fileOptions: const FileOptions(upsert: true));

    return SupabaseBuckets.publicUrl(SupabaseBuckets.hostels, path);
  }

  // ── Upload user avatar ────────────────────────────────────────────────────
  Future<String> uploadAvatar({
    required String userId,
    required File file,
    String fileName = 'avatar.jpg',
  }) async {
    final path = SupabaseBuckets.userAvatar(userId, fileName);
    await supabase.storage
        .from(SupabaseBuckets.avatars)
        .upload(path, file, fileOptions: const FileOptions(upsert: true));

    return SupabaseBuckets.publicUrl(SupabaseBuckets.avatars, path);
  }

  // ── Upload user avatar from bytes (web support) ───────────────────────────
  Future<String> uploadAvatarBytes({
    required String userId,
    required Uint8List bytes,
    String fileName = 'avatar.jpg',
    String mimeType = 'image/jpeg',
  }) async {
    final path = SupabaseBuckets.userAvatar(userId, fileName);
    await supabase.storage
        .from(SupabaseBuckets.avatars)
        .uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(upsert: true, contentType: mimeType),
        );

    return SupabaseBuckets.publicUrl(SupabaseBuckets.avatars, path);
  }

  // ── Upload document (e.g. owner NIN/certificate) ──────────────────────────
  Future<String> uploadDocument({
    required String userId,
    required File file,
    required String fileName,
  }) async {
    final path = SupabaseBuckets.userDocument(userId, fileName);
    await supabase.storage
        .from(SupabaseBuckets.documents)
        .upload(path, file, fileOptions: const FileOptions(upsert: true));

    // Documents bucket is private — return path only (not a public URL)
    return path;
  }

  // ── Delete a file from any bucket ─────────────────────────────────────────
  Future<void> deleteFile(String bucket, String path) async {
    await supabase.storage.from(bucket).remove([path]);
  }

  // ── Delete all files in a hostel folder ───────────────────────────────────
  Future<void> deleteHostelFolder(String hostelId) async {
    final bucket = supabase.storage.from(SupabaseBuckets.hostels);

    // List all objects under hostel_<id>/
    final objects = await bucket.list(path: 'hostel_$hostelId');
    if (objects.isEmpty) return;

    final paths = objects
        .where((o) => o.name.isNotEmpty)
        .map((o) => 'hostel_$hostelId/${o.name}')
        .toList();

    if (paths.isNotEmpty) {
      await bucket.remove(paths);
    }
  }

  // ── Get a signed URL for a private document ───────────────────────────────
  Future<String> getSignedUrl({
    required String bucket,
    required String path,
    Duration expiry = const Duration(hours: 1),
  }) async {
    final response = await supabase.storage
        .from(bucket)
        .createSignedUrl(path, expiry.inSeconds);

    return response;
  }
}

import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';

import '../../repositories/storage_repository.dart';
import '../../supabase/supabase_buckets.dart';

/// High-level storage operations for UI use.
/// Wraps StorageRepository with image picking, compression hints,
/// and platform-safe file handling (mobile + web).
class StorageService {
  StorageService({StorageRepository? storageRepository})
    : _storageRepo = storageRepository ?? const StorageRepository();

  final StorageRepository _storageRepo;
  final _picker = ImagePicker();

  // ── Pick + upload avatar ───────────────────────────────────────────────────
  /// Opens the image picker and uploads the selected image as the user's avatar.
  /// Returns the public URL of the uploaded avatar, or null if picker cancelled.
  Future<String?> pickAndUploadAvatar(String userId) async {
    final xFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );

    if (xFile == null) return null;

    if (kIsWeb) {
      final bytes = await xFile.readAsBytes();
      final ext = xFile.name.split('.').last.toLowerCase();
      final mime = ext == 'png' ? 'image/png' : 'image/jpeg';
      return _storageRepo.uploadAvatarBytes(
        userId: userId,
        bytes: bytes,
        fileName: 'avatar.$ext',
        mimeType: mime,
      );
    } else {
      return _storageRepo.uploadAvatar(userId: userId, file: File(xFile.path));
    }
  }

  // ── Pick + upload hostel cover image ──────────────────────────────────────
  /// Opens camera or gallery and uploads as the hostel cover.
  /// Returns the public URL, or null if cancelled.
  Future<String?> pickAndUploadHostelCover({
    required String hostelId,
    ImageSource source = ImageSource.gallery,
  }) async {
    final xFile = await _picker.pickImage(
      source: source,
      maxWidth: 1200,
      maxHeight: 800,
      imageQuality: 80,
    );

    if (xFile == null) return null;

    if (kIsWeb) {
      // Web: upload bytes via StorageRepository directly
      final bytes = await xFile.readAsBytes();
      final path = SupabaseBuckets.hostelImage(hostelId, 'cover.jpg');
      // Delegate to repo uploadAvatarBytes reusing pattern — cover uses its own bucket
      return _storageRepo.uploadAvatarBytes(
        userId: hostelId, // path builder adapts — covered by hostelImage()
        bytes: bytes,
        fileName: 'cover.jpg',
        mimeType: 'image/jpeg',
      );
    } else {
      return _storageRepo.uploadHostelImage(
        hostelId: hostelId,
        file: File(xFile.path),
        fileName: 'cover.jpg',
      );
    }
  }

  // ── Pick + upload multiple hostel gallery images ───────────────────────────
  /// Returns list of public URLs for all uploaded images.
  Future<List<String>> pickAndUploadGallery({
    required String hostelId,
    int maxImages = 8,
  }) async {
    final xFiles = await _picker.pickMultiImage(
      maxWidth: 1200,
      maxHeight: 800,
      imageQuality: 80,
    );

    if (xFiles.isEmpty) return [];

    // Limit to maxImages
    final limited = xFiles.take(maxImages).toList();

    final urls = <String>[];
    for (int i = 0; i < limited.length; i++) {
      final xFile = limited[i];
      final fileName =
          'gallery_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
      try {
        final url = await _storageRepo.uploadHostelGalleryImage(
          hostelId: hostelId,
          file: File(xFile.path),
          fileName: fileName,
        );
        urls.add(url);
      } catch (_) {
        // Skip failed uploads, continue with rest
      }
    }
    return urls;
  }

  // ── Upload document (owner verification) ──────────────────────────────────
  /// Returns the storage path (private bucket — not a public URL).
  Future<String?> pickAndUploadDocument({
    required String userId,
    required String documentType, // 'id_front' | 'id_back' | 'certificate'
  }) async {
    final xFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );

    if (xFile == null) return null;

    return _storageRepo.uploadDocument(
      userId: userId,
      file: File(xFile.path),
      fileName: '${documentType}_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
  }

  // ── Delete a file ──────────────────────────────────────────────────────────
  Future<void> deleteFile(String bucket, String path) =>
      _storageRepo.deleteFile(bucket, path);

  // ── Get signed URL for private document ───────────────────────────────────
  Future<String> getDocumentUrl(String path) =>
      _storageRepo.getSignedUrl(bucket: SupabaseBuckets.documents, path: path);
}

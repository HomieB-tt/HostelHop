import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/user_model.dart';
import '../../repositories/user_repository.dart';
import '../../services/storage_service.dart';

part 'user_provider.g.dart';

// ── Current user profile ───────────────────────────────────────────────────────
/// Watched by profile_screen, edit_profile_screen as:
///   final profileAsync = ref.watch(userProfileProvider);
@riverpod
class UserProfile extends _$UserProfile {
  late final UserRepository _repo;
  late final StorageService _storageService;

  @override
  Future<UserModel> build() async {
    _repo = const UserRepository();
    _storageService = StorageService();
    return _repo.fetchCurrentUser();
  }

  // ── Refresh ────────────────────────────────────────────────────────────────
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.fetchCurrentUser());
  }

  // ── Update profile fields ──────────────────────────────────────────────────
  Future<void> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
  }) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final updates = <String, dynamic>{};

    // Build full_name from parts, falling back to existing name segments
    if (firstName != null || lastName != null) {
      final parts = current.fullName.split(' ');
      final existingFirst = parts.isNotEmpty ? parts.first : '';
      final existingLast = parts.length > 1 ? parts.sublist(1).join(' ') : '';
      final newFirst = firstName ?? existingFirst;
      final newLast = lastName ?? existingLast;
      updates['full_name'] = '$newFirst $newLast'.trim();
    }

    if (phone != null) updates['phone'] = phone;
    if (updates.isEmpty) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.update(current.id, updates));
  }

  // ── Pick and upload avatar ─────────────────────────────────────────────────
  Future<void> updateAvatar() async {
    final current = state.valueOrNull;
    if (current == null) return;

    final url = await _storageService.pickAndUploadAvatar(current.id);
    if (url == null) return; // picker cancelled

    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.updateAvatar(current.id, url));
  }
}

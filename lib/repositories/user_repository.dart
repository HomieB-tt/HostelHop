import '../../models/user_model.dart';
import '../../supabase/supabase_client.dart';

class UserRepository {
  const UserRepository();

  // Matches the Supabase table name for user profiles
  static const _table = 'profiles';

  // ── Fetch current user profile ─────────────────────────────────────────────
  Future<UserModel> fetchCurrentUser() async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) throw Exception('No authenticated user');

    final response = await supabase
        .from(_table)
        .select()
        .eq('id', uid)
        .single();

    return UserModel.fromJson(response);
  }

  // ── Fetch profile by id ────────────────────────────────────────────────────
  Future<UserModel> fetchById(String userId) async {
    final response = await supabase
        .from(_table)
        .select()
        .eq('id', userId)
        .single();

    return UserModel.fromJson(response);
  }

  // ── Create profile (called after sign-up) ─────────────────────────────────
  Future<UserModel> create(Map<String, dynamic> data) async {
    final response = await supabase
        .from(_table)
        .insert(data)
        .select()
        .single();

    return UserModel.fromJson(response);
  }

  // ── Update profile ─────────────────────────────────────────────────────────
  Future<UserModel> update(String userId, Map<String, dynamic> data) async {
    final response = await supabase
        .from(_table)
        .update(data)
        .eq('id', userId)
        .select()
        .single();

    return UserModel.fromJson(response);
  }

  // ── Update avatar URL ──────────────────────────────────────────────────────
  Future<UserModel> updateAvatar(String userId, String avatarUrl) async {
    return update(userId, {'avatar_url': avatarUrl});
  }

  // ── Update FCM token (for push notifications) ─────────────────────────────
  Future<void> updateFcmToken(String userId, String token) async {
    await supabase
        .from(_table)
        .update({'fcm_token': token})
        .eq('id', userId);
  }

  // ── Realtime stream — current user profile ────────────────────────────────
  Stream<UserModel> streamCurrentUser(String userId) {
    return supabase
        .from(_table)
        .stream(primaryKey: ['id'])
        .eq('id', userId)
        .map((rows) {
          if (rows.isEmpty) throw Exception('Profile not found');
          return UserModel.fromJson(rows.first);
        });
  }
}

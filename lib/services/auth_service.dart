import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/user_model.dart';
import '../../repositories/user_repository.dart';
import '../../supabase/supabase_client.dart';

/// Handles all Supabase Auth operations.
/// Never call supabase.auth directly from UI — always go through this service.
class AuthService {
  AuthService({UserRepository? userRepository})
    : _userRepo = userRepository ?? const UserRepository();

  final UserRepository _userRepo;

  // ── Current session ────────────────────────────────────────────────────────
  User? get currentUser => supabase.auth.currentUser;
  Session? get currentSession => supabase.auth.currentSession;
  bool get isLoggedIn => currentUser != null;

  /// Auth state changes — listen in auth_provider
  Stream<AuthState> get authStateStream => supabase.auth.onAuthStateChange;

  // ── Sign in (student) — phone + password ──────────────────────────────────
  Future<UserModel> signInWithPhone({
    required String phone,
    required String password,
  }) async {
    final response = await supabase.auth.signInWithPassword(
      phone: phone,
      password: password,
    );

    if (response.user == null) {
      throw const AuthException('Sign in failed. Please try again.');
    }

    return _userRepo.fetchById(response.user!.id);
  }

  // ── Sign in (owner) — username + password ────────────────────────────────────
  Future<UserModel> signInOwner({
    required String username,
    required String password,
  }) async {
    final response = await supabase.auth.signInWithPassword(
      username: username,
      password: password,
    );

    if (response.user == null) {
      throw const AuthException('Sign in failed. Please try again.');
    }

    final userModel = await _userRepo.fetchById(response.user!.id);

    // Guard: only owners can use owner login
    if (!userModel.isOwner) {
      await supabase.auth.signOut();
      throw const AuthException('This account does not have owner access.');
    }

    return userModel;
  }

  // ── Register — phone + password ───────────────────────────────────────────
  Future<UserModel> registerWithPhone({
    required String phone,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    final response = await supabase.auth.signUp(
      phone: phone,
      password: password,
      data: {
        'first_name': firstName,
        'last_name': lastName,
        'role': UserRole.student.value,
      },
    );

    if (response.user == null) {
      throw const AuthException('Registration failed. Please try again.');
    }

    // Create profile row in public.profiles
    return _userRepo.create({
      'id': response.user!.id,
      'full_name': '$firstName $lastName'.trim(),
      'phone': phone,
      'email': response.user!.email ?? '',
      'role': UserRole.student.value,
    });
  }

  // ── Password reset ────────────────────────────────────────────────────────
  Future<void> sendPasswordResetOtp(String phone) async {
    await supabase.auth.signInWithOtp(phone: phone);
  }

  Future<void> verifyOtpAndResetPassword({
    required String phone,
    required String token,
    required String newPassword,
  }) async {
    // Verify OTP first
    await supabase.auth.verifyOTP(
      phone: phone,
      token: token,
      type: OtpType.sms,
    );

    // Then update password
    await supabase.auth.updateUser(UserAttributes(password: newPassword));
  }

  // ── Update password (when already logged in) ──────────────────────────────
  Future<void> updatePassword(String newPassword) async {
    await supabase.auth.updateUser(UserAttributes(password: newPassword));
  }

  // ── Sign out ──────────────────────────────────────────────────────────────
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  // ── Fetch the profile for the currently logged-in user ────────────────────
  Future<UserModel?> fetchCurrentProfile() async {
    if (currentUser == null) return null;
    try {
      return await _userRepo.fetchCurrentUser();
    } catch (_) {
      return null;
    }
  }
}

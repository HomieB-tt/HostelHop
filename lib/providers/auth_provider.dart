import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show User, AuthState;

import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/notification_service.dart';
import '../providers/booking_provider.dart';
import '../providers/hostel_provider.dart';
import '../providers/user_provider.dart';

part 'auth_provider.g.dart';

// ── App auth state ─────────────────────────────────────────────────────────────
/// Our own auth state — NOT Supabase's AuthState.
/// Consumed by app_router.dart's _guard() and all screens.
class AppAuthState {
  const AppAuthState({this.user, this.profile, this.isLoading = false});

  /// Raw Supabase user — available immediately on session restore
  final User? user;

  /// Full profile from public.profiles — loaded after sign-in
  final UserModel? profile;

  final bool isLoading;

  bool get isLoggedIn => user != null;
  bool get isOwner => profile?.isOwner ?? false;
  bool get isAdmin => profile?.isAdmin ?? false;

  /// Display name — falls back through profile → metadata → 'there'
  String get firstName =>
      profile?.firstName ??
      user?.userMetadata?['first_name']?.toString() ??
      'there';

  AppAuthState copyWith({
    User? user,
    UserModel? profile,
    bool? isLoading,
    bool clearUser = false,
    bool clearProfile = false,
  }) {
    return AppAuthState(
      user: clearUser ? null : (user ?? this.user),
      profile: clearProfile ? null : (profile ?? this.profile),
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// ── Notifier ───────────────────────────────────────────────────────────────────
@riverpod
class Auth extends _$Auth {
  late final AuthService _authService;
  StreamSubscription<AuthState>? _authSub;

  @override
  AppAuthState build() {
    _authService = AuthService();

    // Listen to Supabase auth state changes for the lifetime of this notifier
    _authSub = _authService.authStateStream.listen(_onAuthStateChange);

    ref.onDispose(() {
      _authSub?.cancel();
    });

    // Restore session synchronously if one exists
    final currentUser = _authService.currentUser;
    if (currentUser != null) {
      // Load profile in background
      _loadProfile(currentUser.id);
      return AppAuthState(user: currentUser, isLoading: true);
    }

    return const AppAuthState();
  }

  // ── Auth state stream handler ──────────────────────────────────────────────
  Future<void> _onAuthStateChange(AuthState event) async {
    final user = event.session?.user;

    if (user == null) {
      // Signed out — clear auth state and invalidate all user-scoped providers
      state = const AppAuthState();
      ref.invalidate(userProfileProvider);
      ref.invalidate(myBookingsProvider);
      ref.invalidate(hostelListProvider);
      // Cancel FCM token refresh subscription
      NotificationService.instance.cancelTokenRefresh().ignore();
      return;
    }

    if (state.user?.id != user.id) {
      // New sign-in — load profile
      state = state.copyWith(user: user, isLoading: true);
      await _loadProfile(user.id);
    }
  }

  // ── Load profile from Supabase ─────────────────────────────────────────────
  Future<void> _loadProfile(String userId) async {
    try {
      final profile = await _authService.fetchCurrentProfile();
      state = state.copyWith(profile: profile, isLoading: false);
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  // ── Sign in (student) ──────────────────────────────────────────────────────
  Future<void> signInWithPhone({
    required String phone,
    required String password,
  }) async {
    final profile = await _authService.signInWithPhone(
      phone: phone,
      password: password,
    );
    final currentUser = _authService.currentUser!;
    state = AppAuthState(user: currentUser, profile: profile);

    // Register FCM token after login
    _registerNotificationToken(currentUser.id);
  }

  // ── Sign in (owner) ────────────────────────────────────────────────────────
  Future<void> signInOwner({
    required String username,
    required String password,
    required String otp,
  }) async {
    final profile = await _authService.signInOwner(
      username: '', // Supabase uses email auth; owner's username IS their email
      password: password,
    );
    final currentUser = _authService.currentUser!;
    state = AppAuthState(user: currentUser, profile: profile);

    _registerNotificationToken(currentUser.id);
  }

  // ── Register ───────────────────────────────────────────────────────────────
  Future<void> registerWithPhone({
    required String phone,
    required String password,
    required String fullName,
  }) async {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    final firstName = parts.isNotEmpty ? parts.first : '';
    final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    final profile = await _authService.registerWithPhone(
      phone: phone,
      password: password,
      firstName: firstName,
      lastName: lastName,
    );
    final currentUser = _authService.currentUser!;
    state = AppAuthState(user: currentUser, profile: profile);

    _registerNotificationToken(currentUser.id);
  }

  // ── Password reset ─────────────────────────────────────────────────────────
  Future<void> sendPasswordReset({required String phone}) async {
    await _authService.sendPasswordResetOtp(phone);
  }

  Future<void> verifyOtpAndResetPassword({
    required String phone,
    required String token,
    required String newPassword,
  }) async {
    await _authService.verifyOtpAndResetPassword(
      phone: phone,
      token: token,
      newPassword: newPassword,
    );
  }

  // ── Sign out ───────────────────────────────────────────────────────────────
  Future<void> signOut() async {
    await _authService.signOut();
    // State reset is handled by _onAuthStateChange
  }

  // ── Refresh profile (e.g. after editing profile) ──────────────────────────
  Future<void> refreshProfile() async {
    if (state.user == null) return;
    await _loadProfile(state.user!.id);
  }

  // ── FCM token helper ───────────────────────────────────────────────────────
  void _registerNotificationToken(String userId) {
    // Fire-and-forget — non-fatal
    NotificationService.instance.registerTokenForUser(userId).ignore();
  }
}

// authProvider is generated by build_runner as:
//   @ProviderFor(Auth)
//   final authProvider = AuthProvider._();
// Do NOT declare it manually here — that would cause a duplicate definition.

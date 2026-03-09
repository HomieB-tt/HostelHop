import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/env.dart';

/// Initialises the Supabase client.
/// Call [SupabaseClientManager.init()] once in main() before runApp().
abstract final class SupabaseClientManager {
  SupabaseClientManager._();

  static Future<void> init() async {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
        autoRefreshToken: true,
      ),
      realtimeClientOptions: const RealtimeClientOptions(
        logLevel: RealtimeLogLevel.info,
      ),
    );
  }

  /// Global Supabase client — use this everywhere instead of
  /// Supabase.instance.client to keep imports clean.
  static SupabaseClient get client => Supabase.instance.client;

  /// Shorthand for the authenticated user's ID.
  /// Returns null if not logged in.
  static String? get currentUserId =>
      Supabase.instance.client.auth.currentUser?.id;

  /// True if a user session is active.
  static bool get isLoggedIn =>
      Supabase.instance.client.auth.currentUser != null;

  /// Auth state stream — listen to this in auth_provider.
  static Stream<AuthState> get authStateStream =>
      Supabase.instance.client.auth.onAuthStateChange;
}

/// Convenience top-level getter.
/// Usage: `supabase.from('hostels').select()`
SupabaseClient get supabase => SupabaseClientManager.client;

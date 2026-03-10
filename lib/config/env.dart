/// Environment configuration loaded at compile time via --dart-define.
///
/// Usage (run / build):
///   flutter run \
///     --dart-define=SUPABASE_URL=https://qfbyixktdrqolherauzw.supabase.co \
///     --dart-define=SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFmYnlpeGt0ZHJxb2xoZXJhdXp3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzIxMTE2OTgsImV4cCI6MjA4NzY4NzY5OH0.rVej979xFmSvY1UKfULZdZD_sDanHY_sU9Ty1H84gK0
///
/// Usage (VS Code launch.json):
///   "toolArgs": [
///     "--dart-define=SUPABASE_URL=https://xxxx.supabase.co",
///     "--dart-define=SUPABASE_ANON_KEY=eyJhbGci..."
///   ]
///
/// Never commit actual values — use a local `.env.sh` or CI secrets.
abstract final class Env {
  Env._();

  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  /// Throws immediately at startup if required env vars are missing.
  /// Call this in main() before runApp().
  static void validate() {
    assert(
      supabaseUrl.isNotEmpty,
      'SUPABASE_URL is not set. Pass --dart-define=SUPABASE_URL=... at build time.',
    );
    assert(
      supabaseAnonKey.isNotEmpty,
      'SUPABASE_ANON_KEY is not set. Pass --dart-define=SUPABASE_ANON_KEY=... at build time.',
    );
  }

  /// True only in debug builds — use for conditional logging, mock data etc.
  static const isDebug = bool.fromEnvironment(
    'dart.vm.product',
    defaultValue: true,
  );
}

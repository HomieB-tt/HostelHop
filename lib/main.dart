import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'config/app_theme.dart';
import 'config/env.dart';
import 'providers/settings_provider.dart';
import 'services/notification_service.dart';
import 'supabase/supabase_client.dart';
import 'config/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── 1. Validate env vars (crashes fast in debug if missing) ───────────────
  Env.validate();

  // ── 2. Lock orientation to portrait ───────────────────────────────────────
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // ── 3. Status bar style (transparent, light icons) ────────────────────────
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // ── 4. Hive (local cache + settings) ──────────────────────────────────────
  await Hive.initFlutter();

  // ── 5. Firebase (required before NotificationService.init) ────────────────
  await Firebase.initializeApp();

  // ── 6. Supabase ───────────────────────────────────────────────────────────
  await SupabaseClientManager.init();

  // ── 7. Push notifications ─────────────────────────────────────────────────
  await NotificationService().init();

  // ── 8. Run app ────────────────────────────────────────────────────────────
  runApp(const ProviderScope(child: HostelHopApp()));
}

// ── Root widget ────────────────────────────────────────────────────────────────
class HostelHopApp extends ConsumerWidget {
  const HostelHopApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final settingsAsync = ref.watch(settingsProvider);

    // Dark mode — default to light while settings load
    final isDark = settingsAsync.valueOrNull?.isDarkMode ?? false;

    return MaterialApp.router(
      title: 'HostelHop',
      debugShowCheckedModeBanner: false,

      // ── Theme ──────────────────────────────────────────────────────────────
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,

      // ── Routing ────────────────────────────────────────────────────────────
      routerConfig: router,
    );
  }
}

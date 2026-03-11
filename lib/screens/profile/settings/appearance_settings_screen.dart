// NOTE: Appearance settings (dark mode toggle) live in settings_screen.dart.
// This file exists in case you want to expand appearance options later
// (font size, colour scheme, language, etc.).
//
// For now it redirects back — you can fill it out when needed.
// It is NOT registered in app_router.dart and NOT referenced anywhere yet.

import 'package:flutter/material.dart';

import '../../../config/app_theme.dart';

class AppearanceSettingsScreen extends StatelessWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Appearance',
          style: TextStyle(
            fontFamily: 'Sora',
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimaryLight,
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.borderLight),
        ),
      ),
      body: const Center(
        child: Text(
          'Coming soon',
          style: TextStyle(
            fontFamily: 'Sora',
            fontSize: 14,
            color: AppColors.textHintLight,
          ),
        ),
      ),
    );
  }
}

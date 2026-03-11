// NOTE: Privacy settings will link to your Privacy Policy URL and
// provide data-deletion / account-deletion options.
// It is NOT registered in app_router.dart yet — add when ready.

import 'package:flutter/material.dart';

import '../../../config/app_theme.dart';

class PrivacySettingsScreen extends StatelessWidget {
  const PrivacySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Privacy',
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

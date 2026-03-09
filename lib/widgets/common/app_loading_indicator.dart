import 'package:flutter/material.dart';

import '../../../config/app_theme.dart';

/// Inline orange spinner — drop into any layout.
///
///   AppLoadingIndicator()
///   AppLoadingIndicator(size: 20)
class AppLoadingIndicator extends StatelessWidget {
  const AppLoadingIndicator({
    super.key,
    this.size = 28.0,
    this.strokeWidth = 2.5,
    this.color,
  });

  final double size;
  final double strokeWidth;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? AppColors.orangeBright,
        ),
      ),
    );
  }
}

/// Centred loading — fills its parent. Use inside Scaffold body
/// or inside an AsyncValue.loading() branch.
///
///   AppLoadingScreen()
///   AppLoadingScreen(message: 'Loading hostels…')
class AppLoadingScreen extends StatelessWidget {
  const AppLoadingScreen({
    super.key,
    this.message,
  });

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppLoadingIndicator(size: 36, strokeWidth: 3),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 13,
                color: AppColors.textSecondaryLight,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Full-screen translucent overlay — use during async actions
/// (e.g. while payment is processing) to block interaction.
///
///   Stack(children: [
///     _content,
///     if (_isLoading) const AppLoadingOverlay(),
///   ])
class AppLoadingOverlay extends StatelessWidget {
  const AppLoadingOverlay({
    super.key,
    this.message,
    this.opacity = 0.55,
  });

  final String? message;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(opacity),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppLoadingIndicator(size: 32, strokeWidth: 3),
              if (message != null) ...[
                const SizedBox(height: 14),
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

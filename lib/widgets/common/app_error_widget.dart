import 'package:flutter/material.dart';

import '../../../config/app_theme.dart';

/// Reusable error widget — shows a message and optional retry button.
///
/// Usage:
///   AppErrorWidget(message: e.toString(), onRetry: () => ref.refresh(...))
///
/// Inline (slim) variant:
///   AppErrorWidget.inline(message: 'Failed to load')
class AppErrorWidget extends StatelessWidget {
  const AppErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.slim = false,
  });

  /// Slim one-liner — suitable inside cards or list items
  factory AppErrorWidget.inline({
    Key? key,
    required String message,
    VoidCallback? onRetry,
  }) {
    return AppErrorWidget(
      key: key,
      message: message,
      onRetry: onRetry,
      slim: true,
    );
  }

  final String message;
  final VoidCallback? onRetry;
  final bool slim;

  // ── Friendly message mappings ──────────────────────────────────────────────
  static String friendly(Object error) {
    final msg = error.toString().toLowerCase();
    if (msg.contains('network') || msg.contains('socket')) {
      return 'No internet connection. Check your network and try again.';
    }
    if (msg.contains('timeout')) {
      return 'Request timed out. Please try again.';
    }
    if (msg.contains('unauthenticated') || msg.contains('401')) {
      return 'Your session has expired. Please sign in again.';
    }
    if (msg.contains('not found') || msg.contains('406')) {
      return 'This item could not be found.';
    }
    return 'Something went wrong. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    if (slim) return _slim(context);
    return _full(context);
  }

  Widget _full(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                color: Color(0xFFFFEBEE),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 36,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong',
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              friendly(message),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontSize: 13,
                color: AppColors.textSecondaryLight,
                height: 1.5,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text(
                  'Try Again',
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.orangeBright,
                  side: const BorderSide(color: AppColors.orangeBright),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 10,
                  ),
                  shape: const StadiumBorder(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _slim(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 16,
            color: AppColors.error,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              friendly(message),
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontSize: 12,
                color: AppColors.error,
              ),
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onRetry,
              child: const Text(
                'Retry',
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.orangeBright,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

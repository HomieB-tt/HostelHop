import 'package:flutter/material.dart';

import '../../../config/app_theme.dart';

/// The app's primary filled button.
///
/// Usage:
///   AppButton(label: 'Book Now', onPressed: _handleBooking)
///   AppButton(label: 'Loading…', onPressed: null, isLoading: true)
///   AppButton(label: 'Book Now', onPressed: _handleBooking, fullWidth: false)
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.fullWidth = true,
    this.icon,
    this.color,
    this.textColor,
    this.height = 52.0,
  });

  // ── Outlined (secondary) variant ──────────────────────────────────────────
  factory AppButton.outlined({
    Key? key,
    required String label,
    required VoidCallback? onPressed,
    bool isLoading = false,
    bool fullWidth = true,
    IconData? icon,
    double height = 52.0,
  }) {
    return _OutlinedButton(
      key: key,
      label: label,
      onPressed: onPressed,
      isLoading: isLoading,
      fullWidth: fullWidth,
      icon: icon,
      height: height,
    );
  }

  // ── Text (ghost) variant ───────────────────────────────────────────────────
  factory AppButton.text({
    Key? key,
    required String label,
    required VoidCallback? onPressed,
    Color? color,
  }) {
    return _TextButton(
      key: key,
      label: label,
      onPressed: onPressed,
      color: color,
    );
  }

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool fullWidth;
  final IconData? icon;
  final Color? color;
  final Color? textColor;
  final double height;

  @override
  Widget build(BuildContext context) {
    final bg = color ?? AppColors.orangeBright;
    final fg = textColor ?? Colors.white;

    Widget child = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(fg),
            ),
          )
        : icon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 18, color: fg),
                  const SizedBox(width: 8),
                  Text(label, style: _labelStyle(fg)),
                ],
              )
            : Text(label, style: _labelStyle(fg));

    final button = SizedBox(
      height: height,
      width: fullWidth ? double.infinity : null,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: bg,
          disabledBackgroundColor: bg.withOpacity(0.55),
          foregroundColor: fg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
        child: child,
      ),
    );

    return button;
  }

  TextStyle _labelStyle(Color color) => TextStyle(
        fontFamily: 'Sora',
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: color,
      );
}

// ── Outlined variant ───────────────────────────────────────────────────────────
class _OutlinedButton extends AppButton {
  const _OutlinedButton({
    super.key,
    required super.label,
    required super.onPressed,
    super.isLoading,
    super.fullWidth,
    super.icon,
    super.height,
  });

  @override
  Widget build(BuildContext context) {
    const fg = AppColors.orangeBright;

    Widget child = isLoading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(fg),
            ),
          )
        : icon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 18, color: fg),
                  const SizedBox(width: 8),
                  Text(label, style: _outlinedLabelStyle),
                ],
              )
            : Text(label, style: _outlinedLabelStyle);

    return SizedBox(
      height: height,
      width: fullWidth ? double.infinity : null,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: fg,
          side: BorderSide(
            color: onPressed == null
                ? AppColors.borderLight
                : AppColors.orangeBright,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
        child: child,
      ),
    );
  }

  static const _outlinedLabelStyle = TextStyle(
    fontFamily: 'Sora',
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.orangeBright,
  );
}

// ── Text / ghost variant ───────────────────────────────────────────────────────
class _TextButton extends AppButton {
  const _TextButton({
    super.key,
    required super.label,
    required super.onPressed,
    super.color,
  });

  @override
  Widget build(BuildContext context) {
    final fg = color ?? AppColors.orangeBright;

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: fg,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Sora',
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}

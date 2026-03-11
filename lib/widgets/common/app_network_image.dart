import 'package:flutter/material.dart';

import '../../../config/app_theme.dart';

/// A network image that handles loading, error, and empty-URL states
/// consistently across the entire app.
///
/// Usage:
///   AppNetworkImage(url: hostel.imageUrls.first, height: 140)
///   AppNetworkImage.avatar(url: user.avatarUrl, size: 40)
///   AppNetworkImage.hero(url: hostel.imageUrls.first)
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.url,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholderIcon = Icons.apartment_outlined,
    this.placeholderIconSize = 40.0,
  });

  /// Circular avatar variant
  factory AppNetworkImage.avatar({
    Key? key,
    required String? url,
    required double size,
    required initials,
    required int radius,
  }) {
    return AppNetworkImage(
      key: key,
      url: url,
      height: size,
      width: size,
      borderRadius: BorderRadius.circular(size / 2),
      placeholderIcon: Icons.person_outline,
      placeholderIconSize: size * 0.45,
    );
  }

  /// Full-width hero image (e.g. hostel detail carousel)
  factory AppNetworkImage.hero({
    Key? key,
    required String? url,
    double height = 260,
  }) {
    return AppNetworkImage(
      key: key,
      url: url,
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
      placeholderIconSize: 56,
    );
  }

  /// Hostel card thumbnail
  factory AppNetworkImage.card({Key? key, required String? url}) {
    return AppNetworkImage(
      key: key,
      url: url,
      height: 140,
      width: double.infinity,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
    );
  }

  final String? url;
  final double? height;
  final double? width;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final IconData placeholderIcon;
  final double placeholderIconSize;

  @override
  Widget build(BuildContext context) {
    final image = _buildImage();

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: image);
    }
    return image;
  }

  Widget _buildImage() {
    if (url == null || url!.isEmpty) return _placeholder();

    return Image.network(
      url!,
      height: height,
      width: width,
      fit: fit,
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return _shimmer();
      },
      errorBuilder: (_, __, ___) => _placeholder(),
    );
  }

  Widget _placeholder() {
    return Container(
      height: height,
      width: width,
      color: AppColors.borderLight,
      child: Center(
        child: Icon(
          placeholderIcon,
          size: placeholderIconSize,
          color: AppColors.textHintLight,
        ),
      ),
    );
  }

  Widget _shimmer() {
    return Container(
      height: height,
      width: width,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE8EAED), Color(0xFFF5F5F5), Color(0xFFE8EAED)],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../config/app_theme.dart';

/// A small pill badge displaying a single amenity with an emoji icon.
///
/// Usage:
///   AmenityChip(amenity: 'WiFi')
///   AmenityChip(amenity: 'Water', large: true)
///
/// The [large] variant is used on the hostel detail screen's full amenity grid.
/// The default (small) variant is used on hostel cards.
class AmenityChip extends StatelessWidget {
  const AmenityChip({
    super.key,
    required this.amenity,
    this.large = false,
  });

  final String amenity;
  final bool large;

  // Emoji map — add more as needed
  static const _icons = <String, String>{
    'WiFi': '📶',
    'Water': '💧',
    'Security': '🔒',
    'Parking': '🚗',
    'Laundry': '👕',
    'Kitchen': '🍳',
    'Study Room': '📚',
    'Generator': '⚡',
    'CCTV': '📹',
    'Cleaning': '🧹',
    'Gym': '🏋️',
    'Swimming Pool': '🏊',
    'Air Conditioning': '❄️',
    'Balcony': '🌿',
    'TV': '📺',
  };

  @override
  Widget build(BuildContext context) {
    final icon = _icons[amenity] ?? '✦';

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 10 : 7,
        vertical: large ? 5 : 3,
      ),
      decoration: BoxDecoration(
        color: AppColors.orangeBright.withOpacity(0.08),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: AppColors.orangeBright.withOpacity(0.18),
        ),
      ),
      child: Text(
        '$icon $amenity',
        style: TextStyle(
          fontFamily: 'Sora',
          fontSize: large ? 11 : 9,
          fontWeight: FontWeight.w600,
          color: AppColors.orangePrimary,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../config/app_theme.dart';

/// Blue "Verified" pill badge shown on verified hostels.
///
/// Usage:
///   if (hostel.isVerified) const VerifiedBadge()
///   if (hostel.isVerified) const VerifiedBadge(large: true)
class VerifiedBadge extends StatelessWidget {
  const VerifiedBadge({super.key, this.large = false});

  final bool large;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 10 : 7,
        vertical: large ? 5 : 3,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: const Color(0xFF90CAF9)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.verified_rounded,
            size: large ? 13 : 10,
            color: AppColors.blueLight,
          ),
          SizedBox(width: large ? 4 : 3),
          Text(
            'Verified',
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: large ? 11 : 9,
              fontWeight: FontWeight.w700,
              color: AppColors.blueLight,
            ),
          ),
        ],
      ),
    );
  }
}

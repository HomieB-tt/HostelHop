import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../config/app_routes.dart';
import '../../../config/app_theme.dart';
import '../../../models/hostel_model.dart';
import '../../../utils/price_formatter.dart';
import '../common/app_network_image.dart';

/// The standard hostel card — used in home, search results,
/// and owner dashboard hostel list.
///
/// Tapping navigates to hostel detail.
/// Pass [onWishlistToggle] to show a tappable heart icon.
class HostelCard extends StatelessWidget {
  const HostelCard({
    super.key,
    required this.hostel,
    this.isWishlisted = false,
    this.onWishlistToggle,
  });

  final HostelModel hostel;
  final bool isWishlisted;
  final VoidCallback? onWishlistToggle;

  @override
  Widget build(BuildContext context) {
    return _PressScaleWrapper(
      onTap: () => context.push(AppRoutes.hostelDetail(hostel.id)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image (Hero source) ───────────────────────────────────────
            Hero(
              tag: 'hostel-image-${hostel.id}',
              child: AppNetworkImage.card(
                url: hostel.imageUrls.isNotEmpty
                    ? hostel.imageUrls.first
                    : null,
              ),
            ),

            // ── Info ─────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + wishlist
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          hostel.name,
                          style: const TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimaryLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (onWishlistToggle != null)
                        GestureDetector(
                          onTap: onWishlistToggle,
                          child: Icon(
                            isWishlisted
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 18,
                            color: isWishlisted
                                ? AppColors.error
                                : Colors.grey.shade400,
                          ),
                        )
                      else
                        Icon(
                          Icons.favorite_border,
                          size: 18,
                          color: Colors.grey.shade400,
                        ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Location
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 12,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          hostel.location,
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Amenity badges + price
                  Row(
                    children: [
                      ...hostel.amenities
                          .take(2)
                          .map(
                            (a) => Container(
                              margin: const EdgeInsets.only(right: 6),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F3F4),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Text(
                                a,
                                style: const TextStyle(
                                  fontFamily: 'Sora',
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondaryLight,
                                ),
                              ),
                            ),
                          ),
                      const Spacer(),
                      Text(
                        PriceFormatter.raw(hostel.pricePerSemester),
                        style: const TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                      const Text(
                        ' /sem',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 10,
                          color: AppColors.textHintLight,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Rating + urgency badge
                  Row(
                    children: [
                      const Text('⭐', style: TextStyle(fontSize: 11)),
                      const SizedBox(width: 3),
                      Text(
                        hostel.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                      Text(
                        ' (${hostel.reviewCount})',
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 10,
                          color: AppColors.textHintLight,
                        ),
                      ),
                      const Spacer(),
                      if (hostel.isAlmostFull)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFEBEE),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Text(
                            '⚡ ${hostel.roomsAvailable} left',
                            style: const TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFE53935),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Press-scale wrapper ────────────────────────────────────────────────────────
/// Wraps any widget with a subtle scale-down on press — 1.0 → 0.97.
/// Reusable across hostel cards, search result cards, etc.
class _PressScaleWrapper extends StatefulWidget {
  const _PressScaleWrapper({required this.child, required this.onTap});
  final Widget child;
  final VoidCallback onTap;

  @override
  State<_PressScaleWrapper> createState() => _PressScaleWrapperState();
}

class _PressScaleWrapperState extends State<_PressScaleWrapper>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 180),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: widget.child,
      ),
    );
  }
}

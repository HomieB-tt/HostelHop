import 'package:flutter/material.dart';

import '../../../config/app_theme.dart';
import '../common/app_network_image.dart';

/// Swipeable full-width image carousel for the hostel detail screen.
///
/// Shows a dot indicator and an image counter badge.
/// Tapping an image pushes to the gallery screen (via [onTap]).
///
/// Usage:
///   HostelImageCarousel(
///     imageUrls: hostel.imageUrls,
///     onTap: () => context.push(AppRoutes.hostelGallery(hostel.id)),
///   )
class HostelImageCarousel extends StatefulWidget {
  const HostelImageCarousel({
    super.key,
    required this.imageUrls,
    this.height = 260.0,
    this.onTap,
  });

  final List<String> imageUrls;
  final double height;
  final VoidCallback? onTap;

  @override
  State<HostelImageCarousel> createState() => _HostelImageCarouselState();
}

class _HostelImageCarouselState extends State<HostelImageCarousel> {
  final _controller = PageController();
  int _current = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final urls = widget.imageUrls;

    if (urls.isEmpty) {
      return _Placeholder(height: widget.height);
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: SizedBox(
        height: widget.height,
        child: Stack(
          children: [
            // ── Page view ────────────────────────────────────────────────────
            PageView.builder(
              controller: _controller,
              itemCount: urls.length,
              onPageChanged: (i) => setState(() => _current = i),
              itemBuilder: (_, i) => AppNetworkImage.hero(
                url: urls[i],
                height: widget.height,
              ),
            ),

            // ── Gradient overlay (bottom) ────────────────────────────────────
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 80,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.45),
                    ],
                  ),
                ),
              ),
            ),

            // ── Dot indicator ────────────────────────────────────────────────
            if (urls.length > 1)
              Positioned(
                bottom: 12,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    urls.length,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: _current == i ? 18 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _current == i
                            ? Colors.white
                            : Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ),

            // ── Image counter badge ──────────────────────────────────────────
            if (urls.length > 1)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.45),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    '${_current + 1} / ${urls.length}',
                    style: const TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

            // ── "View all" tap hint ──────────────────────────────────────────
            if (widget.onTap != null && urls.length > 1)
              Positioned(
                bottom: 12,
                right: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.45),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.photo_library_outlined,
                          size: 12, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        'View all',
                        style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Empty placeholder ──────────────────────────────────────────────────────────
class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.height});
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      color: AppColors.borderLight,
      child: const Center(
        child: Icon(
          Icons.apartment_outlined,
          size: 56,
          color: AppColors.textHintLight,
        ),
      ),
    );
  }
}

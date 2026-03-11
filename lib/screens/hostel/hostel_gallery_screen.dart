import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/app_theme.dart';
import '../../providers/hostel_provider.dart';
import '../../widgets/common/async_value_widget.dart';
import '../../widgets/common/app_network_image.dart';

/// Full-screen photo gallery for a hostel.
/// Receives [hostelId] as a path parameter from GoRouter.
///
/// Route: AppRoutes.hostelGallery(hostelId)
class HostelGalleryScreen extends ConsumerStatefulWidget {
  const HostelGalleryScreen({
    super.key,
    required this.hostelId,
    this.initialIndex = 0,
  });

  final String hostelId;
  final int initialIndex;

  @override
  ConsumerState<HostelGalleryScreen> createState() =>
      _HostelGalleryScreenState();
}

class _HostelGalleryScreenState extends ConsumerState<HostelGalleryScreen> {
  late final PageController _pageCtrl;
  late int _currentIndex;
  bool _uiVisible = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageCtrl = PageController(initialPage: widget.initialIndex);

    // Full-screen immersive mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    // Restore system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _toggleUI() => setState(() => _uiVisible = !_uiVisible);

  @override
  Widget build(BuildContext context) {
    final hostelAsync = ref.watch(hostelDetailProvider(widget.hostelId));

    return Scaffold(
      backgroundColor: Colors.black,
      body: AsyncValueWidget(
        value: hostelAsync,
        data: (hostel) {
          final images = hostel.imageUrls;

          if (images.isEmpty) {
            return const Center(
              child: Text(
                'No photos available',
                style: TextStyle(
                  fontFamily: 'Sora',
                  color: Colors.white54,
                  fontSize: 14,
                ),
              ),
            );
          }

          return Stack(
            children: [
              // ── Swipeable page view ──────────────────────────────────────
              GestureDetector(
                onTap: _toggleUI,
                child: PageView.builder(
                  controller: _pageCtrl,
                  itemCount: images.length,
                  onPageChanged: (i) => setState(() => _currentIndex = i),
                  itemBuilder: (_, i) => _ZoomablePage(url: images[i]),
                ),
              ),

              // ── Top bar (back + title) ────────────────────────────────────
              AnimatedOpacity(
                opacity: _uiVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: IgnorePointer(
                  ignoring: !_uiVisible,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black54, Colors.transparent],
                        stops: [0.0, 1.0],
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Colors.white,
                              ),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                hostel.name,
                                style: const TextStyle(
                                  fontFamily: 'Sora',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // Counter badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black45,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Text(
                                '${_currentIndex + 1} / ${images.length}',
                                style: const TextStyle(
                                  fontFamily: 'Sora',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ── Bottom dot indicator ──────────────────────────────────────
              AnimatedOpacity(
                opacity: _uiVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: IgnorePointer(
                  ignoring: !_uiVisible,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      padding: const EdgeInsets.only(bottom: 32),
                      child: _DotIndicator(
                        count: images.length,
                        current: _currentIndex,
                      ),
                    ),
                  ),
                ),
              ),

              // ── Thumbnail strip ───────────────────────────────────────────
              if (images.length > 1)
                AnimatedOpacity(
                  opacity: _uiVisible ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: IgnorePointer(
                    ignoring: !_uiVisible,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [Colors.black54, Colors.transparent],
                          ),
                        ),
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).padding.bottom + 16,
                          top: 16,
                        ),
                        child: _ThumbnailStrip(
                          images: images,
                          current: _currentIndex,
                          onTap: (i) {
                            _pageCtrl.animateToPage(
                              i,
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeInOut,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// ── Zoomable page ──────────────────────────────────────────────────────────────
class _ZoomablePage extends StatelessWidget {
  const _ZoomablePage({required this.url});
  final String url;

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      minScale: 1.0,
      maxScale: 4.0,
      child: Center(
        child: AppNetworkImage(
          url: url,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

// ── Dot indicator ──────────────────────────────────────────────────────────────
class _DotIndicator extends StatelessWidget {
  const _DotIndicator({required this.count, required this.current});
  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    if (count <= 1) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count > 10 ? 10 : count, // cap dots at 10
        (i) {
          final idx = count > 10 ? (i * count ~/ 10) : i;
          final active =
              idx == current || (count > 10 && i == (current * 10 ~/ count));
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: active ? 18 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: active
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(3),
            ),
          );
        },
      ),
    );
  }
}

// ── Thumbnail strip ────────────────────────────────────────────────────────────
class _ThumbnailStrip extends StatelessWidget {
  const _ThumbnailStrip({
    required this.images,
    required this.current,
    required this.onTap,
  });

  final List<String> images;
  final int current;
  final void Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: images.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (_, i) {
          final isActive = i == current;
          return GestureDetector(
            onTap: () => onTap(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isActive
                      ? AppColors.orangeBright
                      : Colors.white.withValues(alpha: 0.3),
                  width: isActive ? 2 : 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Opacity(
                  opacity: isActive ? 1.0 : 0.55,
                  child: AppNetworkImage(
                    url: images[i],
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

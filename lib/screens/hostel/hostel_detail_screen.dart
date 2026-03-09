import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/app_theme.dart';
import '../../config/app_routes.dart';
import '../../models/hostel_model.dart';
import '../../providers/hostel_provider.dart';

// ── Amenity icon map ───────────────────────────────────────────────────────────
const Map<String, String> _amenityIcons = {
  'WiFi': '📶',
  'Fast WiFi': '📶',
  'Air Con': '❄️',
  'Air Conditioning': '❄️',
  '24/7 Security': '🔒',
  'Security': '🔒',
  'Hot Shower': '🚿',
  'Study Room': '📚',
  'Kitchen': '🍳',
  'Parking': '🚗',
  'Generator': '⚡',
  'CCTV': '📹',
  'Laundry': '👕',
  'Gym': '🏋️',
  'Balcony': '🏡',
};

String _amenityIcon(String amenity) => _amenityIcons[amenity] ?? '✅';

// ── Screen ─────────────────────────────────────────────────────────────────────
class HostelDetailScreen extends ConsumerStatefulWidget {
  const HostelDetailScreen({super.key, required this.hostelId});
  final String hostelId;

  @override
  ConsumerState<HostelDetailScreen> createState() => _HostelDetailScreenState();
}

class _HostelDetailScreenState extends ConsumerState<HostelDetailScreen> {
  final PageController _imagePageController = PageController();
  int _currentImagePage = 0;
  bool _isWishlisted = false;

  @override
  void dispose() {
    _imagePageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hostelAsync = ref.watch(hostelDetailProvider(widget.hostelId));

    return hostelAsync.when(
      loading: () => const _LoadingScreen(),
      error: (e, _) => _ErrorScreen(message: e.toString()),
      data: (hostel) => _DetailScaffold(
        hostel: hostel,
        imagePageController: _imagePageController,
        currentImagePage: _currentImagePage,
        isWishlisted: _isWishlisted,
        onPageChanged: (i) => setState(() => _currentImagePage = i),
        onWishlistToggle: () => setState(() => _isWishlisted = !_isWishlisted),
        onBack: () => context.pop(),
        onShare: () => _onShare(hostel),
        onLockRoom: () => context.push(AppRoutes.booking(hostel.id)),
        onViewReviews: () => context.push(AppRoutes.hostelReviews(hostel.id)),
        onViewGallery: () => context.push(AppRoutes.hostelGallery(hostel.id)),
      ),
    );
  }

  void _onShare(HostelModel hostel) {
    // Share.share will be wired when share_plus is integrated
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Sharing ${hostel.name}...',
          style: const TextStyle(fontFamily: 'Sora', fontSize: 13),
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

// ── Main scaffold ──────────────────────────────────────────────────────────────
class _DetailScaffold extends StatelessWidget {
  const _DetailScaffold({
    required this.hostel,
    required this.imagePageController,
    required this.currentImagePage,
    required this.isWishlisted,
    required this.onPageChanged,
    required this.onWishlistToggle,
    required this.onBack,
    required this.onShare,
    required this.onLockRoom,
    required this.onViewReviews,
    required this.onViewGallery,
  });

  final HostelModel hostel;
  final PageController imagePageController;
  final int currentImagePage;
  final bool isWishlisted;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onWishlistToggle;
  final VoidCallback onBack;
  final VoidCallback onShare;
  final VoidCallback onLockRoom;
  final VoidCallback onViewReviews;
  final VoidCallback onViewGallery;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        child: Stack(
          children: [
            // ── Scrollable content ─────────────────────────────────────
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Hero image sliver
                SliverToBoxAdapter(
                  child: _HeroImageSection(
                    hostel: hostel,
                    pageController: imagePageController,
                    currentPage: currentImagePage,
                    onPageChanged: onPageChanged,
                    onBack: onBack,
                    onShare: onShare,
                    onViewGallery: onViewGallery,
                  ),
                ),

                // Content
                SliverToBoxAdapter(
                  child: _ContentSection(
                    hostel: hostel,
                    isWishlisted: isWishlisted,
                    onWishlistToggle: onWishlistToggle,
                    onViewReviews: onViewReviews,
                  ),
                ),

                // Bottom padding for CTA
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),

            // ── Floating CTA ───────────────────────────────────────────
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _LockRoomCTA(hostel: hostel, onLockRoom: onLockRoom),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Hero image section ─────────────────────────────────────────────────────────
class _HeroImageSection extends StatelessWidget {
  const _HeroImageSection({
    required this.hostel,
    required this.pageController,
    required this.currentPage,
    required this.onPageChanged,
    required this.onBack,
    required this.onShare,
    required this.onViewGallery,
  });

  final HostelModel hostel;
  final PageController pageController;
  final int currentPage;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onBack;
  final VoidCallback onShare;
  final VoidCallback onViewGallery;

  @override
  Widget build(BuildContext context) {
    final images = hostel.imageUrls;
    final topPadding = MediaQuery.of(context).padding.top;

    return SizedBox(
      height: 220,
      child: Stack(
        children: [
          // Image carousel
          GestureDetector(
            onTap: onViewGallery,
            child: PageView.builder(
              controller: pageController,
              onPageChanged: onPageChanged,
              itemCount: images.isEmpty ? 1 : images.length,
              itemBuilder: (_, i) => images.isEmpty
                  ? _HeroPlaceholder()
                  : Image.network(
                      images[i],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (_, __, ___) => _HeroPlaceholder(),
                    ),
            ),
          ),

          // Dark gradient for status bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: topPadding + 60,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.45), Colors.transparent],
                ),
              ),
            ),
          ),

          // Back button
          Positioned(
            top: topPadding + 10,
            left: 14,
            child: _FloatingIconButton(
              onTap: onBack,
              child: const Text('←', style: TextStyle(fontSize: 16)),
            ),
          ),

          // Urgency badge — only when rooms <= 5
          if (hostel.roomsAvailable <= 5)
            Positioned(
              top: topPadding + 10,
              right: 54,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE53935),
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE53935).withOpacity(0.40),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  '⚡ ${hostel.roomsAvailable} Rooms Left!',
                  style: const TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

          // Share button
          Positioned(
            top: topPadding + 10,
            right: 14,
            child: _FloatingIconButton(
              onTap: onShare,
              child: const Icon(
                Icons.share_outlined,
                size: 16,
                color: Color(0xFF1A1A2E),
              ),
            ),
          ),

          // Carousel dots
          if (images.length > 1)
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(images.length, (i) {
                  final isActive = i == currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: isActive ? 16 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isActive
                          ? Colors.white
                          : Colors.white.withOpacity(0.50),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Floating icon button (back / share) ───────────────────────────────────────
class _FloatingIconButton extends StatelessWidget {
  const _FloatingIconButton({required this.onTap, required this.child});
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.10), blurRadius: 6),
          ],
        ),
        child: Center(child: child),
      ),
    );
  }
}

// ── Hero placeholder ───────────────────────────────────────────────────────────
class _HeroPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE8EAED),
      child: const Center(
        child: Icon(
          Icons.apartment_outlined,
          size: 56,
          color: Color(0xFF9AA0A6),
        ),
      ),
    );
  }
}

// ── Content section ────────────────────────────────────────────────────────────
class _ContentSection extends StatelessWidget {
  const _ContentSection({
    required this.hostel,
    required this.isWishlisted,
    required this.onWishlistToggle,
    required this.onViewReviews,
  });

  final HostelModel hostel;
  final bool isWishlisted;
  final VoidCallback onWishlistToggle;
  final VoidCallback onViewReviews;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title row ────────────────────────────────────────────────
          _TitleRow(
            hostel: hostel,
            isWishlisted: isWishlisted,
            onWishlistToggle: onWishlistToggle,
            onViewReviews: onViewReviews,
          ),

          const SizedBox(height: 16),

          // ── Amenities ────────────────────────────────────────────────
          _AmenitiesSection(amenities: hostel.amenities),

          const SizedBox(height: 14),

          // ── Availability card ─────────────────────────────────────────
          _AvailabilityCard(hostel: hostel),

          const SizedBox(height: 14),

          // ── Pricing ──────────────────────────────────────────────────
          _PricingSection(hostel: hostel),
        ],
      ),
    );
  }
}

// ── Title row ──────────────────────────────────────────────────────────────────
class _TitleRow extends StatelessWidget {
  const _TitleRow({
    required this.hostel,
    required this.isWishlisted,
    required this.onWishlistToggle,
    required this.onViewReviews,
  });

  final HostelModel hostel;
  final bool isWishlisted;
  final VoidCallback onWishlistToggle;
  final VoidCallback onViewReviews;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hostel name
              Text(
                hostel.name,
                style: const TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A2E),
                ),
              ),

              const SizedBox(height: 4),

              // Location
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 13,
                    color: Color(0xFF5F6368),
                  ),
                  const SizedBox(width: 3),
                  Expanded(
                    child: Text(
                      hostel.location,
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 11,
                        color: Color(0xFF5F6368),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Rating row
              GestureDetector(
                onTap: onViewReviews,
                child: Row(
                  children: [
                    // Star icons
                    ...List.generate(5, (i) {
                      final filled = i < hostel.rating.floor();
                      return Text(
                        filled ? '⭐' : '☆',
                        style: const TextStyle(fontSize: 14),
                      );
                    }),
                    const SizedBox(width: 6),
                    Text(
                      hostel.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(${hostel.reviewCount} reviews)',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right,
                      size: 14,
                      color: Colors.grey.shade400,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Wishlist button
        GestureDetector(
          onTap: onWishlistToggle,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isWishlisted
                  ? const Color(0xFFFFEBEE)
                  : const Color(0xFFF8F9FA),
              shape: BoxShape.circle,
              border: Border.all(
                color: isWishlisted
                    ? const Color(0xFFEF9A9A)
                    : const Color(0xFFE8EAED),
              ),
            ),
            child: Center(
              child: Text(
                isWishlisted ? '❤️' : '🤍',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Amenities section ──────────────────────────────────────────────────────────
class _AmenitiesSection extends StatelessWidget {
  const _AmenitiesSection({required this.amenities});
  final List<String> amenities;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Amenities',
          style: TextStyle(
            fontFamily: 'Sora',
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1.8,
          children: amenities
              .take(6)
              .map((a) => _AmenityChip(amenity: a))
              .toList(),
        ),
      ],
    );
  }
}

// ── Amenity chip ───────────────────────────────────────────────────────────────
class _AmenityChip extends StatelessWidget {
  const _AmenityChip({required this.amenity});
  final String amenity;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE8EAED)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_amenityIcon(amenity), style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 4),
          Text(
            amenity,
            style: const TextStyle(
              fontFamily: 'Sora',
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: Color(0xFF5F6368),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ── Availability card ──────────────────────────────────────────────────────────
class _AvailabilityCard extends StatelessWidget {
  const _AvailabilityCard({required this.hostel});
  final HostelModel hostel;

  @override
  Widget build(BuildContext context) {
    final fraction = hostel.totalRooms > 0
        ? hostel.roomsAvailable / hostel.totalRooms
        : 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFFE0B2)),
      ),
      child: Row(
        children: [
          // Big number
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${hostel.roomsAvailable}',
                style: const TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.orangeBright,
                  height: 1,
                ),
              ),
              const Text(
                'Rooms\nRemaining',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 10,
                  color: Color(0xFF5F6368),
                  height: 1.3,
                ),
              ),
            ],
          ),

          const SizedBox(width: 14),

          // Progress bar + label
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: fraction,
                    minHeight: 8,
                    backgroundColor: const Color(0xFFFFE0B2),
                    valueColor: const AlwaysStoppedAnimation(
                      AppColors.orangeBright,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${hostel.roomsAvailable} of ${hostel.totalRooms} rooms left',
                  style: const TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 10,
                    color: Color(0xFF9AA0A6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Pricing section ────────────────────────────────────────────────────────────
class _PricingSection extends StatelessWidget {
  const _PricingSection({required this.hostel});
  final HostelModel hostel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              'UGX ${_formatPrice(hostel.pricePerSemester)}',
              style: const TextStyle(
                fontFamily: 'Sora',
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              '/semester',
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 12,
                color: Color(0xFF9AA0A6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Commitment fee: UGX ${_formatPrice(hostel.commitmentFee)}',
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 11,
            color: Color(0xFF5F6368),
          ),
        ),
      ],
    );
  }

  String _formatPrice(int price) => price.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]},',
  );
}

// ── Lock Room CTA ──────────────────────────────────────────────────────────────
class _LockRoomCTA extends StatelessWidget {
  const _LockRoomCTA({required this.hostel, required this.onLockRoom});
  final HostelModel hostel;
  final VoidCallback onLockRoom;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.orangeBright, AppColors.orangePrimary],
          ),
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: AppColors.orangeBright.withOpacity(0.40),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: hostel.roomsAvailable > 0 ? onLockRoom : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            disabledForegroundColor: Colors.white60,
            minimumSize: const Size(double.infinity, 52),
            shape: const StadiumBorder(),
            elevation: 0,
          ),
          child: Text(
            hostel.roomsAvailable > 0
                ? '🔒 Lock My Room'
                : '😔 No Rooms Available',
            style: const TextStyle(
              fontFamily: 'Sora',
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Loading screen ─────────────────────────────────────────────────────────────
class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // Skeleton header
            Container(height: 220, color: const Color(0xFFE8EAED)),
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(color: AppColors.orangeBright),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Error screen ───────────────────────────────────────────────────────────────
class _ErrorScreen extends StatelessWidget {
  const _ErrorScreen({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A2E)),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('😕', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              const Text(
                'Could not load hostel',
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 13,
                  color: Color(0xFF5F6368),
                ),
              ),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: () => context.pop(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.orangeBright,
                  side: const BorderSide(color: AppColors.orangeBright),
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: const Text(
                  '← Go Back',
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

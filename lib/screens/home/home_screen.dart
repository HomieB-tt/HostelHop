import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/app_theme.dart';
import '../../config/app_routes.dart';
import '../../models/hostel_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/hostel_provider.dart';

// ── Heat index data ────────────────────────────────────────────────────────────
class _HeatLevel {
  const _HeatLevel({
    required this.label,
    required this.emoji,
    required this.color,
    required this.tip,
  });
  final String label;
  final String emoji;
  final Color color;
  final String tip;
}

const List<_HeatLevel> _heatLevels = [
  _HeatLevel(
    label: 'Cool',
    emoji: '😌',
    color: Color(0xFF4CAF50),
    tip: 'Enkoola nzungu! Stay cool and book from home.',
  ),
  _HeatLevel(
    label: 'Warm',
    emoji: '😅',
    color: Color(0xFFFFC107),
    tip: 'Omupiira gw\'omwaka! Find a shaded room fast.',
  ),
  _HeatLevel(
    label: 'Hot',
    emoji: '🥵',
    color: Color(0xFFFF7043),
    tip: 'Akasana kasiba! Book your room from home.',
  ),
  _HeatLevel(
    label: '🔥 Extreme',
    emoji: '🔥',
    color: Color(0xFFE53935),
    tip:
        'Akasana tokawulira? Book your room from home without having to sweat asf.',
  ),
];

// ── Sun Meter expanded height ──────────────────────────────────────────────────
const double _kSunMeterExpandedHeight = 148.0;
const double _kSunMeterCollapsedHeight = 38.0;

// ── Screen ─────────────────────────────────────────────────────────────────────
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _navIndex = 0;

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final hostelState = ref.watch(hostelListProvider);

    final firstName =
        authState.user?.userMetadata?['full_name']
            ?.toString()
            .split(' ')
            .first ??
        'there';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Collapsing orange app bar ──────────────────────────────
            _GreetingSliverAppBar(firstName: firstName),

            // ── Pinned Sun Meter ───────────────────────────────────────
            const SliverPersistentHeader(
              pinned: true,
              delegate: _SunMeterDelegate(
                expandedHeight: _kSunMeterExpandedHeight,
                collapsedHeight: _kSunMeterCollapsedHeight,
                tempC: 34,
                feelsLikeC: 38,
                heatFraction: 0.82, // 0.0 → 1.0
                heatLevelIndex: 3, // 0=Cool 1=Warm 2=Hot 3=Extreme
              ),
            ),

            // ── Section header ─────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Available Hostels',
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.push(AppRoutes.search),
                      child: const Text(
                        'View all',
                        style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.blueLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Hostel list ────────────────────────────────────────────
            hostelState.when(
              loading: () => const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.orangeBright,
                  ),
                ),
              ),
              error: (e, _) =>
                  SliverToBoxAdapter(child: _ErrorCard(message: e.toString())),
              data: (hostels) => hostels.isEmpty
                  ? const SliverToBoxAdapter(child: _EmptyState())
                  : SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (_, i) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _StaggeredItem(
                              index: i,
                              child: _HostelCard(hostel: hostels[i]),
                            ),
                          ),
                          childCount: hostels.length,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),

      // ── Bottom nav ─────────────────────────────────────────────────────
      bottomNavigationBar: _BottomNav(
        currentIndex: _navIndex,
        onTap: (i) {
          setState(() => _navIndex = i);
          switch (i) {
            case 0:
              break; // already home
            case 1:
              context.push(AppRoutes.search);
            case 2:
              context.push(AppRoutes.myBookings);
            case 3:
              context.push(AppRoutes.profile);
          }
        },
      ),
    );
  }
}

// ── Greeting SliverAppBar ──────────────────────────────────────────────────────
class _GreetingSliverAppBar extends StatelessWidget {
  const _GreetingSliverAppBar({required this.firstName});
  final String firstName;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 164.0,
      pinned: true,
      floating: false,
      elevation: 0,
      backgroundColor: AppColors.orangePrimary,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      // Collapsed state — inline title + search
      title: Row(
        children: [
          const Expanded(
            child: Text(
              'Find Your Shade',
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          _AppBarActions(),
        ],
      ),
      // Below the title when collapsed — search bar
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(52),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: _SearchBar(onFilterTap: () {}),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.orangeBright,
                AppColors.orangePrimary,
                AppColors.orangeDim,
              ],
              stops: [0.0, 0.55, 1.0],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _greeting(),
                              style: const TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$firstName 👋',
                              style: const TextStyle(
                                fontFamily: 'Sora',
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _AppBarActions(),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Title
                  const Text(
                    'Find Your Shade',
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white70,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Search bar inside flexibleSpace
                  _SearchBar(onFilterTap: () {}),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning,';
    if (hour < 17) return 'Good afternoon,';
    return 'Good evening,';
  }
}

// ── App bar action icons ───────────────────────────────────────────────────────
class _AppBarActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Notification bell
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: const Icon(
                Icons.notifications_outlined,
                color: Colors.white,
                size: 22,
              ),
              onPressed: () {},
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFD600),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
        // Avatar
        Consumer(
          builder: (_, ref, __) {
            final user = ref.watch(authProvider).user;
            final initial =
                user?.userMetadata?['full_name']
                    ?.toString()
                    .substring(0, 1)
                    .toUpperCase() ??
                'U';
            return GestureDetector(
              onTap: () => GoRouter.of(context).push(AppRoutes.profile),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.60),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: const TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

// ── Search bar ─────────────────────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.onFilterTap});
  final VoidCallback onFilterTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => GoRouter.of(context).push(AppRoutes.search),
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withValues(alpha: 0.30)),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            const Icon(Icons.search, color: Colors.white70, size: 18),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Search hostels near campus...',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 13,
                  color: Colors.white70,
                ),
              ),
            ),
            GestureDetector(
              onTap: onFilterTap,
              child: Container(
                margin: const EdgeInsets.all(5),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Icon(Icons.tune, color: Colors.white, size: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sun Meter SliverPersistentHeaderDelegate ───────────────────────────────────
class _SunMeterDelegate extends SliverPersistentHeaderDelegate {
  const _SunMeterDelegate({
    required this.expandedHeight,
    required this.collapsedHeight,
    required this.tempC,
    required this.feelsLikeC,
    required this.heatFraction,
    required this.heatLevelIndex,
  });

  final double expandedHeight;
  final double collapsedHeight;
  final int tempC;
  final int feelsLikeC;
  final double heatFraction;
  final int heatLevelIndex;

  @override
  double get minExtent => collapsedHeight;

  @override
  double get maxExtent => expandedHeight;

  @override
  bool shouldRebuild(covariant _SunMeterDelegate old) =>
      old.heatFraction != heatFraction || old.heatLevelIndex != heatLevelIndex;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    // t = 0 → fully expanded, t = 1 → fully collapsed
    final t = (shrinkOffset / (expandedHeight - collapsedHeight)).clamp(
      0.0,
      1.0,
    );

    return _SunMeterSurface(
      t: t,
      tempC: tempC,
      feelsLikeC: feelsLikeC,
      heatFraction: heatFraction,
      heatLevelIndex: heatLevelIndex,
    );
  }
}

// ── Sun Meter surface — interpolates between expanded and collapsed ─────────────
class _SunMeterSurface extends StatelessWidget {
  const _SunMeterSurface({
    required this.t,
    required this.tempC,
    required this.feelsLikeC,
    required this.heatFraction,
    required this.heatLevelIndex,
  });

  final double t;
  final int tempC;
  final int feelsLikeC;
  final double heatFraction;
  final int heatLevelIndex;

  @override
  Widget build(BuildContext context) {
    final level = _heatLevels[heatLevelIndex];

    return Container(
      color: const Color(0xFFF8F9FA),
      child: AnimatedContainer(
        duration: Duration.zero,
        margin: EdgeInsets.fromLTRB(
          16,
          lerpDouble(8, 0, t)!,
          16,
          lerpDouble(8, 0, t)!,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(lerpDouble(12, 0, t)!),
          border: Border.all(color: const Color(0xFFE8EAED)),
          boxShadow: t < 0.5
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05 * (1 - t)),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: t < 0.5
            ? _ExpandedContent(
                tempC: tempC,
                feelsLikeC: feelsLikeC,
                heatFraction: heatFraction,
                level: level,
                opacity: 1 - (t * 2),
              )
            : _CollapsedContent(
                tempC: tempC,
                feelsLikeC: feelsLikeC,
                level: level,
                opacity: (t - 0.5) * 2,
              ),
      ),
    );
  }
}

double? lerpDouble(double a, double b, double t) => a + (b - a) * t;

// ── Sun Meter — expanded content ───────────────────────────────────────────────
class _ExpandedContent extends StatelessWidget {
  const _ExpandedContent({
    required this.tempC,
    required this.feelsLikeC,
    required this.heatFraction,
    required this.level,
    required this.opacity,
  });

  final int tempC;
  final int feelsLikeC;
  final double heatFraction;
  final _HeatLevel level;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity.clamp(0.0, 1.0),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Text('☀️', style: TextStyle(fontSize: 14)),
                    SizedBox(width: 6),
                    Text(
                      'SUN METER · KAMPALA',
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF5F6368),
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                Text(
                  '$tempC°C feels $feelsLikeC°',
                  style: const TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Gradient bar
            _HeatBar(fraction: heatFraction),

            const SizedBox(height: 4),

            // Labels
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Cool',
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 8,
                    color: Color(0xFF4CAF50),
                  ),
                ),
                Text(
                  'Warm',
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 8,
                    color: Color(0xFFFFC107),
                  ),
                ),
                Text(
                  'Hot',
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 8,
                    color: Color(0xFFFF7043),
                  ),
                ),
                Text(
                  '🔥 Extreme',
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 8,
                    color: Color(0xFFE53935),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Luganda tip
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '🏃 ${level.tip}',
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 10,
                  color: Color(0xFF5F6368),
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sun Meter — collapsed strip content ───────────────────────────────────────
class _CollapsedContent extends StatelessWidget {
  const _CollapsedContent({
    required this.tempC,
    required this.feelsLikeC,
    required this.level,
    required this.opacity,
  });

  final int tempC;
  final int feelsLikeC;
  final _HeatLevel level;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity.clamp(0.0, 1.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Text('☀️', style: TextStyle(fontSize: 12)),
                SizedBox(width: 6),
                Text(
                  'SUN METER · KAMPALA',
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF5F6368),
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
            Text(
              '$tempC°C feels $feelsLikeC° · ${level.label} ${level.emoji}',
              style: const TextStyle(
                fontFamily: 'Sora',
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A2E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Heat gradient bar ──────────────────────────────────────────────────────────
class _HeatBar extends StatelessWidget {
  const _HeatBar({required this.fraction});
  final double fraction;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final width = constraints.maxWidth;
        final thumbX = width * fraction;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Track
            Container(
              height: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF4CAF50),
                    Color(0xFFFFC107),
                    Color(0xFFFF7043),
                    Color(0xFFE53935),
                  ],
                ),
              ),
            ),
            // Thumb
            Positioned(
              left: (thumbX - 6).clamp(0, width - 12),
              top: -3,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE53935), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ── Hostel card ────────────────────────────────────────────────────────────────
class _HostelCard extends StatelessWidget {
  const _HostelCard({required this.hostel});
  final HostelModel hostel;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.hostelDetail(hostel.id)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE8EAED)),
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
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
              child: hostel.imageUrls.isNotEmpty
                  ? Image.network(
                      hostel.imageUrls.first,
                      height: 140,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _ImagePlaceholder(),
                    )
                  : _ImagePlaceholder(),
            ),

            // Info
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
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                      ),
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

                  // Badges + price
                  Row(
                    children: [
                      // Amenity badges (first 2)
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
                                  color: Color(0xFF5F6368),
                                ),
                              ),
                            ),
                          ),
                      const Spacer(),
                      // Price
                      Text(
                        'UGX ${_formatPrice(hostel.pricePerSemester)}',
                        style: const TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      const Text(
                        '/sem',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 10,
                          color: Color(0xFF9AA0A6),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Rating + rooms left
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
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      Text(
                        ' (${hostel.reviewCount})',
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 10,
                          color: Color(0xFF9AA0A6),
                        ),
                      ),
                      const Spacer(),
                      if (hostel.roomsAvailable <= 5)
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

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }
}

// ── Image placeholder ──────────────────────────────────────────────────────────
class _ImagePlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      width: double.infinity,
      color: const Color(0xFFE8EAED),
      child: const Center(
        child: Icon(
          Icons.apartment_outlined,
          size: 40,
          color: Color(0xFF9AA0A6),
        ),
      ),
    );
  }
}

// ── Empty state ────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 32),
      child: Column(
        children: [
          const Text('🏚️', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          const Text(
            'No hostels found',
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back soon — new hostels are being added.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 13,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Error card ─────────────────────────────────────────────────────────────────
class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEBEE),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFEF9A9A)),
        ),
        child: Row(
          children: [
            const Text('⚠️', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Could not load hostels: $message',
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 12,
                  color: Color(0xFFB71C1C),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bottom nav ─────────────────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    const items = [
      _NavItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        label: 'Home',
      ),
      _NavItem(icon: Icons.search, activeIcon: Icons.search, label: 'Explore'),
      _NavItem(
        icon: Icons.bookmark_border,
        activeIcon: Icons.bookmark,
        label: 'Bookings',
      ),
      _NavItem(
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        label: 'Profile',
      ),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE8EAED))),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 54,
          child: Row(
            children: List.generate(items.length, (i) {
              final isActive = i == currentIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isActive ? items[i].activeIcon : items[i].icon,
                        size: 20,
                        color: isActive
                            ? AppColors.orangeBright
                            : const Color(0xFF9AA0A6),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        items[i].label,
                        style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: isActive
                              ? AppColors.orangeBright
                              : const Color(0xFF9AA0A6),
                        ),
                      ),
                      const SizedBox(height: 2),
                      if (isActive)
                        Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: AppColors.orangeBright,
                            shape: BoxShape.circle,
                          ),
                        )
                      else
                        const SizedBox(height: 4),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
  final IconData icon;
  final IconData activeIcon;
  final String label;
}

// ── Staggered entrance item ────────────────────────────────────────────────────
/// Fades and slides up each list item with a staggered delay based on [index].
/// Caps delay at item 6 so late items don't wait too long on long lists.
class _StaggeredItem extends StatefulWidget {
  const _StaggeredItem({required this.index, required this.child});
  final int index;
  final Widget child;

  @override
  State<_StaggeredItem> createState() => _StaggeredItemState();
}

class _StaggeredItemState extends State<_StaggeredItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    // Stagger: 60ms per item, capped at item 6
    final delayMs = (widget.index.clamp(0, 6) * 60);
    Future.delayed(Duration(milliseconds: delayMs), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

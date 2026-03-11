import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/app_routes.dart';
import '../../config/app_theme.dart';
import '../../models/hostel_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers//hostel_provider.dart';
import '../../utils/price_formatter.dart';
import '../../widgets/common/async_value_widget.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_empty_state.dart';
import '../../widgets/common/app_network_image.dart';
import '../../widgets/common/fade_up_widget.dart';

class OwnerDashboardScreen extends ConsumerWidget {
  const OwnerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final hostelsAsync = ref.watch(ownerHostelListProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          // ── App bar ─────────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.orangePrimary,
            foregroundColor: Colors.white,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              title: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back,',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                  Text(
                    auth.firstName,
                    style: const TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.orangePrimary, AppColors.orangeDim],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.logout_rounded),
                onPressed: () async {
                  await ref.read(authProvider.notifier).signOut();
                  if (context.mounted) context.go(AppRoutes.login);
                },
              ),
            ],
          ),

          // ── Stats row ────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: hostelsAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (hostels) => _StatsRow(hostels: hostels),
            ),
          ),

          // ── Section header ───────────────────────────────────────────────────
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 10),
              child: Text(
                'Your Hostels',
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimaryLight,
                ),
              ),
            ),
          ),

          // ── Hostel list ──────────────────────────────────────────────────────
          SliverAsyncValueWidget<List<HostelModel>>(
            value: hostelsAsync,
            isEmpty: (h) => h.isEmpty,
            empty: SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: AppEmptyState(
                  emoji: '🏠',
                  title: 'No hostels yet',
                  subtitle:
                      'Add your first hostel to start receiving bookings.',
                  ctaLabel: 'Add Hostel',
                  onCta: () => context.push(AppRoutes.manageHostel),
                ),
              ),
            ),
            data: (hostels) => SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: FadeUpWidget(
                      delay: Duration(milliseconds: i.clamp(0, 5) * 70),
                      child: _OwnerHostelCard(hostel: hostels[i]),
                    ),
                  ),
                  childCount: hostels.length,
                ),
              ),
            ),
          ),
        ],
      ),

      // ── FAB — add hostel ───────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.manageHostel),
        backgroundColor: AppColors.orangeBright,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add Hostel',
          style: TextStyle(
            fontFamily: 'Sora',
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// ── Stats row ──────────────────────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.hostels});
  final List<HostelModel> hostels;

  @override
  Widget build(BuildContext context) {
    final totalRooms = hostels.fold<int>(0, (sum, h) => sum + h.totalRooms);
    final available = hostels.fold<int>(0, (sum, h) => sum + h.roomsAvailable);
    final occupied = totalRooms - available;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _Stat(
            label: 'Hostels',
            value: '${hostels.length}',
            icon: Icons.apartment_rounded,
            color: AppColors.orangeBright,
          ),
          _divider(),
          _Stat(
            label: 'Total Rooms',
            value: '$totalRooms',
            icon: Icons.bed_outlined,
            color: AppColors.blueLight,
          ),
          _divider(),
          _Stat(
            label: 'Occupied',
            value: '$occupied',
            icon: Icons.people_outline_rounded,
            color: AppColors.success,
          ),
          _divider(),
          _Stat(
            label: 'Available',
            value: '$available',
            icon: Icons.door_front_door_outlined,
            color: AppColors.warning,
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(
    height: 36,
    width: 1,
    color: AppColors.borderLight,
    margin: const EdgeInsets.symmetric(horizontal: 8),
  );
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 10,
              color: AppColors.textHintLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Owner hostel card ──────────────────────────────────────────────────────────
class _OwnerHostelCard extends StatelessWidget {
  const _OwnerHostelCard({required this.hostel});
  final HostelModel hostel;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image + status badge
          Stack(
            children: [
              AppNetworkImage.card(
                url: hostel.imageUrls.isNotEmpty
                    ? hostel.imageUrls.first
                    : null,
              ),
              Positioned(
                top: 10,
                right: 10,
                child: _ActiveBadge(isActive: hostel.isActive),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                Text(
                  hostel.name,
                  style: const TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 4),

                // Location
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 12,
                      color: AppColors.textHintLight,
                    ),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        hostel.location,
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 11,
                          color: AppColors.textHintLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Occupancy bar
                _OccupancyBar(hostel: hostel),

                const SizedBox(height: 10),

                // Price + actions
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          PriceFormatter.format(hostel.pricePerSemester),
                          style: const TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimaryLight,
                          ),
                        ),
                        const Text(
                          'per semester',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 10,
                            color: AppColors.textHintLight,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    _ActionButton(
                      icon: Icons.people_outline_rounded,
                      label: 'Bookings',
                      onTap: () => context.push(
                        AppRoutes.manageBookings,
                        extra: hostel.id,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _ActionButton(
                      icon: Icons.bed_outlined,
                      label: 'Rooms',
                      onTap: () =>
                          context.push(AppRoutes.manageRooms, extra: hostel.id),
                    ),
                    const SizedBox(width: 8),
                    _ActionButton(
                      icon: Icons.edit_outlined,
                      label: 'Edit',
                      onTap: () =>
                          context.push(AppRoutes.manageHostel, extra: hostel),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Occupancy bar ──────────────────────────────────────────────────────────────
class _OccupancyBar extends StatelessWidget {
  const _OccupancyBar({required this.hostel});
  final HostelModel hostel;

  @override
  Widget build(BuildContext context) {
    final fraction = hostel.occupancyFraction.clamp(0.0, 1.0);
    final occupied = hostel.totalRooms - hostel.roomsAvailable;
    final color = fraction >= 0.9
        ? AppColors.error
        : fraction >= 0.7
        ? AppColors.warning
        : AppColors.success;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Occupancy',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 11,
                color: AppColors.textHintLight,
              ),
            ),
            Text(
              '$occupied / ${hostel.totalRooms} rooms',
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: fraction,
            minHeight: 6,
            backgroundColor: AppColors.borderLight,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

// ── Active badge ───────────────────────────────────────────────────────────────
class _ActiveBadge extends StatelessWidget {
  const _ActiveBadge({required this.isActive});
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: isActive ? const Color(0xFFA5D6A7) : const Color(0xFFEF9A9A),
        ),
      ),
      child: Text(
        isActive ? '● Active' : '● Inactive',
        style: TextStyle(
          fontFamily: 'Sora',
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: isActive ? AppColors.success : AppColors.error,
        ),
      ),
    );
  }
}

// ── Action button ──────────────────────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: AppColors.orangeBright),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Sora',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

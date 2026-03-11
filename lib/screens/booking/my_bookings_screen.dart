import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/app_theme.dart';
import '../../config/app_routes.dart';
import '../../models/booking_model.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/booking/booking_status_badge.dart';
import '../../widgets/common/fade_up_widget.dart';

// ── Tab definition ─────────────────────────────────────────────────────────────
enum _BookingTab { active, past, cancelled }

extension _BookingTabLabel on _BookingTab {
  String get label {
    switch (this) {
      case _BookingTab.active:
        return 'Active';
      case _BookingTab.past:
        return 'Past';
      case _BookingTab.cancelled:
        return 'Cancelled';
    }
  }
}

// ── Screen ─────────────────────────────────────────────────────────────────────
class MyBookingsScreen extends ConsumerStatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  ConsumerState<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends ConsumerState<MyBookingsScreen> {
  _BookingTab _activeTab = _BookingTab.active;

  @override
  Widget build(BuildContext context) {
    final bookingsAsync = ref.watch(myBookingsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ───────────────────────────────────────────────
              _Header(),

              // ── Tab switcher ──────────────────────────────────────────
              _TabSwitcher(
                activeTab: _activeTab,
                onTabChanged: (t) => setState(() => _activeTab = t),
              ),

              // ── Booking list ──────────────────────────────────────────
              Expanded(
                child: bookingsAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.orangeBright,
                    ),
                  ),
                  error: (e, _) => _ErrorBody(message: e.toString()),
                  data: (bookings) {
                    final filtered = _filterBookings(bookings, _activeTab);
                    if (filtered.isEmpty) {
                      return FadeUpWidget(child: _EmptyState(tab: _activeTab));
                    }
                    return FadeUpWidget(
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                        itemCount: filtered.length + 1, // +1 for support link
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (_, i) {
                          if (i == filtered.length) {
                            return const _SupportLink();
                          }
                          return _BookingCard(booking: filtered[i]);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),

      // ── Bottom nav ──────────────────────────────────────────────────────
      bottomNavigationBar: _BottomNav(
        onHomeTap: () => context.go(AppRoutes.home),
        onExploreTap: () => context.push(AppRoutes.search),
        onProfileTap: () => context.push(AppRoutes.profile),
      ),
    );
  }

  List<BookingModel> _filterBookings(List<BookingModel> all, _BookingTab tab) {
    switch (tab) {
      case _BookingTab.active:
        return all
            .where(
              (b) =>
                  b.status == BookingStatus.confirmed ||
                  b.status == BookingStatus.pending,
            )
            .toList();
      case _BookingTab.past:
        return all.where((b) => b.status == BookingStatus.completed).toList();
      case _BookingTab.cancelled:
        return all.where((b) => b.status == BookingStatus.cancelled).toList();
    }
  }
}

// ── Header ─────────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      color: Colors.white,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Bookings',
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1A2E),
            ),
          ),
          SizedBox(height: 2),
          Text(
            'Track and manage your room reservations',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 12,
              color: Color(0xFF5F6368),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tab switcher ───────────────────────────────────────────────────────────────
class _TabSwitcher extends StatelessWidget {
  const _TabSwitcher({required this.activeTab, required this.onTabChanged});

  final _BookingTab activeTab;
  final ValueChanged<_BookingTab> onTabChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: _BookingTab.values.map((tab) {
              final isActive = tab == activeTab;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTabChanged(tab),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          tab.label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 12,
                            fontWeight: isActive
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isActive
                                ? AppColors.blueLight
                                : const Color(0xFF9AA0A6),
                          ),
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 2,
                        color: isActive
                            ? AppColors.blueLight
                            : Colors.transparent,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const Divider(height: 1, color: Color(0xFFE8EAED)),
        ],
      ),
    );
  }
}

// ── Booking card ───────────────────────────────────────────────────────────────
class _BookingCard extends ConsumerWidget {
  const _BookingCard({required this.booking});
  final BookingModel booking;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8EAED)),
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
          // ── Card header ─────────────────────────────────────────────
          _CardHeader(booking: booking),

          const Divider(height: 1, color: Color(0xFFE8EAED)),

          // ── Card body ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hostel thumbnail + info
                _CardSummaryRow(booking: booking),

                const SizedBox(height: 12),

                // Payment section
                _PaymentSection(booking: booking),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Card header — ref + status badge ──────────────────────────────────────────
class _CardHeader extends StatelessWidget {
  const _CardHeader({required this.booking});
  final BookingModel booking;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Booking reference
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'BOOKING REF',
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF9AA0A6),
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '#${booking.reference}',
                style: const TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),

          // Status badge
          BookingStatusBadge(status: booking.status),
        ],
      ),
    );
  }
}

// ── Card summary row — thumbnail + hostel info ─────────────────────────────────
class _CardSummaryRow extends StatelessWidget {
  const _CardSummaryRow({required this.booking});
  final BookingModel booking;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Thumbnail
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: booking.hostelImageUrl != null
              ? Image.network(
                  booking.hostelImageUrl!,
                  width: 52,
                  height: 52,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _ThumbPlaceholder(),
                )
              : _ThumbPlaceholder(),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                booking.hostelName,
                style: const TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                booking.roomType,
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 11,
                  color: Color(0xFF5F6368),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '📅 ${booking.dateRangeLabel}',
                style: const TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.blueLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Thumbnail placeholder ──────────────────────────────────────────────────────
class _ThumbPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFFE8EAED),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Icon(
          Icons.apartment_outlined,
          size: 22,
          color: Color(0xFF9AA0A6),
        ),
      ),
    );
  }
}

// ── Payment section ────────────────────────────────────────────────────────────
class _PaymentSection extends StatelessWidget {
  const _PaymentSection({required this.booking});
  final BookingModel booking;

  @override
  Widget build(BuildContext context) {
    final isPending = booking.status == BookingStatus.pending;
    final isConfirmed = booking.status == BookingStatus.confirmed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Divider
        const Divider(height: 1, color: Color(0xFFF1F3F4)),
        const SizedBox(height: 10),

        if (isConfirmed) ...[
          // Progress bar
          _PaymentProgressBar(booking: booking),
          const SizedBox(height: 10),
          // Pay balance CTA
          _PayBalanceButton(booking: booking),
        ],

        if (isPending) ...[
          // Escrow notice
          _EscrowNotice(booking: booking),
        ],
      ],
    );
  }
}

// ── Payment progress bar ───────────────────────────────────────────────────────
class _PaymentProgressBar extends StatelessWidget {
  const _PaymentProgressBar({required this.booking});
  final BookingModel booking;

  @override
  Widget build(BuildContext context) {
    final paid = booking.commitmentFeePaid;
    final total = booking.totalAmount;
    final fraction = total > 0 ? paid / total : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Payment progress',
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFF5F6368),
              ),
            ),
            Text(
              'UGX ${_fmt(paid)} / ${_fmt(total)}',
              style: const TextStyle(
                fontFamily: 'Sora',
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.blueLight,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: fraction,
            minHeight: 7,
            backgroundColor: const Color(0xFFE8EAED),
            valueColor: const AlwaysStoppedAnimation(AppColors.blueLight),
          ),
        ),
      ],
    );
  }

  String _fmt(int v) => v.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]},',
  );
}

// ── Pay balance button ─────────────────────────────────────────────────────────
class _PayBalanceButton extends StatelessWidget {
  const _PayBalanceButton({required this.booking});
  final BookingModel booking;

  @override
  Widget build(BuildContext context) {
    final balance = booking.totalAmount - booking.commitmentFeePaid;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => context.push(AppRoutes.payment(booking.id)),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE53935),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        child: Text(
          'Pay Balance — UGX ${_fmt(balance)}',
          style: const TextStyle(
            fontFamily: 'Sora',
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  String _fmt(int v) => v.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]},',
  );
}

// ── Escrow notice (PENDING) ────────────────────────────────────────────────────
class _EscrowNotice extends StatelessWidget {
  const _EscrowNotice({required this.booking});
  final BookingModel booking;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: const Color(0xFFFFE082)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🔒', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Commitment fee in escrow',
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF795548),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'UGX ${_fmt(booking.commitmentFeePaid)} held safely. '
                  'Fully refundable within 48 hrs if you change your mind.',
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 10,
                    color: Color(0xFF9AA0A6),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(int v) => v.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]},',
  );
}

// ── Support link ───────────────────────────────────────────────────────────────
class _SupportLink extends StatelessWidget {
  const _SupportLink();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: GestureDetector(
          onTap: () {}, // wire to support chat / URL
          child: RichText(
            text: const TextSpan(
              style: TextStyle(fontFamily: 'Roboto', fontSize: 12),
              children: [
                TextSpan(
                  text: 'Need help? ',
                  style: TextStyle(color: Color(0xFF9AA0A6)),
                ),
                TextSpan(
                  text: 'Contact Support →',
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontWeight: FontWeight.w700,
                    color: AppColors.blueLight,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Empty state ────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.tab});
  final _BookingTab tab;

  @override
  Widget build(BuildContext context) {
    final config = _emptyConfig(tab);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(config.emoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(
              config.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Sora',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              config.subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontSize: 13,
                color: Color(0xFF9AA0A6),
                height: 1.5,
              ),
            ),
            if (tab == _BookingTab.active) ...[
              const SizedBox(height: 24),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.orangeBright, AppColors.orangePrimary],
                  ),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: ElevatedButton(
                  onPressed: () => context.go(AppRoutes.home),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 12,
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    '🔍 Find a Hostel',
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  _EmptyConfig _emptyConfig(_BookingTab tab) {
    switch (tab) {
      case _BookingTab.active:
        return const _EmptyConfig(
          emoji: '🏠',
          title: 'No active bookings yet',
          subtitle: 'Find and lock your perfect hostel room to get started.',
        );
      case _BookingTab.past:
        return const _EmptyConfig(
          emoji: '🏁',
          title: 'No past bookings',
          subtitle: 'Your completed stays will appear here.',
        );
      case _BookingTab.cancelled:
        return const _EmptyConfig(
          emoji: '😌',
          title: 'No cancellations',
          subtitle: 'Bookings you cancel will appear here.',
        );
    }
  }
}

class _EmptyConfig {
  const _EmptyConfig({
    required this.emoji,
    required this.title,
    required this.subtitle,
  });
  final String emoji, title, subtitle;
}

// ── Error body ─────────────────────────────────────────────────────────────────
class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('😕', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            const Text(
              'Could not load bookings',
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 16,
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
          ],
        ),
      ),
    );
  }
}

// ── Bottom nav ─────────────────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  const _BottomNav({
    required this.onHomeTap,
    required this.onExploreTap,
    required this.onProfileTap,
  });

  final VoidCallback onHomeTap;
  final VoidCallback onExploreTap;
  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
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
            children: [
              _NavTile(
                icon: Icons.home_outlined,
                label: 'Home',
                isActive: false,
                onTap: onHomeTap,
              ),
              _NavTile(
                icon: Icons.search,
                label: 'Explore',
                isActive: false,
                onTap: onExploreTap,
              ),
              _NavTile(
                icon: Icons.bookmark,
                label: 'Bookings',
                isActive: true,
                onTap: () {},
              ),
              _NavTile(
                icon: Icons.person_outline,
                label: 'Profile',
                isActive: false,
                onTap: onProfileTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isActive
                  ? AppColors.orangeBright
                  : const Color(0xFF9AA0A6),
            ),
            const SizedBox(height: 2),
            Text(
              label,
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
  }
}

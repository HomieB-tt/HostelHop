import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/app_theme.dart';
import '../../config/app_routes.dart';
import '../../models/booking_model.dart';
import '../../providers/booking_provider.dart';

class BookingConfirmationScreen extends ConsumerStatefulWidget {
  const BookingConfirmationScreen({super.key, required this.bookingId});
  final String bookingId;

  @override
  ConsumerState<BookingConfirmationScreen> createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState
    extends ConsumerState<BookingConfirmationScreen>
    with TickerProviderStateMixin {
  // ── Animations ─────────────────────────────────────────────────────────────
  late final AnimationController _checkController;
  late final AnimationController _contentController;

  late final Animation<double> _checkScale;
  late final Animation<double> _checkOpacity;
  late final Animation<double> _contentSlide;
  late final Animation<double> _contentOpacity;

  @override
  void initState() {
    super.initState();

    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _checkScale = CurvedAnimation(
      parent: _checkController,
      curve: Curves.elasticOut,
    );

    _checkOpacity = CurvedAnimation(
      parent: _checkController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
    );

    _contentSlide = Tween<double>(begin: 32, end: 0).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOut),
    );

    _contentOpacity = CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeIn,
    );

    // Stagger: checkmark first, then content
    _checkController.forward().then((_) {
      if (mounted) _contentController.forward();
    });
  }

  @override
  void dispose() {
    _checkController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookingAsync = ref.watch(bookingDetailProvider(widget.bookingId));

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        child: bookingAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.orangeBright),
          ),
          error: (e, _) => _ErrorBody(message: e.toString()),
          data: (booking) => SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 32, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ── Animated checkmark ─────────────────────────────
                  _AnimatedCheckmark(
                    scaleAnimation: _checkScale,
                    opacityAnimation: _checkOpacity,
                  ),

                  const SizedBox(height: 20),

                  // ── Heading ────────────────────────────────────────
                  AnimatedBuilder(
                    animation: _contentController,
                    builder: (_, child) => Opacity(
                      opacity: _contentOpacity.value,
                      child: Transform.translate(
                        offset: Offset(0, _contentSlide.value),
                        child: child,
                      ),
                    ),
                    child: _Heading(booking: booking),
                  ),

                  const SizedBox(height: 20),

                  // ── Booking summary card ───────────────────────────
                  AnimatedBuilder(
                    animation: _contentController,
                    builder: (_, child) => Opacity(
                      opacity: _contentOpacity.value,
                      child: Transform.translate(
                        offset: Offset(0, _contentSlide.value),
                        child: child,
                      ),
                    ),
                    child: _BookingSummaryCard(booking: booking),
                  ),

                  const SizedBox(height: 14),

                  // ── What happens next ──────────────────────────────
                  AnimatedBuilder(
                    animation: _contentController,
                    builder: (_, child) => Opacity(
                      opacity: _contentOpacity.value,
                      child: Transform.translate(
                        offset: Offset(0, _contentSlide.value),
                        child: child,
                      ),
                    ),
                    child: const _WhatHappensNext(),
                  ),

                  const SizedBox(height: 24),

                  // ── CTAs ───────────────────────────────────────────
                  AnimatedBuilder(
                    animation: _contentController,
                    builder: (_, child) => Opacity(
                      opacity: _contentOpacity.value,
                      child: Transform.translate(
                        offset: Offset(0, _contentSlide.value),
                        child: child,
                      ),
                    ),
                    child: _CtaButtons(booking: booking),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Animated checkmark ─────────────────────────────────────────────────────────
class _AnimatedCheckmark extends StatelessWidget {
  const _AnimatedCheckmark({
    required this.scaleAnimation,
    required this.opacityAnimation,
  });

  final Animation<double> scaleAnimation;
  final Animation<double> opacityAnimation;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: opacityAnimation,
      child: ScaleTransition(
        scale: scaleAnimation,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer glow ring
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF34A853).withOpacity(0.08),
              ),
            ),
            // Inner circle
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE8F5E9),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF34A853).withOpacity(0.25),
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Center(
                child: Text('✅', style: TextStyle(fontSize: 44)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Heading ────────────────────────────────────────────────────────────────────
class _Heading extends StatelessWidget {
  const _Heading({required this.booking});
  final BookingModel booking;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Room Locked! 🔒',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Sora',
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Your room at ${booking.hostelName} has been reserved. '
          'The hostel owner has been notified.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 13,
            color: Color(0xFF5F6368),
            height: 1.6,
          ),
        ),
      ],
    );
  }
}

// ── Booking summary card ───────────────────────────────────────────────────────
class _BookingSummaryCard extends StatelessWidget {
  const _BookingSummaryCard({required this.booking});
  final BookingModel booking;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8EAED)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header band
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.orangeBright, AppColors.orangePrimary],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'BOOKING CONFIRMED',
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 1.0,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: booking.reference));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'Reference copied!',
                          style: TextStyle(fontFamily: 'Sora', fontSize: 13),
                        ),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Text(
                        '#${booking.reference}',
                        style: const TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.copy, size: 12, color: Colors.white70),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Details rows
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                _DetailRow(label: 'Hostel', value: booking.hostelName),
                _DetailRow(label: 'Room Type', value: booking.roomType),
                _DetailRow(label: 'Period', value: booking.dateRangeLabel),
                _DetailRow(
                  label: 'Commitment Paid',
                  value: 'UGX ${_fmt(booking.commitmentFeeAmount)}',
                  valueColor: const Color(0xFF34A853),
                ),
                _DetailRow(
                  label: 'Balance Due',
                  value: 'UGX ${_fmt(booking.balanceDue)}',
                  valueColor: AppColors.orangeBright,
                  isLast: true,
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

// ── Detail row ─────────────────────────────────────────────────────────────────
class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor = const Color(0xFF1A1A2E),
    this.isLast = false,
  });

  final String label;
  final String value;
  final Color valueColor;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 12,
                  color: Color(0xFF5F6368),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ),
        if (!isLast) const Divider(height: 1, color: Color(0xFFF1F3F4)),
      ],
    );
  }
}

// ── What happens next ──────────────────────────────────────────────────────────
class _WhatHappensNext extends StatelessWidget {
  const _WhatHappensNext();

  @override
  Widget build(BuildContext context) {
    const steps = [
      _NextStep(
        emoji: '📱',
        title: 'Check your SMS',
        subtitle: 'A confirmation has been sent to your registered number.',
      ),
      _NextStep(
        emoji: '🏠',
        title: 'Contact the owner',
        subtitle:
            'The hostel owner will reach out within 24 hours to confirm move-in details.',
      ),
      _NextStep(
        emoji: '💰',
        title: 'Pay balance on arrival',
        subtitle:
            'Bring the remaining balance when you move in. Your room is held for 14 days.',
      ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8EAED)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What happens next?',
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 14),
          ...steps.asMap().entries.map((entry) {
            final isLast = entry.key == steps.length - 1;
            return _NextStepTile(step: entry.value, isLast: isLast);
          }),
        ],
      ),
    );
  }
}

class _NextStep {
  const _NextStep({
    required this.emoji,
    required this.title,
    required this.subtitle,
  });
  final String emoji, title, subtitle;
}

class _NextStepTile extends StatelessWidget {
  const _NextStepTile({required this.step, required this.isLast});
  final _NextStep step;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Emoji + connector line
        Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(step.emoji, style: const TextStyle(fontSize: 18)),
              ),
            ),
            if (!isLast)
              Container(
                width: 1.5,
                height: 28,
                color: const Color(0xFFE8EAED),
                margin: const EdgeInsets.symmetric(vertical: 3),
              ),
          ],
        ),

        const SizedBox(width: 12),

        // Text
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: const TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  step.subtitle,
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 11,
                    color: Color(0xFF5F6368),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── CTA buttons ────────────────────────────────────────────────────────────────
class _CtaButtons extends StatelessWidget {
  const _CtaButtons({required this.booking});
  final BookingModel booking;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Primary — View My Bookings
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.orangeBright, AppColors.orangePrimary],
            ),
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: AppColors.orangeBright.withOpacity(0.35),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () => context.go(AppRoutes.myBookings),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 52),
              shape: const StadiumBorder(),
              elevation: 0,
            ),
            child: const Text(
              '📋 View My Bookings',
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Secondary — Back to Home
        OutlinedButton(
          onPressed: () => context.go(AppRoutes.home),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF5F6368),
            side: const BorderSide(color: Color(0xFFE8EAED)),
            minimumSize: const Size(double.infinity, 52),
            shape: const StadiumBorder(),
          ),
          child: const Text(
            '🏠 Back to Home',
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
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
              'Could not load confirmation',
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
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () => context.go(AppRoutes.home),
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
                '🏠 Go Home',
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/app_theme.dart';
import '../../config/app_routes.dart';
import '../../models/hostel_model.dart';
import '../../providers/hostel_provider.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/booking/booking_summary_card.dart';
import '../../widgets/booking/booking_step_indicator.dart';
import '../../widgets/booking/date_range_picker.dart';

class BookingScreen extends ConsumerStatefulWidget {
  const BookingScreen({super.key, required this.hostelId});
  final String hostelId;

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  bool _isLoading = false;

  // Date state — driven by DateRangePicker
  DateTime? _checkIn;
  DateTime? _checkOut;

  @override
  void initState() {
    super.initState();
    // Default to semester 1 dates
    _checkIn = DateTime(DateTime.now().year, 2, 1);
    _checkOut = DateTime(DateTime.now().year, 7, 31);
  }

  Future<void> _onLockRoom(HostelModel hostel) async {
    if (_checkIn == null || _checkOut == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select check-in and check-out dates.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final bookingId = await ref
          .read(bookingProvider.notifier)
          .createBooking(
            hostelId: hostel.id,
            hostelName: hostel.name,
            roomId: '',
            roomType: hostel.primaryRoomType,
            totalAmount: hostel.pricePerSemester,
            commitmentFee: hostel.commitmentFee,
            moveInDate: _checkIn!,
            moveOutDate: _checkOut!,
          );
      if (mounted) context.push(AppRoutes.payment(bookingId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString(),
              style: const TextStyle(fontFamily: 'Sora', fontSize: 13),
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hostelAsync = ref.watch(hostelDetailProvider(widget.hostelId));

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        child: hostelAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.orangeBright),
          ),
          error: (e, _) => _ErrorBody(message: e.toString()),
          data: (hostel) => SafeArea(
            child: Column(
              children: [
                // ── Top bar ──────────────────────────────────────────
                _TopBar(onBack: () => context.pop(), hostel: hostel),

                // ── Step indicator ───────────────────────────────────
                const BookingStepIndicator(currentStep: BookingStep.details),

                // ── Scrollable content ───────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Hostel summary card
                        _HostelSummaryCard(hostel: hostel),

                        const SizedBox(height: 16),

                        // Date range picker
                        const Text(
                          'Select Dates',
                          style: TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(height: 10),
                        DateRangePicker(
                          checkIn: _checkIn,
                          checkOut: _checkOut,
                          onChanged: (checkIn, checkOut) {
                            setState(() {
                              _checkIn = checkIn;
                              _checkOut = checkOut;
                            });
                          },
                        ),

                        const SizedBox(height: 16),

                        // Booking summary card
                        BookingSummaryCard(
                          hostelName: hostel.name,
                          roomType: hostel.primaryRoomType,
                          checkIn:
                              _checkIn ?? DateTime(DateTime.now().year, 2, 1),
                          checkOut:
                              _checkOut ?? DateTime(DateTime.now().year, 7, 31),
                          totalAmount: hostel.pricePerSemester,
                          commitmentFee: hostel.commitmentFee,
                          location: hostel.location,
                        ),

                        const SizedBox(height: 12),

                        // Dark commitment fee card
                        _CommitmentFeeCard(hostel: hostel),

                        const SizedBox(height: 12),

                        // Campus Life Guarantee banner
                        const _GuaranteeBanner(),

                        const SizedBox(height: 20),

                        // Lock Room CTA
                        _LockRoomButton(
                          hostel: hostel,
                          isLoading: _isLoading,
                          onTap: () => _onLockRoom(hostel),
                        ),
                      ],
                    ),
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

// ── Top bar ────────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  const _TopBar({required this.onBack, required this.hostel});
  final VoidCallback onBack;
  final HostelModel hostel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE8EAED))),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F3F4),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE8EAED)),
              ),
              child: const Center(
                child: Text('←', style: TextStyle(fontSize: 16)),
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                const Text(
                  '🔒 Lock My Room',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${hostel.name} — Pay commitment fee to reserve',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 11,
                    color: Color(0xFF5F6368),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Balance spacer
          const SizedBox(width: 36),
        ],
      ),
    );
  }
}

// ── Hostel summary card ────────────────────────────────────────────────────────
class _HostelSummaryCard extends StatelessWidget {
  const _HostelSummaryCard({required this.hostel});
  final HostelModel hostel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE8EAED)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: hostel.imageUrls.isNotEmpty
                ? Image.network(
                    hostel.imageUrls.first,
                    width: 52,
                    height: 52,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _ThumbPlaceholder(),
                  )
                : _ThumbPlaceholder(),
          ),

          const SizedBox(width: 10),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hostel.name,
                  style: const TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Room Type: ${hostel.primaryRoomType}',
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 11,
                    color: Color(0xFF5F6368),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '📅 ${hostel.semesterLabel}',
                  style: TextStyle(
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
      ),
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
          size: 24,
          color: Color(0xFF9AA0A6),
        ),
      ),
    );
  }
}

// ── Dark commitment fee card ───────────────────────────────────────────────────
class _CommitmentFeeCard extends StatelessWidget {
  const _CommitmentFeeCard({required this.hostel});
  final HostelModel hostel;

  @override
  Widget build(BuildContext context) {
    final balance = hostel.pricePerSemester - hostel.commitmentFee;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A1628), Color(0xFF0D2137)],
        ),
      ),
      child: Stack(
        children: [
          // Radial glow
          Positioned(
            top: -30,
            right: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.blueLight.withOpacity(0.30),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Label
              const Text(
                'COMMITMENT FEE',
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: Colors.white54,
                  letterSpacing: 1.5,
                ),
              ),

              const SizedBox(height: 4),

              // Amount
              Text(
                'UGX ${_formatPrice(hostel.commitmentFee)}',
                style: const TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1,
                ),
              ),

              const SizedBox(height: 10),

              // Description
              Text(
                'Pay this now to secure your room. The remaining '
                'balance of UGX ${_formatPrice(balance)} is due when you move in.',
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 10,
                  color: Colors.white54,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 14),

              // Hold notice
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 30,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.blueLight.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text('🔒', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 11,
                          color: Colors.white70,
                          height: 1.4,
                        ),
                        children: [
                          TextSpan(text: 'Your room is held for '),
                          TextSpan(
                            text: '14 days',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF64B5F6),
                            ),
                          ),
                          TextSpan(
                            text:
                                ' after payment.\nFully refundable within 48 hrs.',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatPrice(int price) => price.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]},',
  );
}

// ── Price breakdown table ──────────────────────────────────────────────────────
class _PriceBreakdownTable extends StatelessWidget {
  const _PriceBreakdownTable({required this.hostel});
  final HostelModel hostel;

  @override
  Widget build(BuildContext context) {
    final balance = hostel.pricePerSemester - hostel.commitmentFee;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE8EAED)),
      ),
      child: Column(
        children: [
          _BreakdownRow(
            label: 'Monthly Rent',
            value: 'UGX ${_formatPrice(hostel.pricePerSemester)}',
            valueStyle: _defaultValueStyle,
            isFirst: true,
          ),
          _BreakdownRow(
            label: 'Duration',
            value: hostel.durationLabel,
            valueStyle: _defaultValueStyle,
          ),
          _BreakdownRow(
            label: 'Commitment Fee (Now)',
            value: 'UGX ${_formatPrice(hostel.commitmentFee)}',
            valueStyle: TextStyle(
              fontFamily: 'Sora',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.blueLight,
            ),
          ),
          _BreakdownRow(
            label: 'Balance on Move-In',
            value: 'UGX ${_formatPrice(balance)}',
            valueStyle: const TextStyle(
              fontFamily: 'Sora',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.orangeBright,
            ),
            isLast: true,
          ),
        ],
      ),
    );
  }

  static const TextStyle _defaultValueStyle = TextStyle(
    fontFamily: 'Sora',
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: Color(0xFF1A1A2E),
  );

  String _formatPrice(int price) => price.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]},',
  );
}

// ── Breakdown row ──────────────────────────────────────────────────────────────
class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({
    required this.label,
    required this.value,
    required this.valueStyle,
    this.isFirst = false,
    this.isLast = false,
  });

  final String label;
  final String value;
  final TextStyle valueStyle;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: Color(0xFFE8EAED))),
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(10) : Radius.zero,
          bottom: isLast ? const Radius.circular(10) : Radius.zero,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 11,
              color: Color(0xFF5F6368),
            ),
          ),
          Text(value, style: valueStyle),
        ],
      ),
    );
  }
}

// ── Campus Life Guarantee banner ───────────────────────────────────────────────
class _GuaranteeBanner extends StatelessWidget {
  const _GuaranteeBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.orangeBright.withOpacity(0.30)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🛡️', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Protected by Campus Life Guarantee. If the hostel '
              'doesn\'t match the listing, you get a full refund.',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 10,
                color: AppColors.blueDark,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Lock Room button ───────────────────────────────────────────────────────────
class _LockRoomButton extends StatelessWidget {
  const _LockRoomButton({
    required this.hostel,
    required this.isLoading,
    required this.onTap,
  });

  final HostelModel hostel;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.blueLight, AppColors.blueDark],
        ),
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: AppColors.blueLight.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: const StadiumBorder(),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            : Text(
                '🔒 Pay UGX ${_formatPrice(hostel.commitmentFee)} — Lock Room',
                style: const TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }

  String _formatPrice(int price) => price.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]},',
  );
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
              'Could not load booking details',
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
              onPressed: () => context.pop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.blueLight,
                side: BorderSide(color: AppColors.blueLight),
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
    );
  }
}

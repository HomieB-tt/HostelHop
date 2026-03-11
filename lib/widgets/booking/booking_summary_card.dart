import 'package:flutter/material.dart';

import '../../../config/app_theme.dart';
import '../../../models/booking_model.dart';
import '../../../utils/date_helpers.dart';
import '../../../utils/price_formatter.dart';

/// A read-only summary card showing key booking details.
/// Used on the booking screen (review step), payment screen,
/// and booking confirmation screen.
///
/// Usage:
///   BookingSummaryCard(booking: booking)
///
/// Or from raw values before a booking is created:
///   BookingSummaryCard.preview(
///     hostelName: 'Sunrise Hostel',
///     roomType: 'Single',
///     checkIn: DateTime(...),
///     checkOut: DateTime(...),
///     totalAmount: 1200000,
///     commitmentFee: 300000,
///   )
class BookingSummaryCard extends StatelessWidget {
  const BookingSummaryCard({
    super.key,
    required this.hostelName,
    required this.roomType,
    required this.checkIn,
    required this.checkOut,
    required this.totalAmount,
    required this.commitmentFee,
    this.bookingReference,
    this.location,
  });

  factory BookingSummaryCard.fromBooking(BookingModel booking) {
    return BookingSummaryCard(
      hostelName: booking.hostelName,
      roomType: booking.roomType,
      checkIn: booking.checkInDate,
      checkOut: booking.checkOutDate,
      totalAmount: booking.totalAmount,
      commitmentFee: booking.commitmentFeeAmount,
      bookingReference: booking.reference,
    );
  }

  final String hostelName;
  final String roomType;
  final DateTime checkIn;
  final DateTime checkOut;
  final int totalAmount;
  final int commitmentFee;
  final String? bookingReference;
  final String? location;

  int get _balance => totalAmount - commitmentFee;

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
          // ── Header ──────────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: const BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.orangeBright.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.apartment_rounded,
                    size: 18,
                    color: AppColors.orangeBright,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hostelName,
                        style: const TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimaryLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (location != null) ...[
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 11,
                              color: AppColors.textHintLight,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              location!,
                              style: const TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 11,
                                color: AppColors.textHintLight,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.borderLight),

          // ── Details ──────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                _Row(
                  icon: Icons.bed_outlined,
                  label: 'Room Type',
                  value: roomType,
                ),
                const SizedBox(height: 10),
                _Row(
                  icon: Icons.calendar_today_outlined,
                  label: 'Check-in',
                  value: DateHelpers.formatFull(checkIn),
                ),
                const SizedBox(height: 10),
                _Row(
                  icon: Icons.calendar_today_outlined,
                  label: 'Check-out',
                  value: DateHelpers.formatFull(checkOut),
                ),
                const SizedBox(height: 10),
                _Row(
                  icon: Icons.timelapse_outlined,
                  label: 'Duration',
                  value: DateHelpers.durationLabel(checkIn, checkOut),
                ),
                if (bookingReference != null) ...[
                  const SizedBox(height: 10),
                  _Row(
                    icon: Icons.confirmation_number_outlined,
                    label: 'Reference',
                    value: bookingReference!,
                    valueStyle: const TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.orangeBright,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.borderLight),

          // ── Price breakdown ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                _PriceRow(
                  label: 'Total Amount',
                  value: PriceFormatter.format(totalAmount),
                ),
                const SizedBox(height: 6),
                _PriceRow(
                  label: 'Commitment Fee',
                  value: PriceFormatter.format(commitmentFee),
                  valueColor: AppColors.success,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(height: 1, color: AppColors.borderLight),
                ),
                _PriceRow(
                  label: 'Balance Due',
                  value: PriceFormatter.format(_balance),
                  labelBold: true,
                  valueBold: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Detail row ─────────────────────────────────────────────────────────────────
class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.label,
    required this.value,
    this.valueStyle,
  });

  final IconData icon;
  final String label;
  final String value;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textHintLight),
        const SizedBox(width: 8),
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 12,
              color: AppColors.textHintLight,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style:
                valueStyle ??
                const TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimaryLight,
                ),
          ),
        ),
      ],
    );
  }
}

// ── Price row ──────────────────────────────────────────────────────────────────
class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.value,
    this.labelBold = false,
    this.valueBold = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool labelBold;
  final bool valueBold;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Sora',
            fontSize: 12,
            fontWeight: labelBold ? FontWeight.w700 : FontWeight.w500,
            color: AppColors.textSecondaryLight,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Sora',
            fontSize: 13,
            fontWeight: valueBold ? FontWeight.w800 : FontWeight.w600,
            color: valueColor ?? AppColors.textPrimaryLight,
          ),
        ),
      ],
    );
  }
}

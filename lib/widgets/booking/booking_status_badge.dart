import 'package:flutter/material.dart';

import '../../../models/booking_model.dart';

/// Status badge pill for a booking.
/// Extracted from my_bookings_screen — now shared with
/// booking_confirmation_screen and owner manage_bookings_screen.
///
///   BookingStatusBadge(status: booking.status)
class BookingStatusBadge extends StatelessWidget {
  const BookingStatusBadge({
    super.key,
    required this.status,
  });

  final BookingStatus status;

  @override
  Widget build(BuildContext context) {
    final cfg = _config(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: cfg.bg,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: cfg.border),
      ),
      child: Text(
        cfg.label,
        style: TextStyle(
          fontFamily: 'Sora',
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: cfg.text,
        ),
      ),
    );
  }

  _BadgeConfig _config(BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed:
        return const _BadgeConfig(
          label: '✅ CONFIRMED',
          bg: Color(0xFFE8F5E9),
          border: Color(0xFFA5D6A7),
          text: Color(0xFF2E7D32),
        );
      case BookingStatus.pending:
        return const _BadgeConfig(
          label: '⏳ PENDING',
          bg: Color(0xFFFFF8E1),
          border: Color(0xFFFFE082),
          text: Color(0xFF795548),
        );
      case BookingStatus.completed:
        return const _BadgeConfig(
          label: '🏁 COMPLETED',
          bg: Color(0xFFF5F5F5),
          border: Color(0xFFBDBDBD),
          text: Color(0xFF757575),
        );
      case BookingStatus.cancelled:
        return const _BadgeConfig(
          label: '❌ CANCELLED',
          bg: Color(0xFFFFEBEE),
          border: Color(0xFFEF9A9A),
          text: Color(0xFFB71C1C),
        );
    }
  }
}

class _BadgeConfig {
  const _BadgeConfig({
    required this.label,
    required this.bg,
    required this.border,
    required this.text,
  });
  final String label;
  final Color bg;
  final Color border;
  final Color text;
}

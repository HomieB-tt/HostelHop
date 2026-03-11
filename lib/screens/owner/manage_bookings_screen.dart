import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/app_theme.dart';
import '../../models/booking_model.dart';
import '../../repositories/booking_repository.dart';
import '../../utils/date_helpers.dart';
import '../../utils/price_formatter.dart';
import '../../widgets/booking/booking_status_badge.dart';
import '../../widgets/common/app_empty_state.dart';
import '../../widgets/common/app_error_widget.dart';
import '../../widgets/common/app_loading_indicator.dart';

/// Owner view of all bookings for a specific hostel.
/// Receives [hostelId] via GoRouter `extra`.
///
/// Route: AppRoutes.manageBookings
/// Extra: String hostelId
class ManageBookingsScreen extends ConsumerStatefulWidget {
  const ManageBookingsScreen({super.key, required this.hostelId});

  final String hostelId;

  @override
  ConsumerState<ManageBookingsScreen> createState() =>
      _ManageBookingsScreenState();
}

class _ManageBookingsScreenState extends ConsumerState<ManageBookingsScreen> {
  List<BookingModel> _all = [];
  bool _isLoading = true;
  String? _error;
  BookingStatus? _filter; // null = show all

  List<BookingModel> get _filtered =>
      _filter == null ? _all : _all.where((b) => b.status == _filter).toList();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final bookings = await const BookingRepository().fetchByHostel(
        widget.hostelId,
      );
      // Most recent first
      bookings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      setState(() => _all = bookings);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _confirm(BookingModel booking) async {
    try {
      await const BookingRepository().updateStatus(
        booking.id,
        BookingStatus.confirmed,
      );
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking confirmed ✅'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _cancel(BookingModel booking) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          'Cancel Booking?',
          style: TextStyle(fontFamily: 'Sora', fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Cancel booking ${booking.reference}? This cannot be undone.',
          style: const TextStyle(fontFamily: 'Roboto'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await const BookingRepository().cancel(booking.id);
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Bookings',
          style: TextStyle(
            fontFamily: 'Sora',
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimaryLight,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(49),
          child: Column(
            children: [
              const Divider(height: 1, color: AppColors.borderLight),
              _FilterBar(
                current: _filter,
                onChanged: (f) => setState(() => _filter = f),
              ),
            ],
          ),
        ),
      ),
      body: _isLoading
          ? const AppLoadingScreen()
          : _error != null
          ? AppErrorWidget(message: _error!, onRetry: _load)
          : _filtered.isEmpty
          ? AppEmptyState(
              emoji: '📋',
              title: _filter == null
                  ? 'No bookings yet'
                  : 'No ${_filter!.value} bookings',
              subtitle: 'Bookings will appear here once students book.',
            )
          : RefreshIndicator(
              onRefresh: _load,
              color: AppColors.orangeBright,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _BookingCard(
                  booking: _filtered[i],
                  onConfirm: _filtered[i].isPending
                      ? () => _confirm(_filtered[i])
                      : null,
                  onCancel: (_filtered[i].isPending || _filtered[i].isConfirmed)
                      ? () => _cancel(_filtered[i])
                      : null,
                ),
              ),
            ),
    );
  }
}

// ── Filter bar ─────────────────────────────────────────────────────────────────
class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.current, required this.onChanged});

  final BookingStatus? current;
  final void Function(BookingStatus?) onChanged;

  @override
  Widget build(BuildContext context) {
    final filters = <BookingStatus?>[
      null,
      BookingStatus.pending,
      BookingStatus.confirmed,
      BookingStatus.completed,
      BookingStatus.cancelled,
    ];
    final labels = {
      null: 'All',
      BookingStatus.pending: 'Pending',
      BookingStatus.confirmed: 'Confirmed',
      BookingStatus.completed: 'Completed',
      BookingStatus.cancelled: 'Cancelled',
    };

    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: filters.map((f) {
          final isActive = current == f;
          return GestureDetector(
            onTap: () => onChanged(f),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isActive ? AppColors.orangeBright : Colors.white,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  color: isActive
                      ? AppColors.orangeBright
                      : AppColors.borderLight,
                ),
              ),
              child: Center(
                child: Text(
                  labels[f]!,
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isActive
                        ? Colors.white
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Booking card ───────────────────────────────────────────────────────────────
class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.booking, this.onConfirm, this.onCancel});

  final BookingModel booking;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Row(
              children: [
                // Reference
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'BOOKING REF',
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textHintLight,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      booking.reference,
                      style: const TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.orangeBright,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                BookingStatusBadge(status: booking.status),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.borderLight),

          // ── Body ─────────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                _InfoRow(
                  icon: Icons.person_outline_rounded,
                  label: 'Student',
                  value: booking.userId,
                ),
                const SizedBox(height: 8),
                _InfoRow(
                  icon: Icons.bed_outlined,
                  label: 'Room Type',
                  value: booking.roomType,
                ),
                const SizedBox(height: 8),
                _InfoRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Dates',
                  value: booking.dateRangeLabel,
                ),
                const SizedBox(height: 8),
                _InfoRow(
                  icon: Icons.payments_outlined,
                  label: 'Total',
                  value: PriceFormatter.format(booking.totalAmount),
                ),
                const SizedBox(height: 8),
                _InfoRow(
                  icon: Icons.check_circle_outline_rounded,
                  label: 'Commitment',
                  value: PriceFormatter.format(booking.commitmentFeePaid),
                  valueColor: booking.commitmentFeePaid > 0
                      ? AppColors.success
                      : AppColors.textHintLight,
                ),
                const SizedBox(height: 8),
                _InfoRow(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Balance',
                  value: PriceFormatter.format(booking.balanceDue),
                  valueColor: booking.isFullyPaid
                      ? AppColors.success
                      : AppColors.warning,
                ),
                const SizedBox(height: 8),
                _InfoRow(
                  icon: Icons.access_time_rounded,
                  label: 'Booked',
                  value: DateHelpers.timeAgo(booking.createdAt),
                ),
              ],
            ),
          ),

          // ── Actions ──────────────────────────────────────────────────────────
          if (onConfirm != null || onCancel != null) ...[
            const Divider(height: 1, color: AppColors.borderLight),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  if (onCancel != null)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onCancel,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  if (onConfirm != null && onCancel != null)
                    const SizedBox(width: 10),
                  if (onConfirm != null)
                    Expanded(
                      child: FilledButton(
                        onPressed: onConfirm,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.success,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Confirm',
                          style: TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Info row ───────────────────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textHintLight),
        const SizedBox(width: 8),
        SizedBox(
          width: 85,
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
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.textPrimaryLight,
            ),
          ),
        ),
      ],
    );
  }
}

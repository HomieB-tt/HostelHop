import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/app_theme.dart';
import '../../config/app_routes.dart';
import '../../providers/booking_provider.dart';
import '../../models/booking_model.dart';
import '../../widgets/booking/booking_step_indicator.dart';

// ── Mobile money providers ─────────────────────────────────────────────────────
enum _MobileMoneyProvider { mtn, airtel }

extension _MobileMoneyProviderX on _MobileMoneyProvider {
  String get label {
    switch (this) {
      case _MobileMoneyProvider.mtn:
        return 'MTN Mobile Money';
      case _MobileMoneyProvider.airtel:
        return 'Airtel Money';
    }
  }

  String get shortLabel {
    switch (this) {
      case _MobileMoneyProvider.mtn:
        return 'MTN';
      case _MobileMoneyProvider.airtel:
        return 'Airtel';
    }
  }

  // Placeholder emoji icons — to be replaced with official brand assets
  String get emoji {
    switch (this) {
      case _MobileMoneyProvider.mtn:
        return '📲';
      case _MobileMoneyProvider.airtel:
        return '📶';
    }
  }

  Color get brandColor {
    switch (this) {
      case _MobileMoneyProvider.mtn:
        return const Color(0xFFFFCC00); // MTN yellow
      case _MobileMoneyProvider.airtel:
        return const Color(0xFFE53935); // Airtel red
    }
  }
}

// ── Screen ─────────────────────────────────────────────────────────────────────
class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key, required this.bookingId});
  final String bookingId;

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  _MobileMoneyProvider _selectedProvider = _MobileMoneyProvider.mtn;
  final _phoneController = TextEditingController();
  final _phoneFocus = FocusNode();
  bool _phoneHasFocus = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _phoneFocus.addListener(
      () => setState(() => _phoneHasFocus = _phoneFocus.hasFocus),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

  // ── Submit ─────────────────────────────────────────────────────────────────
  Future<void> _onPay(BookingModel booking) async {
    FocusScope.of(context).unfocus();

    final phone = _phoneController.text.trim();
    if (phone.isEmpty || phone.length < 9) {
      _showError('Please enter a valid mobile money number.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref
          .read(bookingProvider.notifier)
          .initiatePayment(
            bookingId: booking.id,
            phone: '+256$phone',
            provider: _selectedProvider.shortLabel,
          );
      if (mounted) {
        context.pushReplacement(AppRoutes.bookingConfirmation(booking.id));
      }
    } catch (e) {
      if (mounted) _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'Sora', fontSize: 13),
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────
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
            child: Column(
              children: [
                // ── Top bar ──────────────────────────────────────────
                _TopBar(onBack: () => context.pop()),

                // ── Step indicator ───────────────────────────────────
                const BookingStepIndicator(currentStep: BookingStep.payment),

                // ── Scrollable content ───────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Amount due card
                        _AmountDueCard(booking: booking),

                        const SizedBox(height: 20),

                        // Provider label
                        const _SectionLabel(label: 'SELECT PROVIDER'),
                        const SizedBox(height: 10),

                        // Provider selector
                        _ProviderSelector(
                          selected: _selectedProvider,
                          onSelect: (p) =>
                              setState(() => _selectedProvider = p),
                        ),

                        const SizedBox(height: 20),

                        // Phone label
                        const _SectionLabel(label: 'MOBILE MONEY NUMBER'),
                        const SizedBox(height: 4),
                        Text(
                          'Enter the number registered with '
                          '${_selectedProvider.shortLabel}',
                          style: const TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 11,
                            color: Color(0xFF9AA0A6),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Phone input
                        _PhoneInput(
                          controller: _phoneController,
                          focusNode: _phoneFocus,
                          hasFocus: _phoneHasFocus,
                        ),

                        const SizedBox(height: 12),

                        // Prompt helper
                        const _PromptHelperNote(),

                        const SizedBox(height: 20),

                        // SSL note
                        const _SslNote(),

                        const SizedBox(height: 24),

                        // Pay CTA
                        _PayNowButton(
                          booking: booking,
                          isLoading: _isLoading,
                          onTap: () => _onPay(booking),
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
  const _TopBar({required this.onBack});
  final VoidCallback onBack;

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
          const Expanded(
            child: Text(
              'Secure Payment',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A2E),
              ),
            ),
          ),
          // Balance spacer
          const SizedBox(width: 36),
        ],
      ),
    );
  }
}

// ── Amount due card ────────────────────────────────────────────────────────────
class _AmountDueCard extends StatelessWidget {
  const _AmountDueCard({required this.booking});
  final BookingModel booking;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8EAED)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'AMOUNT DUE NOW',
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF9AA0A6),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'UGX ${_fmt(booking.commitmentFeePaid == 0 ? booking.commitmentFeeAmount : booking.balanceDue)}',
            style: const TextStyle(
              fontFamily: 'Sora',
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1A2E),
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Text(
              booking.hostelName,
              style: const TextStyle(
                fontFamily: 'Sora',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.orangeBright,
              ),
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

// ── Section label ──────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontFamily: 'Sora',
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: Color(0xFF5F6368),
        letterSpacing: 0.8,
      ),
    );
  }
}

// ── Provider selector ──────────────────────────────────────────────────────────
class _ProviderSelector extends StatelessWidget {
  const _ProviderSelector({required this.selected, required this.onSelect});

  final _MobileMoneyProvider selected;
  final ValueChanged<_MobileMoneyProvider> onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _MobileMoneyProvider.values.map((provider) {
        final isSelected = provider == selected;
        return Expanded(
          child: GestureDetector(
            onTap: () => onSelect(provider),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(
                right: provider == _MobileMoneyProvider.mtn ? 8 : 0,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.blueLight.withValues(alpha: 0.06)
                    : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected
                      ? AppColors.blueLight
                      : const Color(0xFFE8EAED),
                  width: isSelected ? 1.5 : 1.0,
                ),
              ),
              child: Row(
                children: [
                  // Brand icon container — placeholder emoji
                  // TODO: replace with Image.asset('<brand>.png')
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: provider.brandColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        provider.emoji,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          provider.shortLabel,
                          style: TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? AppColors.blueLight
                                : const Color(0xFF1A1A2E),
                          ),
                        ),
                        const Text(
                          'Mobile Money',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 9,
                            color: Color(0xFF9AA0A6),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Selection indicator
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? AppColors.blueLight
                          : Colors.transparent,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.blueLight
                            : const Color(0xFFE8EAED),
                        width: 1.5,
                      ),
                    ),
                    child: isSelected
                        ? const Center(
                            child: Icon(
                              Icons.check,
                              size: 10,
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Phone input ────────────────────────────────────────────────────────────────
class _PhoneInput extends StatelessWidget {
  const _PhoneInput({
    required this.controller,
    required this.focusNode,
    required this.hasFocus,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasFocus;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: hasFocus ? AppColors.orangeBright : const Color(0xFFE8EAED),
          width: hasFocus ? 1.5 : 1.0,
        ),
        boxShadow: hasFocus
            ? [
                BoxShadow(
                  color: AppColors.orangeBright.withValues(alpha: 0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: Row(
        children: [
          // +256 prefix
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: const BoxDecoration(
              border: Border(right: BorderSide(color: Color(0xFFE8EAED))),
            ),
            child: const Row(
              children: [
                Text('🇺🇬', style: TextStyle(fontSize: 16)),
                SizedBox(width: 6),
                Text(
                  '+256',
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF5F6368),
                  ),
                ),
              ],
            ),
          ),

          // Number input
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontSize: 14,
                color: Color(0xFF1A1A2E),
              ),
              decoration: const InputDecoration(
                hintText: '7XX XXX XXX',
                hintStyle: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14,
                  color: Color(0xFF9AA0A6),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Prompt helper note ─────────────────────────────────────────────────────────
class _PromptHelperNote extends StatelessWidget {
  const _PromptHelperNote();

  @override
  Widget build(BuildContext context) {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('ℹ️', style: TextStyle(fontSize: 13)),
        SizedBox(width: 7),
        Expanded(
          child: Text(
            'You\'ll receive a payment prompt on your phone. '
            'Enter your PIN to complete the transaction.',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 11,
              color: Color(0xFF5F6368),
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

// ── SSL note ───────────────────────────────────────────────────────────────────
class _SslNote extends StatelessWidget {
  const _SslNote();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock_outline, size: 12, color: Colors.grey.shade400),
          const SizedBox(width: 5),
          Text(
            '256-bit SSL · PCI-DSS compliant',
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade400,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Pay Now button ─────────────────────────────────────────────────────────────
class _PayNowButton extends StatelessWidget {
  const _PayNowButton({
    required this.booking,
    required this.isLoading,
    required this.onTap,
  });

  final BookingModel booking;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final amount = booking.commitmentFeePaid == 0
        ? booking.commitmentFeeAmount
        : booking.balanceDue;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.orangeBright, AppColors.orangePrimary],
        ),
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: AppColors.orangeBright.withValues(alpha: 0.40),
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
          minimumSize: const Size(double.infinity, 54),
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
                '💳 Pay UGX ${_fmt(amount)} Now',
                style: const TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 15,
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
              'Could not load payment details',
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
    );
  }
}

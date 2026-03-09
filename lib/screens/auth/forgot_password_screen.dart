import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';

// ── Screen states ──────────────────────────────────────────────────────────────
enum _ForgotPasswordState { idle, loading, success }

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _phoneFocus = FocusNode();

  bool _phoneHasFocus = false;
  _ForgotPasswordState _screenState = _ForgotPasswordState.idle;

  // Success checkmark animation
  late final AnimationController _successController;
  late final Animation<double> _successScale;

  @override
  void initState() {
    super.initState();

    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _successScale = CurvedAnimation(
      parent: _successController,
      curve: Curves.elasticOut,
    );

    _phoneFocus.addListener(
      () => setState(() => _phoneHasFocus = _phoneFocus.hasFocus),
    );
  }

  @override
  void dispose() {
    _successController.dispose();
    _phoneController.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

  // ── Submit ─────────────────────────────────────────────────────────────────
  Future<void> _onSendReset() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _screenState = _ForgotPasswordState.loading);

    try {
      await ref
          .read(authProvider.notifier)
          .sendPasswordReset(phone: '+256${_phoneController.text.trim()}');
      if (mounted) {
        setState(() => _screenState = _ForgotPasswordState.success);
        _successController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _screenState = _ForgotPasswordState.idle);
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
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      resizeToAvoidBottomInset: true,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Top bar ────────────────────────────────────────────────
              _TopBar(onBack: () => context.pop()),

              // ── Content ────────────────────────────────────────────────
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  child: _screenState == _ForgotPasswordState.success
                      ? _SuccessView(
                          key: const ValueKey('success'),
                          scaleAnimation: _successScale,
                          phone: _phoneController.text.trim(),
                          onBack: () => context.pop(),
                        )
                      : _IdleView(
                          key: const ValueKey('idle'),
                          formKey: _formKey,
                          phoneController: _phoneController,
                          phoneFocus: _phoneFocus,
                          phoneHasFocus: _phoneHasFocus,
                          isLoading:
                              _screenState == _ForgotPasswordState.loading,
                          onSend: _onSendReset,
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
              'Forgot Password',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 15,
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

// ── Idle / form view ───────────────────────────────────────────────────────────
class _IdleView extends StatelessWidget {
  const _IdleView({
    super.key,
    required this.formKey,
    required this.phoneController,
    required this.phoneFocus,
    required this.phoneHasFocus,
    required this.isLoading,
    required this.onSend,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController phoneController;
  final FocusNode phoneFocus;
  final bool phoneHasFocus;
  final bool isLoading;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 32),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Illustration
            Center(
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.orangeBright.withOpacity(0.20),
                      blurRadius: 24,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('🔑', style: TextStyle(fontSize: 40)),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Heading
            const Text(
              'Reset your password',
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Enter the phone number linked to your account. We\'ll send you a reset link via SMS.',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 13,
                color: Color(0xFF5F6368),
                height: 1.6,
              ),
            ),

            const SizedBox(height: 32),

            // Phone field label
            const Text(
              'PHONE NUMBER',
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFF5F6368),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),

            // Phone field
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: phoneHasFocus
                      ? AppColors.orangeBright
                      : const Color(0xFFE8EAED),
                  width: phoneHasFocus ? 1.5 : 1.0,
                ),
                boxShadow: phoneHasFocus
                    ? [
                        BoxShadow(
                          color: AppColors.orangeBright.withOpacity(0.12),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                    decoration: const BoxDecoration(
                      border: Border(
                        right: BorderSide(color: Color(0xFFE8EAED)),
                      ),
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
                  Expanded(
                    child: TextFormField(
                      controller: phoneController,
                      focusNode: phoneFocus,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => onSend(),
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
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Please enter your phone number';
                        }
                        if (v.trim().length < 9) {
                          return 'Enter a valid Ugandan number';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Send reset button
            _SendResetButton(isLoading: isLoading, onTap: onSend),

            const SizedBox(height: 20),

            // Info note
            Center(
              child: Text(
                'Remember your password? Sign in instead.',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Success view ───────────────────────────────────────────────────────────────
class _SuccessView extends StatelessWidget {
  const _SuccessView({
    super.key,
    required this.scaleAnimation,
    required this.phone,
    required this.onBack,
  });

  final Animation<double> scaleAnimation;
  final String phone;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated checkmark
          ScaleTransition(
            scale: scaleAnimation,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF34A853).withOpacity(0.20),
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Center(
                child: Text('✅', style: TextStyle(fontSize: 44)),
              ),
            ),
          ),

          const SizedBox(height: 32),

          const Text(
            'Reset link sent!',
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1A2E),
            ),
          ),

          const SizedBox(height: 12),

          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontSize: 13,
                color: Color(0xFF5F6368),
                height: 1.6,
              ),
              children: [
                const TextSpan(text: 'We\'ve sent a password reset link to\n'),
                TextSpan(
                  text: '+256 $phone',
                  style: const TextStyle(
                    fontFamily: 'Sora',
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const TextSpan(
                  text:
                      '.\n\nCheck your SMS and follow the link to reset your password.',
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // Info card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.orangeBright.withOpacity(0.30),
              ),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ℹ️', style: TextStyle(fontSize: 16)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'The link expires in 15 minutes. If you don\'t receive it, check that the number is registered on HostelHop.',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 11,
                      color: Color(0xFF5F6368),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Back to login button
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
              onPressed: onBack,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 52),
                shape: const StadiumBorder(),
                elevation: 0,
              ),
              child: const Text(
                '← Back to Sign In',
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Send reset button ──────────────────────────────────────────────────────────
class _SendResetButton extends StatelessWidget {
  const _SendResetButton({required this.isLoading, required this.onTap});
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
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
            : const Text(
                '📩 Send Reset Link',
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}

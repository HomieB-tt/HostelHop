import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/app_theme.dart';
import '../../config/app_routes.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  // ── Form ───────────────────────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  final _phoneFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _phoneHasFocus = false;
  bool _passwordHasFocus = false;

  // ── Sun animation ──────────────────────────────────────────────────────────
  late final AnimationController _haloController;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseScale;

  @override
  void initState() {
    super.initState();

    _haloController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _pulseScale = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _phoneFocus.addListener(() {
      setState(() => _phoneHasFocus = _phoneFocus.hasFocus);
    });
    _passwordFocus.addListener(() {
      setState(() => _passwordHasFocus = _passwordFocus.hasFocus);
    });
  }

  @override
  void dispose() {
    _haloController.dispose();
    _pulseController.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ── Actions ────────────────────────────────────────────────────────────────
  Future<void> _onSignIn() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    try {
      await ref
          .read(authProvider.notifier)
          .signInWithPhone(
            phone: '+256${_phoneController.text.trim()}',
            password: _passwordController.text,
          );
      if (mounted) context.go(AppRoutes.home);
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

  void _onForgotPassword() => context.push(AppRoutes.forgotPassword);
  void _onCreateAccount() => context.push(AppRoutes.register);
  void _onOwnerLogin() => context.push(AppRoutes.ownerLogin);

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      resizeToAvoidBottomInset: true,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        child: Stack(
          children: [
            // ── Orange gradient header ─────────────────────────────────
            const _OrangeHeader(),

            // ── Scrollable form ────────────────────────────────────────
            SafeArea(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  children: [
                    // Space for the header (sun orb area)
                    _HeaderContent(
                      haloController: _haloController,
                      pulseScale: _pulseScale,
                    ),

                    // Form card
                    _FormCard(
                      formKey: _formKey,
                      phoneController: _phoneController,
                      passwordController: _passwordController,
                      phoneFocus: _phoneFocus,
                      passwordFocus: _passwordFocus,
                      phoneHasFocus: _phoneHasFocus,
                      passwordHasFocus: _passwordHasFocus,
                      obscurePassword: _obscurePassword,
                      isLoading: _isLoading,
                      onToggleObscure: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                      onSignIn: _onSignIn,
                      onForgotPassword: _onForgotPassword,
                      onCreateAccount: _onCreateAccount,
                      onOwnerLogin: _onOwnerLogin,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Orange gradient header background ─────────────────────────────────────────
class _OrangeHeader extends StatelessWidget {
  const _OrangeHeader();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: 228,
      child: Container(
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
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
        ),
        child: Stack(
          children: [
            // Radial glow blob top-right
            Positioned(
              top: -40,
              right: -20,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withOpacity(0.12),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header content — sun orb + brand ──────────────────────────────────────────
class _HeaderContent extends StatelessWidget {
  const _HeaderContent({
    required this.haloController,
    required this.pulseScale,
  });

  final AnimationController haloController;
  final Animation<double> pulseScale;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return SizedBox(
      height: 228,
      child: Padding(
        padding: EdgeInsets.only(top: topPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Sun orb
            SizedBox(
              width: 100,
              height: 100,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Rotating halo
                  AnimatedBuilder(
                    animation: haloController,
                    builder: (_, __) => Transform.rotate(
                      angle: haloController.value * 2 * math.pi,
                      child: CustomPaint(
                        size: const Size(100, 100),
                        painter: _MiniHaloPainter(),
                      ),
                    ),
                  ),
                  // Pulsing orb
                  AnimatedBuilder(
                    animation: pulseScale,
                    builder: (_, child) =>
                        Transform.scale(scale: pulseScale.value, child: child),
                    child: Container(
                      width: 62,
                      height: 62,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.30),
                            blurRadius: 20,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text('☀️', style: TextStyle(fontSize: 28)),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Brand
            RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: 'Hostel',
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  TextSpan(
                    text: 'Hop',
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white60,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 4),

            const Text(
              'CAMPUS LIFE, SORTED.',
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: Colors.white60,
                letterSpacing: 2.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Mini halo painter (smaller than splash version) ───────────────────────────
class _MiniHaloPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const radius = 46.0;
    const dashCount = 20;
    const dashAngle = (2 * math.pi) / dashCount;
    const gapFraction = 0.45;

    final paint = Paint()
      ..color = Colors.white.withOpacity(0.35)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < dashCount; i++) {
      final startAngle = i * dashAngle;
      const sweepAngle = dashAngle * (1 - gapFraction);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Form card ──────────────────────────────────────────────────────────────────
class _FormCard extends StatelessWidget {
  const _FormCard({
    required this.formKey,
    required this.phoneController,
    required this.passwordController,
    required this.phoneFocus,
    required this.passwordFocus,
    required this.phoneHasFocus,
    required this.passwordHasFocus,
    required this.obscurePassword,
    required this.isLoading,
    required this.onToggleObscure,
    required this.onSignIn,
    required this.onForgotPassword,
    required this.onCreateAccount,
    required this.onOwnerLogin,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final FocusNode phoneFocus;
  final FocusNode passwordFocus;
  final bool phoneHasFocus;
  final bool passwordHasFocus;
  final bool obscurePassword;
  final bool isLoading;
  final VoidCallback onToggleObscure;
  final VoidCallback onSignIn;
  final VoidCallback onForgotPassword;
  final VoidCallback onCreateAccount;
  final VoidCallback onOwnerLogin;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
      decoration: const BoxDecoration(color: AppColors.backgroundLight),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome text
            const Text(
              'Welcome back 👋',
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Sign in to continue to your account',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Color(0xFF5F6368),
              ),
            ),

            const SizedBox(height: 24),

            // ── Phone field ──────────────────────────────────────────
            const _FieldLabel(label: 'PHONE NUMBER'),
            const SizedBox(height: 6),
            _PhoneField(
              controller: phoneController,
              focusNode: phoneFocus,
              hasFocus: phoneHasFocus,
              nextFocus: passwordFocus,
            ),

            const SizedBox(height: 16),

            // ── Password field ───────────────────────────────────────
            const _FieldLabel(label: 'PASSWORD'),
            const SizedBox(height: 6),
            _PasswordField(
              controller: passwordController,
              focusNode: passwordFocus,
              hasFocus: passwordHasFocus,
              obscure: obscurePassword,
              onToggleObscure: onToggleObscure,
              onSubmitted: (_) => onSignIn(),
            ),

            // Forgot password
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onForgotPassword,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 0,
                    vertical: 4,
                  ),
                  foregroundColor: AppColors.blueLight,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Forgot password?',
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // ── Sign In button ───────────────────────────────────────
            _SignInButton(isLoading: isLoading, onTap: onSignIn),

            const SizedBox(height: 20),

            // ── Divider ──────────────────────────────────────────────
            const _Divider(label: 'New to HostelHop?'),

            const SizedBox(height: 16),

            // ── Create account button ────────────────────────────────
            _OutlinedActionButton(
              label: '✨ Create an Account',
              onTap: onCreateAccount,
            ),

            const SizedBox(height: 20),

            // ── Owner login link ─────────────────────────────────────
            Center(
              child: GestureDetector(
                onTap: onOwnerLogin,
                child: RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Own a Hostel?  ',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 12,
                          color: Color(0xFF5F6368),
                        ),
                      ),
                      TextSpan(
                        text: 'Login',
                        style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.orangeBright,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Field label ────────────────────────────────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label});
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
        letterSpacing: 0.5,
      ),
    );
  }
}

// ── Phone field ────────────────────────────────────────────────────────────────
class _PhoneField extends StatelessWidget {
  const _PhoneField({
    required this.controller,
    required this.focusNode,
    required this.hasFocus,
    required this.nextFocus,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasFocus;
  final FocusNode nextFocus;

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
                  color: AppColors.orangeBright.withOpacity(0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: Row(
        children: [
          // Flag + prefix
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
          // Text input
          Expanded(
            child: TextFormField(
              controller: controller,
              focusNode: focusNode,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) =>
                  FocusScope.of(context).requestFocus(nextFocus),
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
    );
  }
}

// ── Password field ─────────────────────────────────────────────────────────────
class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.focusNode,
    required this.hasFocus,
    required this.obscure,
    required this.onToggleObscure,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasFocus;
  final bool obscure;
  final VoidCallback onToggleObscure;
  final ValueChanged<String> onSubmitted;

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
                  color: AppColors.orangeBright.withOpacity(0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        obscureText: obscure,
        textInputAction: TextInputAction.done,
        onFieldSubmitted: onSubmitted,
        style: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 14,
          color: Color(0xFF1A1A2E),
        ),
        decoration: InputDecoration(
          hintText: 'Enter your password',
          hintStyle: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 14,
            color: Color(0xFF9AA0A6),
          ),
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 12, right: 8),
            child: Text('🔑', style: TextStyle(fontSize: 16)),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 0,
            minHeight: 0,
          ),
          suffixIcon: TextButton(
            onPressed: onToggleObscure,
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF9AA0A6),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              obscure ? 'Show' : 'Hide',
              style: const TextStyle(
                fontFamily: 'Sora',
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
        ),
        validator: (v) {
          if (v == null || v.isEmpty) return 'Please enter your password';
          if (v.length < 6) return 'Password must be at least 6 characters';
          return null;
        },
      ),
    );
  }
}

// ── Sign In button ─────────────────────────────────────────────────────────────
class _SignInButton extends StatelessWidget {
  const _SignInButton({required this.isLoading, required this.onTap});
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
            color: AppColors.orangeBright.withOpacity(0.40),
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
            : const Text(
                '🔐 Sign In',
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

// ── Divider with label ─────────────────────────────────────────────────────────
class _Divider extends StatelessWidget {
  const _Divider({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFFE8EAED))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Sora',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF9AA0A6),
            ),
          ),
        ),
        const Expanded(child: Divider(color: Color(0xFFE8EAED))),
      ],
    );
  }
}

// ── Outlined action button ─────────────────────────────────────────────────────
class _OutlinedActionButton extends StatelessWidget {
  const _OutlinedActionButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        shape: const StadiumBorder(),
        side: const BorderSide(color: Color(0xFFE8EAED)),
        foregroundColor: const Color(0xFF5F6368),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Sora',
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/app_theme.dart';
import '../../config/app_routes.dart';
import '../../providers/auth_provider.dart';

// ── Password strength ──────────────────────────────────────────────────────────
enum _PasswordStrength { empty, weak, fair, strong }

_PasswordStrength _evaluateStrength(String password) {
  if (password.isEmpty) return _PasswordStrength.empty;
  int score = 0;
  if (password.length >= 8) score++;
  if (RegExp(r'[A-Z]').hasMatch(password)) score++;
  if (RegExp(r'[0-9]').hasMatch(password)) score++;
  if (RegExp(r'[!@#\$&*~%^()]').hasMatch(password)) score++;
  if (score <= 1) return _PasswordStrength.weak;
  if (score == 2) return _PasswordStrength.fair;
  return _PasswordStrength.strong;
}

Color _strengthColor(_PasswordStrength s) {
  switch (s) {
    case _PasswordStrength.weak:
      return Colors.redAccent;
    case _PasswordStrength.fair:
      return AppColors.orangeBright;
    case _PasswordStrength.strong:
      return const Color(0xFF34A853);
    case _PasswordStrength.empty:
      return const Color(0xFFE8EAED);
  }
}

double _strengthFraction(_PasswordStrength s) {
  switch (s) {
    case _PasswordStrength.empty:
      return 0.0;
    case _PasswordStrength.weak:
      return 0.33;
    case _PasswordStrength.fair:
      return 0.66;
    case _PasswordStrength.strong:
      return 1.0;
  }
}

String _strengthLabel(_PasswordStrength s) {
  switch (s) {
    case _PasswordStrength.empty:
      return '';
    case _PasswordStrength.weak:
      return 'Weak';
    case _PasswordStrength.fair:
      return 'Fair';
    case _PasswordStrength.strong:
      return 'Strong';
  }
}

// ── Screen ─────────────────────────────────────────────────────────────────────
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  // ── Form ───────────────────────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  final _nameFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();

  bool _nameHasFocus = false;
  bool _phoneHasFocus = false;
  bool _passwordHasFocus = false;
  bool _confirmHasFocus = false;

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _agreedToTerms = false;
  bool _isLoading = false;

  _PasswordStrength _passwordStrength = _PasswordStrength.empty;

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

    _nameFocus.addListener(
      () => setState(() => _nameHasFocus = _nameFocus.hasFocus),
    );
    _phoneFocus.addListener(
      () => setState(() => _phoneHasFocus = _phoneFocus.hasFocus),
    );
    _passwordFocus.addListener(
      () => setState(() => _passwordHasFocus = _passwordFocus.hasFocus),
    );
    _confirmFocus.addListener(
      () => setState(() => _confirmHasFocus = _confirmFocus.hasFocus),
    );

    _passwordController.addListener(() {
      setState(() {
        _passwordStrength = _evaluateStrength(_passwordController.text);
      });
    });
  }

  @override
  void dispose() {
    _haloController.dispose();
    _pulseController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _nameFocus.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  // ── Submit ─────────────────────────────────────────────────────────────────
  Future<void> _onRegister() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Please agree to the Terms & Privacy Policy to continue.',
            style: TextStyle(fontFamily: 'Sora', fontSize: 13),
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref
          .read(authProvider.notifier)
          .registerWithPhone(
            fullName: _nameController.text.trim(),
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
            // Orange gradient header background
            const _OrangeHeader(),

            SafeArea(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  children: [
                    // Header with sun orb
                    _HeaderContent(
                      haloController: _haloController,
                      pulseScale: _pulseScale,
                    ),

                    // Form
                    _RegisterForm(
                      formKey: _formKey,
                      nameController: _nameController,
                      phoneController: _phoneController,
                      passwordController: _passwordController,
                      confirmController: _confirmController,
                      nameFocus: _nameFocus,
                      phoneFocus: _phoneFocus,
                      passwordFocus: _passwordFocus,
                      confirmFocus: _confirmFocus,
                      nameHasFocus: _nameHasFocus,
                      phoneHasFocus: _phoneHasFocus,
                      passwordHasFocus: _passwordHasFocus,
                      confirmHasFocus: _confirmHasFocus,
                      obscurePassword: _obscurePassword,
                      obscureConfirm: _obscureConfirm,
                      agreedToTerms: _agreedToTerms,
                      isLoading: _isLoading,
                      passwordStrength: _passwordStrength,
                      onTogglePassword: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                      onToggleConfirm: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                      onToggleTerms: (v) =>
                          setState(() => _agreedToTerms = v ?? false),
                      onRegister: _onRegister,
                      onSignIn: () => context.pop(),
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

// ── Orange header background (shared with login) ───────────────────────────────
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

// ── Header content — sun orb + brand (identical to login) ─────────────────────
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
            SizedBox(
              width: 100,
              height: 100,
              child: Stack(
                alignment: Alignment.center,
                children: [
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

// ── Mini halo painter ──────────────────────────────────────────────────────────
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
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        i * dashAngle,
        dashAngle * (1 - gapFraction),
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Register form ──────────────────────────────────────────────────────────────
class _RegisterForm extends StatelessWidget {
  const _RegisterForm({
    required this.formKey,
    required this.nameController,
    required this.phoneController,
    required this.passwordController,
    required this.confirmController,
    required this.nameFocus,
    required this.phoneFocus,
    required this.passwordFocus,
    required this.confirmFocus,
    required this.nameHasFocus,
    required this.phoneHasFocus,
    required this.passwordHasFocus,
    required this.confirmHasFocus,
    required this.obscurePassword,
    required this.obscureConfirm,
    required this.agreedToTerms,
    required this.isLoading,
    required this.passwordStrength,
    required this.onTogglePassword,
    required this.onToggleConfirm,
    required this.onToggleTerms,
    required this.onRegister,
    required this.onSignIn,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final TextEditingController confirmController;
  final FocusNode nameFocus, phoneFocus, passwordFocus, confirmFocus;
  final bool nameHasFocus, phoneHasFocus, passwordHasFocus, confirmHasFocus;
  final bool obscurePassword, obscureConfirm, agreedToTerms, isLoading;
  final _PasswordStrength passwordStrength;
  final VoidCallback onTogglePassword, onToggleConfirm, onRegister, onSignIn;
  final ValueChanged<bool?> onToggleTerms;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
      color: AppColors.backgroundLight,
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Heading
            const Text(
              'Create Account 🎉',
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Join thousands of students finding great rooms',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 12,
                color: Color(0xFF5F6368),
              ),
            ),

            const SizedBox(height: 24),

            // ── Full Name ─────────────────────────────────────────────
            const _FieldLabel(label: 'FULL NAME'),
            const SizedBox(height: 6),
            _OrangeTextField(
              controller: nameController,
              focusNode: nameFocus,
              hasFocus: nameHasFocus,
              hintText: 'e.g. Brian Ssekandi',
              prefixEmoji: '👤',
              nextFocus: phoneFocus,
              keyboardType: TextInputType.name,
              textCapitalization: TextCapitalization.words,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Full name is required';
                }
                if (v.trim().split(' ').length < 2) {
                  return 'Please enter first and last name';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // ── Phone ─────────────────────────────────────────────────
            const _FieldLabel(label: 'PHONE NUMBER'),
            const SizedBox(height: 4),
            const Text(
              'This will be your login identifier',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 10,
                color: Color(0xFF9AA0A6),
              ),
            ),
            const SizedBox(height: 6),
            _PhoneField(
              controller: phoneController,
              focusNode: phoneFocus,
              hasFocus: phoneHasFocus,
              nextFocus: passwordFocus,
            ),

            const SizedBox(height: 16),

            // ── Password ──────────────────────────────────────────────
            const _FieldLabel(label: 'PASSWORD'),
            const SizedBox(height: 6),
            _PasswordField(
              controller: passwordController,
              focusNode: passwordFocus,
              hasFocus: passwordHasFocus,
              obscure: obscurePassword,
              onToggleObscure: onTogglePassword,
              nextFocus: confirmFocus,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Password is required';
                if (v.length < 6) return 'At least 6 characters required';
                return null;
              },
            ),
            // Strength bar
            if (passwordStrength != _PasswordStrength.empty) ...[
              const SizedBox(height: 8),
              _StrengthBar(strength: passwordStrength),
            ],

            const SizedBox(height: 16),

            // ── Confirm Password ──────────────────────────────────────
            const _FieldLabel(label: 'CONFIRM PASSWORD'),
            const SizedBox(height: 6),
            _PasswordField(
              controller: confirmController,
              focusNode: confirmFocus,
              hasFocus: confirmHasFocus,
              obscure: obscureConfirm,
              onToggleObscure: onToggleConfirm,
              nextFocus: FocusNode(), // last field — dismiss keyboard
              isConfirm: true,
              passwordController: passwordController,
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return 'Please confirm your password';
                }
                if (v != passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            // Match indicator
            if (confirmController.text.isNotEmpty) ...[
              const SizedBox(height: 6),
              _MatchIndicator(
                matches: confirmController.text == passwordController.text,
              ),
            ],

            const SizedBox(height: 20),

            // ── T&C checkbox ──────────────────────────────────────────
            _TermsCheckbox(agreed: agreedToTerms, onChanged: onToggleTerms),

            const SizedBox(height: 24),

            // ── Create Account button ─────────────────────────────────
            _CreateAccountButton(isLoading: isLoading, onTap: onRegister),

            const SizedBox(height: 20),

            // ── Sign In link ──────────────────────────────────────────
            Center(
              child: GestureDetector(
                onTap: onSignIn,
                child: RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Already have an account?  ',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 12,
                          color: Color(0xFF5F6368),
                        ),
                      ),
                      TextSpan(
                        text: 'Sign In',
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

// ── Orange-focused generic text field ─────────────────────────────────────────
class _OrangeTextField extends StatelessWidget {
  const _OrangeTextField({
    required this.controller,
    required this.focusNode,
    required this.hasFocus,
    required this.hintText,
    required this.prefixEmoji,
    required this.nextFocus,
    required this.validator,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasFocus;
  final String hintText, prefixEmoji;
  final FocusNode nextFocus;
  final FormFieldValidator<String> validator;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;

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
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        textInputAction: TextInputAction.next,
        onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(nextFocus),
        style: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 14,
          color: Color(0xFF1A1A2E),
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 14,
            color: Color(0xFF9AA0A6),
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 12, right: 8),
            child: Text(prefixEmoji, style: const TextStyle(fontSize: 16)),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 0,
            minHeight: 0,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
        ),
        validator: validator,
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
                  return 'Phone number is required';
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
    required this.nextFocus,
    required this.validator,
    this.isConfirm = false,
    this.passwordController,
  });

  final TextEditingController controller;
  final FocusNode focusNode, nextFocus;
  final bool hasFocus, obscure, isConfirm;
  final VoidCallback onToggleObscure;
  final FormFieldValidator<String> validator;
  final TextEditingController? passwordController;

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
        textInputAction: isConfirm
            ? TextInputAction.done
            : TextInputAction.next,
        onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(nextFocus),
        style: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 14,
          color: Color(0xFF1A1A2E),
        ),
        decoration: InputDecoration(
          hintText: isConfirm ? 'Re-enter your password' : 'Create a password',
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
        validator: validator,
      ),
    );
  }
}

// ── Password strength bar ──────────────────────────────────────────────────────
class _StrengthBar extends StatelessWidget {
  const _StrengthBar({required this.strength});
  final _PasswordStrength strength;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _strengthFraction(strength),
              minHeight: 5,
              backgroundColor: const Color(0xFFE8EAED),
              valueColor: AlwaysStoppedAnimation(_strengthColor(strength)),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          _strengthLabel(strength),
          style: TextStyle(
            fontFamily: 'Sora',
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: _strengthColor(strength),
          ),
        ),
      ],
    );
  }
}

// ── Password match indicator ───────────────────────────────────────────────────
class _MatchIndicator extends StatelessWidget {
  const _MatchIndicator({required this.matches});
  final bool matches;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          matches ? '✓ Passwords match' : '✗ Passwords do not match',
          style: TextStyle(
            fontFamily: 'Sora',
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: matches ? const Color(0xFF34A853) : Colors.redAccent,
          ),
        ),
      ],
    );
  }
}

// ── Terms checkbox ─────────────────────────────────────────────────────────────
class _TermsCheckbox extends StatelessWidget {
  const _TermsCheckbox({required this.agreed, required this.onChanged});
  final bool agreed;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 22,
          height: 22,
          child: Checkbox(
            value: agreed,
            onChanged: onChanged,
            activeColor: AppColors.orangeBright,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            side: const BorderSide(color: AppColors.orangeBright, width: 1.5),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: () => onChanged(!agreed),
            child: RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 12,
                  color: Color(0xFF5F6368),
                  height: 1.5,
                ),
                children: [
                  TextSpan(text: 'I agree to the '),
                  TextSpan(
                    text: 'Terms of Service',
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontWeight: FontWeight.w600,
                      color: AppColors.orangeBright,
                    ),
                  ),
                  TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontWeight: FontWeight.w600,
                      color: AppColors.blueLight,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Create Account button ──────────────────────────────────────────────────────
class _CreateAccountButton extends StatelessWidget {
  const _CreateAccountButton({required this.isLoading, required this.onTap});
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
                '🎉 Create My Account',
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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/app_theme.dart';
import '../../../config/app_routes.dart';
import '../../../providers/auth_provider.dart';

class OwnerLoginScreen extends ConsumerStatefulWidget {
  const OwnerLoginScreen({super.key});

  @override
  ConsumerState<OwnerLoginScreen> createState() => _OwnerLoginScreenState();
}

class _OwnerLoginScreenState extends ConsumerState<OwnerLoginScreen> {
  // ── Form ───────────────────────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  // OTP — 6 individual controllers + focus nodes
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());

  final _usernameFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _usernameHasFocus = false;
  bool _passwordHasFocus = false;

  @override
  void initState() {
    super.initState();
    _usernameFocus.addListener(
      () => setState(() => _usernameHasFocus = _usernameFocus.hasFocus),
    );
    _passwordFocus.addListener(
      () => setState(() => _passwordHasFocus = _passwordFocus.hasFocus),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _otpFocusNodes) {
      f.dispose();
    }
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  // ── OTP helpers ────────────────────────────────────────────────────────────
  String get _otpValue => _otpControllers.map((c) => c.text).join();

  void _onOtpChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      FocusScope.of(context).requestFocus(_otpFocusNodes[index + 1]);
    }
    setState(() {});
  }

  void _onOtpBackspace(int index) {
    if (_otpControllers[index].text.isEmpty && index > 0) {
      _otpControllers[index - 1].clear();
      FocusScope.of(context).requestFocus(_otpFocusNodes[index - 1]);
      setState(() {});
    }
  }

  // ── Submit ─────────────────────────────────────────────────────────────────
  Future<void> _onAccess() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final otp = _otpValue;
    if (otp.length < 6) {
      _showError('Please enter the 6-digit OTP sent to your email.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref
          .read(authProvider.notifier)
          .signInOwner(
            username: _usernameController.text.trim(),
            password: _passwordController.text,
            otp: otp,
          );
      if (mounted) context.go(AppRoutes.ownerDashboard);
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

              // ── Scrollable content ─────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Admin info card
                        const _AdminInfoCard(),

                        const SizedBox(height: 24),

                        // ── Username ────────────────────────────────────
                        const _FieldLabel(label: 'USERNAME'),
                        const SizedBox(height: 6),
                        _BlueTextField(
                          controller: _usernameController,
                          focusNode: _usernameFocus,
                          hasFocus: _usernameHasFocus,
                          hintText: 'Your owner username',
                          prefixEmoji: '👤',
                          nextFocus: _passwordFocus,
                          textInputAction: TextInputAction.next,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Username is required';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // ── Password ────────────────────────────────────
                        const _FieldLabel(label: 'PASSWORD'),
                        const SizedBox(height: 6),
                        _BluePasswordField(
                          controller: _passwordController,
                          focusNode: _passwordFocus,
                          hasFocus: _passwordHasFocus,
                          obscure: _obscurePassword,
                          onToggleObscure: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                          onSubmitted: (_) => FocusScope.of(
                            context,
                          ).requestFocus(_otpFocusNodes[0]),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Password is required';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 24),

                        // ── OTP section ─────────────────────────────────
                        const _FieldLabel(label: 'WEB OTP · 6-DIGIT CODE'),
                        const SizedBox(height: 4),
                        const Text(
                          'Sent to your registered email address',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 11,
                            color: Color(0xFF9AA0A6),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _OtpRow(
                          controllers: _otpControllers,
                          focusNodes: _otpFocusNodes,
                          onChanged: _onOtpChanged,
                          onBackspace: _onOtpBackspace,
                        ),

                        const SizedBox(height: 24),

                        // ── Warning banner ──────────────────────────────
                        const _WarningBanner(),

                        const SizedBox(height: 24),

                        // ── Access button ───────────────────────────────
                        _AccessButton(isLoading: _isLoading, onTap: _onAccess),
                      ],
                    ),
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
          // Back button
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

          // Centered title block
          const Expanded(
            child: Column(
              children: [
                Text(
                  'Hostel Owner Login',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Admin access · requires web OTP',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 11,
                    color: AppColors.blueLight,
                  ),
                ),
              ],
            ),
          ),

          // Spacer to balance back button
          const SizedBox(width: 36),
        ],
      ),
    );
  }
}

// ── Admin info card ────────────────────────────────────────────────────────────
class _AdminInfoCard extends StatelessWidget {
  const _AdminInfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.blueLight.withOpacity(0.30)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('🏢', style: TextStyle(fontSize: 20)),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Owner & Admin Portal',
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.blueLight,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'This area is restricted to verified hostel owners and platform administrators. Your credentials were provided during onboarding.',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 11,
                    color: Color(0xFF5F6368),
                    height: 1.5,
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

// ── Blue-focused text field ────────────────────────────────────────────────────
class _BlueTextField extends StatelessWidget {
  const _BlueTextField({
    required this.controller,
    required this.focusNode,
    required this.hasFocus,
    required this.hintText,
    required this.prefixEmoji,
    required this.nextFocus,
    required this.textInputAction,
    required this.validator,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasFocus;
  final String hintText;
  final String prefixEmoji;
  final FocusNode nextFocus;
  final TextInputAction textInputAction;
  final FormFieldValidator<String> validator;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: hasFocus ? AppColors.blueLight : const Color(0xFFE8EAED),
          width: hasFocus ? 1.5 : 1.0,
        ),
        boxShadow: hasFocus
            ? [
                BoxShadow(
                  color: AppColors.blueLight.withOpacity(0.10),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        textInputAction: textInputAction,
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

// ── Blue-focused password field ────────────────────────────────────────────────
class _BluePasswordField extends StatelessWidget {
  const _BluePasswordField({
    required this.controller,
    required this.focusNode,
    required this.hasFocus,
    required this.obscure,
    required this.onToggleObscure,
    required this.onSubmitted,
    required this.validator,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasFocus;
  final bool obscure;
  final VoidCallback onToggleObscure;
  final ValueChanged<String> onSubmitted;
  final FormFieldValidator<String> validator;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: hasFocus ? AppColors.blueLight : const Color(0xFFE8EAED),
          width: hasFocus ? 1.5 : 1.0,
        ),
        boxShadow: hasFocus
            ? [
                BoxShadow(
                  color: AppColors.blueLight.withOpacity(0.10),
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
        validator: validator,
      ),
    );
  }
}

// ── OTP row — 6 individual boxes ───────────────────────────────────────────────
class _OtpRow extends StatelessWidget {
  const _OtpRow({
    required this.controllers,
    required this.focusNodes,
    required this.onChanged,
    required this.onBackspace,
  });

  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final void Function(int index, String value) onChanged;
  final void Function(int index) onBackspace;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (i) {
        final isFilled = controllers[i].text.isNotEmpty;
        return SizedBox(
          width: 44,
          height: 52,
          child: KeyboardListener(
            focusNode: FocusNode(),
            onKeyEvent: (event) {
              if (event is KeyDownEvent &&
                  event.logicalKey == LogicalKeyboardKey.backspace) {
                onBackspace(i);
              }
            },
            child: TextFormField(
              controller: controllers[i],
              focusNode: focusNodes[i],
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              inputFormatters: [
                LengthLimitingTextInputFormatter(1),
                FilteringTextInputFormatter.digitsOnly,
              ],
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: isFilled ? AppColors.blueLight : const Color(0xFF1A1A2E),
              ),
              decoration: BoxDecoration(
                color: isFilled
                    ? AppColors.blueLight.withOpacity(0.06)
                    : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isFilled
                      ? AppColors.blueLight
                      : const Color(0xFFE8EAED),
                  width: isFilled ? 1.5 : 1.0,
                ),
              ).toInputDecoration(),
              onChanged: (v) => onChanged(i, v),
            ),
          ),
        );
      }),
    );
  }
}

// ── BoxDecoration → InputDecoration helper extension ──────────────────────────
extension on BoxDecoration {
  InputDecoration toInputDecoration() {
    return InputDecoration(
      border: OutlineInputBorder(
        borderRadius: borderRadius as BorderRadius? ?? BorderRadius.zero,
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: borderRadius as BorderRadius? ?? BorderRadius.zero,
        borderSide: (border as Border?)?.top ?? BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: borderRadius as BorderRadius? ?? BorderRadius.zero,
        borderSide: const BorderSide(color: AppColors.blueLight, width: 1.5),
      ),
      filled: true,
      fillColor: color,
      contentPadding: EdgeInsets.zero,
    );
  }
}

// ── Warning banner ─────────────────────────────────────────────────────────────
class _WarningBanner extends StatelessWidget {
  const _WarningBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFFE082)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('⚠️', style: TextStyle(fontSize: 16)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Unauthorised access attempts are logged and reported. This portal is for verified owners only.',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 11,
                color: Color(0xFF795548),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Access button ──────────────────────────────────────────────────────────────
class _AccessButton extends StatelessWidget {
  const _AccessButton({required this.isLoading, required this.onTap});
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
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
            : const Text(
                '🔐 Access Admin View',
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

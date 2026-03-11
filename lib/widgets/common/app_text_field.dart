import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../config/app_theme.dart';

/// The app's standard text input field.
///
/// Usage:
///   AppTextField(
///     label: 'Phone Number',
///     hint: '07XX XXX XXX',
///     controller: _phoneController,
///     keyboardType: TextInputType.phone,
///     validator: Validators.phone,
///   )
///
///   AppTextField.password(
///     label: 'Password',
///     controller: _passController,
///     validator: Validators.password,
///   )
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.focusNode,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.obscureText = false,
    this.autofocus = false,
    this.initialValue,
  });

  /// Password variant — adds a show/hide toggle automatically
  factory AppTextField.password({
    Key? key,
    required String label,
    String? hint,
    TextEditingController? controller,
    FocusNode? focusNode,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    TextInputAction? textInputAction,
    bool enabled = true,
    bool autofocus = false,
  }) {
    return _PasswordTextField(
      key: key,
      label: label,
      hint: hint ?? 'Enter password',
      controller: controller,
      focusNode: focusNode,
      validator: validator,
      onChanged: onChanged,
      textInputAction: textInputAction,
      enabled: enabled,
      autofocus: autofocus,
    );
  }

  /// Multiline textarea variant
  factory AppTextField.multiline({
    Key? key,
    required String label,
    String? hint,
    TextEditingController? controller,
    FocusNode? focusNode,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    int minLines = 3,
    int maxLines = 6,
    int? maxLength,
    bool enabled = true,
  }) {
    return AppTextField(
      key: key,
      label: label,
      hint: hint,
      controller: controller,
      focusNode: focusNode,
      validator: validator,
      onChanged: onChanged,
      minLines: minLines,
      maxLines: maxLines,
      maxLength: maxLength,
      enabled: enabled,
      textInputAction: TextInputAction.newline,
    );
  }

  final String label;
  final String? hint;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final bool readOnly;
  final int maxLines;
  final int? minLines;
  final int? maxLength;
  final bool obscureText;
  final bool autofocus;
  final String? initialValue;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Label ─────────────────────────────────────────────────────────────
        Text(
          widget.label,
          style: const TextStyle(
            fontFamily: 'Sora',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 6),

        // ── Input ─────────────────────────────────────────────────────────────
        TextFormField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          initialValue: widget.initialValue,
          validator: widget.validator,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          inputFormatters: widget.inputFormatters,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          maxLines: widget.maxLines,
          minLines: widget.minLines,
          maxLength: widget.maxLength,
          obscureText: widget.obscureText,
          autofocus: widget.autofocus,
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 15,
            color: AppColors.textPrimaryLight,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 14,
              color: AppColors.textHintLight,
            ),
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.suffixIcon,
            filled: true,
            fillColor: widget.enabled
                ? AppColors.surfaceLight
                : AppColors.backgroundLight,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.orangeBright,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
            counterText: '',
          ),
        ),
      ],
    );
  }
}

// ── Password variant ───────────────────────────────────────────────────────────
class _PasswordTextField extends AppTextField {
  const _PasswordTextField({
    super.key,
    required super.label,
    super.hint,
    super.controller,
    super.focusNode,
    super.validator,
    super.onChanged,
    super.textInputAction,
    super.enabled,
    super.autofocus,
  }) : super(obscureText: true);

  @override
  State<AppTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends _AppTextFieldState {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontFamily: 'Sora',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          validator: widget.validator,
          onChanged: widget.onChanged,
          textInputAction: widget.textInputAction,
          enabled: widget.enabled,
          autofocus: widget.autofocus,
          obscureText: !_visible,
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 15,
            color: AppColors.textPrimaryLight,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 14,
              color: AppColors.textHintLight,
            ),
            suffixIcon: IconButton(
              onPressed: () => setState(() => _visible = !_visible),
              icon: Icon(
                _visible
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 20,
                color: AppColors.textHintLight,
              ),
            ),
            filled: true,
            fillColor: AppColors.surfaceLight,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.orangeBright,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

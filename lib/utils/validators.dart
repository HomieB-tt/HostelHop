import 'constants.dart';

/// Pure functions for TextFormField validators.
/// Every function matches Flutter's `FormFieldValidator<String>` signature:
/// returns null on valid, error string on invalid.
abstract final class Validators {
  Validators._();

  // ── Phone ──────────────────────────────────────────────────────────────────
  /// Validates a Uganda phone number entered WITHOUT the country code.
  /// Accepts 9-digit numbers starting with 07x / 03x.
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your phone number';
    }
    final cleaned = value.trim().replaceAll(RegExp(r'\s+'), '');
    if (!RegExp(r'^(07|03)\d{7}$').hasMatch(cleaned)) {
      return 'Enter a valid Uganda number (e.g. 0772345678)';
    }
    return null;
  }

  /// Validates a phone number that already includes the +256 prefix.
  static String? phoneWithCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your phone number';
    }
    final cleaned = value.trim().replaceAll(RegExp(r'\s+'), '');
    if (!RegExp(r'^\+256(7|3)\d{8}$').hasMatch(cleaned)) {
      return 'Enter a valid Uganda number';
    }
    return null;
  }

  // ── Mobile money ───────────────────────────────────────────────────────────
  /// Checks that the number belongs to the selected provider.
  /// [provider] is 'MTN' or 'Airtel'.
  static String? mobileMoney(String? value, String provider) {
    final base = phone(value);
    if (base != null) return base;

    final cleaned = value!.trim();
    final prefix = cleaned.substring(0, 3);

    if (provider == 'MTN' && !AppConstants.mtnPrefixes.contains(prefix)) {
      return 'Enter a valid MTN number (077x / 078x / 076x / 039x)';
    }
    if (provider == 'Airtel' && !AppConstants.airtelPrefixes.contains(prefix)) {
      return 'Enter a valid Airtel number (070x / 075x / 074x)';
    }
    return null;
  }

  // ── Email ──────────────────────────────────────────────────────────────────
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email address';
    }
    if (!RegExp(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$').hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  // ── Password ───────────────────────────────────────────────────────────────
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != original) {
      return 'Passwords do not match';
    }
    return null;
  }

  // ── Name ───────────────────────────────────────────────────────────────────
  static String? firstName(String? value) => _name(value, 'first name');

  static String? lastName(String? value) => _name(value, 'last name');

  static String? _name(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your $label';
    }
    if (value.trim().length < 2) {
      return 'Your $label is too short';
    }
    if (RegExp(r'[0-9!@#\$&*~%^()]').hasMatch(value)) {
      return 'Your $label should not contain numbers or symbols';
    }
    return null;
  }

  // ── Required (generic) ────────────────────────────────────────────────────
  static String? required(String? value, [String label = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$label is required';
    }
    return null;
  }

  // ── OTP ───────────────────────────────────────────────────────────────────
  static String? otp(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter the OTP';
    }
    if (!RegExp(r'^\d{6}$').hasMatch(value.trim())) {
      return 'OTP must be 6 digits';
    }
    return null;
  }

  // ── Review ────────────────────────────────────────────────────────────────
  static String? reviewComment(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please write a review';
    }
    if (value.trim().length < 10) {
      return 'Review is too short — add a bit more detail';
    }
    if (value.trim().length > 500) {
      return 'Review is too long (max 500 characters)';
    }
    return null;
  }
}

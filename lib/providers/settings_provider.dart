import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../services/notification_service.dart';

part 'settings_provider.g.dart';

// ── Settings state ─────────────────────────────────────────────────────────────
class AppSettings {
  const AppSettings({
    this.isDarkMode = false,
    this.notificationsEnabled = true,
    this.bookingAlertsEnabled = true,
    this.promoAlertsEnabled = false,
  });

  final bool isDarkMode;
  final bool notificationsEnabled;
  final bool bookingAlertsEnabled;
  final bool promoAlertsEnabled;

  AppSettings copyWith({
    bool? isDarkMode,
    bool? notificationsEnabled,
    bool? bookingAlertsEnabled,
    bool? promoAlertsEnabled,
  }) {
    return AppSettings(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      bookingAlertsEnabled: bookingAlertsEnabled ?? this.bookingAlertsEnabled,
      promoAlertsEnabled: promoAlertsEnabled ?? this.promoAlertsEnabled,
    );
  }

  // ── Hive persistence keys ──────────────────────────────────────────────────
  static const _boxName = 'settings';
  static const _darkModeKey = 'dark_mode';
  static const _notificationsKey = 'notifications_enabled';
  static const _bookingAlertsKey = 'booking_alerts';
  static const _promoAlertsKey = 'promo_alerts';

  static Future<AppSettings> load() async {
    final box = await Hive.openBox(_boxName);
    return AppSettings(
      isDarkMode: box.get(_darkModeKey, defaultValue: false) as bool,
      notificationsEnabled:
          box.get(_notificationsKey, defaultValue: true) as bool,
      bookingAlertsEnabled:
          box.get(_bookingAlertsKey, defaultValue: true) as bool,
      promoAlertsEnabled: box.get(_promoAlertsKey, defaultValue: false) as bool,
    );
  }

  Future<void> save() async {
    final box = await Hive.openBox(_boxName);
    await box.put(_darkModeKey, isDarkMode);
    await box.put(_notificationsKey, notificationsEnabled);
    await box.put(_bookingAlertsKey, bookingAlertsEnabled);
    await box.put(_promoAlertsKey, promoAlertsEnabled);
  }
}

// ── Settings notifier ─────────────────────────────────────────────────────────
@riverpod
class Settings extends _$Settings {
  @override
  Future<AppSettings> build() async {
    final settings = await AppSettings.load();
    _syncNotificationService(settings);
    return settings;
  }

  // ── Sync prefs to NotificationService ─────────────────────────────────────
  void _syncNotificationService(AppSettings s) {
    NotificationService.instance.updateSettings(
      notificationsEnabled: s.notificationsEnabled,
      bookingAlertsEnabled: s.bookingAlertsEnabled,
      promoAlertsEnabled: s.promoAlertsEnabled,
    );
  }

  // ── Toggle dark mode ───────────────────────────────────────────────────────
  Future<void> toggleDarkMode() async {
    final current = state.valueOrNull ?? const AppSettings();
    final updated = current.copyWith(isDarkMode: !current.isDarkMode);
    state = AsyncData(updated);
    await updated.save();
  }

  // ── Toggle all notifications ───────────────────────────────────────────────
  Future<void> setNotificationsEnabled(bool value) async {
    final current = state.valueOrNull ?? const AppSettings();
    final updated = current.copyWith(notificationsEnabled: value);
    state = AsyncData(updated);
    await updated.save();
    _syncNotificationService(updated);
  }

  // ── Toggle booking alerts ──────────────────────────────────────────────────
  Future<void> setBookingAlertsEnabled(bool value) async {
    final current = state.valueOrNull ?? const AppSettings();
    final updated = current.copyWith(bookingAlertsEnabled: value);
    state = AsyncData(updated);
    await updated.save();
    _syncNotificationService(updated);
  }

  // ── Toggle promo alerts ────────────────────────────────────────────────────
  Future<void> setPromoAlertsEnabled(bool value) async {
    final current = state.valueOrNull ?? const AppSettings();
    final updated = current.copyWith(promoAlertsEnabled: value);
    state = AsyncData(updated);
    await updated.save();
    _syncNotificationService(updated);
  }
}

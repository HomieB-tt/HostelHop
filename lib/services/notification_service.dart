import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../repositories/user_repository.dart';

// ── Background message handler ─────────────────────────────────────────────────
// Must be a top-level function — FCM requirement.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background messages are handled by the OS notification tray.
  // No UI work here — Firebase.initializeApp() is NOT needed in this handler
  // because it was already called in main() before the app was backgrounded.
}

/// Manages push notifications via Firebase Cloud Messaging (FCM)
/// and local notifications via flutter_local_notifications.
///
/// Always access via [NotificationService.instance] — never construct directly.
///
/// Lifecycle:
///   1. main() calls NotificationService.instance.init()
///   2. auth_provider calls NotificationService.instance.registerTokenForUser(uid)
///   3. auth_provider calls NotificationService.instance.cancelTokenRefresh() on sign-out
class NotificationService {
  NotificationService._();

  // ── Singleton ─────────────────────────────────────────────────────────────
  static final instance = NotificationService._();

  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();
  final UserRepository _userRepo = const UserRepository();

  // ── Notification channel IDs ───────────────────────────────────────────────
  static const _bookingChannelId = 'hostelhop_bookings';
  static const _bookingChannelName = 'Booking Alerts';
  static const _bookingChannelDesc =
      'Notifications for booking confirmations and updates';

  static const _generalChannelId = 'hostelhop_general';
  static const _generalChannelName = 'General';
  static const _generalChannelDesc = 'General HostelHop notifications';

  // ── Token refresh subscription (cancelled on sign-out) ────────────────────
  StreamSubscription<String>? _tokenRefreshSub;

  // ── Notification settings (set by settings_provider) ──────────────────────
  bool _notificationsEnabled = true;
  bool _bookingAlertsEnabled = true;
  bool _promoAlertsEnabled = true;

  /// Called by settings_provider when the user changes notification prefs.
  void updateSettings({
    required bool notificationsEnabled,
    required bool bookingAlertsEnabled,
    required bool promoAlertsEnabled,
  }) {
    _notificationsEnabled = notificationsEnabled;
    _bookingAlertsEnabled = bookingAlertsEnabled;
    _promoAlertsEnabled = promoAlertsEnabled;
  }

  // ── Pending navigation (consumed by notification_provider) ────────────────
  String? _pendingNavigationBookingId;

  String? consumePendingNavigation() {
    final id = _pendingNavigationBookingId;
    _pendingNavigationBookingId = null;
    return id;
  }

  // ── Init ───────────────────────────────────────────────────────────────────
  Future<void> init() async {
    if (kIsWeb) return;

    // Register background handler before anything else
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Request permissions
    await _requestPermissions();

    // iOS: show banners/sounds when app is in foreground
    if (Platform.isIOS) {
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    // Set up local notifications + Android channels
    await _initLocalNotifications();

    // Foreground messages → show local notification
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Background tap (app was not terminated)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Terminated state tap — check for message that launched the app
    final initial = await _messaging.getInitialMessage();
    if (initial != null) {
      _handleNotificationTap(initial);
    }
  }

  // ── Request permissions ────────────────────────────────────────────────────
  Future<void> _requestPermissions() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
  }

  // ── Local notifications setup ──────────────────────────────────────────────
  Future<void> _initLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _localNotifications.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: (details) {
        _handleLocalNotificationTap(details.payload);
      },
    );

    if (Platform.isAndroid) {
      final plugin = _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      await plugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          _bookingChannelId,
          _bookingChannelName,
          description: _bookingChannelDesc,
          importance: Importance.high,
        ),
      );

      await plugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          _generalChannelId,
          _generalChannelName,
          description: _generalChannelDesc,
          importance: Importance.defaultImportance,
        ),
      );
    }
  }

  // ── Show a local notification ──────────────────────────────────────────────
  Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    bool isBookingAlert = true,
  }) async {
    if (kIsWeb) return;
    if (!_notificationsEnabled) return;
    if (isBookingAlert && !_bookingAlertsEnabled) return;
    if (!isBookingAlert && !_promoAlertsEnabled) return;

    final channelId = isBookingAlert ? _bookingChannelId : _generalChannelId;
    final channelName = isBookingAlert
        ? _bookingChannelName
        : _generalChannelName;
    final channelDesc = isBookingAlert
        ? _bookingChannelDesc
        : _generalChannelDesc;

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDesc,
      importance: isBookingAlert
          ? Importance.high
          : Importance.defaultImportance,
      priority: isBookingAlert ? Priority.high : Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
    );
    const iosDetails = DarwinNotificationDetails();

    await _localNotifications.show(
      id,
      title,
      body,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: payload,
    );
  }

  // ── Foreground message handler ─────────────────────────────────────────────
  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    final isBooking = message.data['type'] == 'booking';

    showLocalNotification(
      id: message.hashCode,
      title: notification.title ?? 'HostelHop',
      body: notification.body ?? '',
      payload: message.data['booking_id'] as String?,
      isBookingAlert: isBooking,
    );
  }

  // ── Notification tap handlers ──────────────────────────────────────────────
  void _handleNotificationTap(RemoteMessage message) {
    final bookingId = message.data['booking_id'] as String?;
    if (bookingId != null) {
      _pendingNavigationBookingId = bookingId;
    }
  }

  void _handleLocalNotificationTap(String? payload) {
    if (payload != null) {
      _pendingNavigationBookingId = payload;
    }
  }

  // ── FCM token management ───────────────────────────────────────────────────
  Future<String?> getToken() async {
    if (kIsWeb) return null;
    return _messaging.getToken();
  }

  /// Call after login to register the device token with the user's profile.
  /// Subscribes to token refreshes — call [cancelTokenRefresh] on sign-out.
  Future<void> registerTokenForUser(String userId) async {
    if (kIsWeb) return;

    final token = await getToken();
    if (token != null) {
      await _userRepo.updateFcmToken(userId, token);
    }

    // Cancel any stale subscription before creating a new one
    await _tokenRefreshSub?.cancel();
    _tokenRefreshSub = _messaging.onTokenRefresh.listen((newToken) async {
      await _userRepo.updateFcmToken(userId, newToken);
    });
  }

  /// Call on sign-out to stop listening for token refreshes.
  Future<void> cancelTokenRefresh() async {
    await _tokenRefreshSub?.cancel();
    _tokenRefreshSub = null;
  }

  // ── Badge clear (iOS) ──────────────────────────────────────────────────────
  Future<void> clearBadge() async {
    if (kIsWeb || !Platform.isIOS) return;
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions();
  }
}

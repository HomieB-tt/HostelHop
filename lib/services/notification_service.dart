import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../repositories/user_repository.dart';

// ── Background message handler (top-level, required by FCM) ─────────────────
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // FirebaseMessaging background messages are handled here.
  // No UI work — just log or persist if needed.
}

/// Manages push notifications via Firebase Cloud Messaging
/// and local notifications via flutter_local_notifications.
class NotificationService {
  NotificationService({UserRepository? userRepository})
    : _userRepo = userRepository ?? const UserRepository();

  final UserRepository _userRepo;

  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  // Android notification channel for booking alerts
  static const _bookingChannelId = 'hostelhop_bookings';
  static const _bookingChannelName = 'Booking Alerts';
  static const _bookingChannelDesc =
      'Notifications for booking confirmations and updates';

  // ── Initialise ─────────────────────────────────────────────────────────────
  Future<void> init() async {
    // Register background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Request permissions (iOS + Android 13+)
    await _requestPermissions();

    // Set up local notifications
    await _initLocalNotifications();

    // Listen to foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification tap when app was in background (not terminated)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
  }

  // ── Request permissions ────────────────────────────────────────────────────
  Future<void> _requestPermissions() async {
    if (kIsWeb) return;

    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
  }

  // ── Local notifications setup ──────────────────────────────────────────────
  Future<void> _initLocalNotifications() async {
    if (kIsWeb) return;

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false, // Already requested above
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _localNotifications.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: (details) {
        // Handle tap on local notification — route based on payload
        _handleLocalNotificationTap(details.payload);
      },
    );

    // Create Android notification channel
    if (Platform.isAndroid) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(
            const AndroidNotificationChannel(
              _bookingChannelId,
              _bookingChannelName,
              description: _bookingChannelDesc,
              importance: Importance.high,
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
  }) async {
    if (kIsWeb) return;

    const androidDetails = AndroidNotificationDetails(
      _bookingChannelId,
      _bookingChannelName,
      channelDescription: _bookingChannelDesc,
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();

    await _localNotifications.show(
      id,
      title,
      body,
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: payload,
    );
  }

  // ── Foreground message handler ─────────────────────────────────────────────
  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    showLocalNotification(
      id: message.hashCode,
      title: notification.title ?? 'HostelHop',
      body: notification.body ?? '',
      payload: message.data['booking_id'],
    );
  }

  // ── Notification tap handlers ──────────────────────────────────────────────
  void _handleNotificationTap(RemoteMessage message) {
    // Navigation is handled by providers watching a notification stream.
    // Store the booking_id from data payload for the provider to pick up.
    final bookingId = message.data['booking_id'];
    if (bookingId != null) {
      _pendingNavigationBookingId = bookingId;
    }
  }

  void _handleLocalNotificationTap(String? payload) {
    if (payload != null) {
      _pendingNavigationBookingId = payload;
    }
  }

  // ── Pending navigation (consumed by notification_provider) ────────────────
  String? _pendingNavigationBookingId;
  String? consumePendingNavigation() {
    final id = _pendingNavigationBookingId;
    _pendingNavigationBookingId = null;
    return id;
  }

  // ── FCM token management ───────────────────────────────────────────────────
  Future<String?> getToken() async {
    if (kIsWeb) return null;
    return _messaging.getToken();
  }

  /// Call this after login to register the device token with the user profile.
  Future<void> registerTokenForUser(String userId) async {
    if (kIsWeb) return;

    final token = await getToken();
    if (token == null) return;

    await _userRepo.updateFcmToken(userId, token);

    // Listen for token refresh
    _messaging.onTokenRefresh.listen((newToken) async {
      await _userRepo.updateFcmToken(userId, newToken);
    });
  }

  // ── Clear badge count (iOS) ────────────────────────────────────────────────
  Future<void> clearBadge() async {
    if (kIsWeb || !Platform.isIOS) return;
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions();
  }
}

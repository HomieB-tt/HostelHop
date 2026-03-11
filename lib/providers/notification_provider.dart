import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/notification_service.dart';

// ── Notification deep-link provider ───────────────────────────────────────────
/// Exposes the booking ID from a notification tap so the app can navigate.
///
/// Usage in a root widget (e.g. inside HomeScreen or _ShellScaffold):
///
///   ref.listen(notificationDeepLinkProvider, (_, next) {
///     if (next != null) {
///       context.push(AppRoutes.bookingConfirmation(next));
///     }
///   });
///
/// The provider polls [NotificationService.instance.consumePendingNavigation()]
/// once on build. The router also calls it after the app resumes from
/// background (handled by [NotificationService.onMessageOpenedApp]).
final notificationDeepLinkProvider = StreamProvider<String?>((ref) async* {
  // Emit the pending navigation booking ID once on startup
  // (handles terminated-state tap via getInitialMessage)
  final pending = NotificationService.instance.consumePendingNavigation();
  if (pending != null) yield pending;

  // Then listen for subsequent taps while the app is running
  yield* _notificationTapStream();
});

// Internal stream that emits when the user taps a notification
// while the app is in background or foreground.
Stream<String?> _notificationTapStream() {
  late StreamController<String?> controller;

  Timer? _pollTimer;

  controller = StreamController<String?>.broadcast(
    onListen: () {
      // Poll every 500ms — lightweight since it just reads a nullable field
      _pollTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
        final id = NotificationService.instance.consumePendingNavigation();
        if (id != null) controller.add(id);
      });
    },
    onCancel: () {
      _pollTimer?.cancel();
    },
  );

  return controller.stream;
}

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

import '../di/injection.dart';
import '../router/app_router.dart';
import '../router/routes.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/orders/domain/repositories/orders_repository.dart';

const _androidChannel = AndroidNotificationChannel(
  'grand_frere_channel',
  'Notifications importantes',
  description:
      'Utilisé pour les notifications de commandes et du compte vendeur.',
  importance: Importance.max,
);

/// Displays notifications locally (foreground push + tap handling).
class LocalNotificationService {
  final _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_androidChannel);

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null) {
          handleNotificationTap(jsonDecode(payload) as Map<String, dynamic>);
        }
      },
    );
  }

  Future<void> show(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return Future.value();
    return _plugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'grand_frere_channel',
          'Notifications importantes',
          importance: Importance.max,
          priority: Priority.high,
        ),
        // Without these, iOS silently drops the banner while the app is
        // in the foreground — it only shows for background/terminated pushes.
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }
}

/// Handles Firebase Cloud Messaging: permission, token, and message streams.
/// Basic setup only — tapping a notification simply opens the notifications screen.
class FirebaseNotificationService {
  FirebaseNotificationService(this._local, this._authRepository);
  final LocalNotificationService _local;
  final AuthRepository _authRepository;

  final _messaging = FirebaseMessaging.instance;

  Future<void> init() async {
    await _requestPermission();
    await _local.init();

    // Listeners must be registered unconditionally before anything that can
    // fail (like the network call in syncToken) — otherwise a token-sync
    // error silently kills foreground display and tap handling for the rest
    // of the session.
    FirebaseMessaging.onMessage.listen(_local.show);
    FirebaseMessaging.onMessageOpenedApp.listen(
      (message) => handleNotificationTap(message.data),
    );

    unawaited(syncToken());
    _messaging.onTokenRefresh.listen((_) => syncToken());

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      handleNotificationTap(initialMessage.data);
    }
  }

  /// Fire-and-forget: registering the token isn't on the critical path,
  /// mirrors how the backend treats notification side effects. Errors are
  /// swallowed here so a token-sync failure never breaks the listeners above.
  Future<void> syncToken() async {
    try {
      if (Platform.isIOS) {
        // On iOS, FCM's getToken() calls getAPNSToken() internally, but APNS
        // registration with Apple is async — retry until it's ready.
        var apnsToken = await _messaging.getAPNSToken();
        var attempts = 0;
        while (apnsToken == null && attempts < 5) {
          await Future.delayed(const Duration(seconds: 1));
          apnsToken = await _messaging.getAPNSToken();
          attempts++;
        }
        if (apnsToken == null) return;
      }

      final token = await getToken();
      if (token != null) {
        await _authRepository.updateFcmToken(token);
      }
    } catch (e, st) {
      log('Failed to sync FCM token', error: e, stackTrace: st);
    }
  }

  Future<void> _requestPermission() async {
    if (Platform.isAndroid) {
      await Permission.notification.request();
    }
    await _messaging.requestPermission(alert: true, badge: true, sound: true);
  }

  Future<String?> getToken() => _messaging.getToken();
}

/// Must be a top-level function: runs in a separate isolate when the app is backgrounded/terminated.
@pragma('vm:entry-point')
Future<void> firebaseBackgroundMessageHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

/// Routes a notification tap. `ORDER_RECEIVED` loads the order detail from
/// the `orderId` carried in the FCM data payload; anything else (or a failed
/// fetch) falls back to the notifications list.
Future<void> handleNotificationTap(Map<String, dynamic> data) async {
  log('handleNotificationTap: $data');
  final router = getIt<AppRouter>().router;
  final orderId = data['orderId'] as String?;

  if (data['type'] == 'ORDER_RECEIVED' && orderId != null) {
    final result = await getIt<OrdersRepository>().getOrderById(orderId);
    final order = result.fold((f) {
      log('handleNotificationTap: getOrderById failed — ${f.message}');
      return null;
    }, (order) => order);
    if (order != null) {
      router.push(
        Routes.orderDetail.replaceFirst(':id', order.id),
        extra: order,
      );
      return;
    }
  }

  router.push(Routes.notifications);
}

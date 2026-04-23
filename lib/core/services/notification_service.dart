import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _ready = false;

  static Future<void> initialize() async {
    if (_ready) return;
    if (kIsWeb) {
      _ready = true;
      return;
    }
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);
    await _plugin.initialize(settings);
    const channel = AndroidNotificationChannel(
      'isnad_alerts',
      'تنبيهات إسناد',
      description: 'بلاغات وطوارئ',
      importance: Importance.max,
    );
    final androidImpl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.createNotificationChannel(channel);
    _ready = true;
  }

  static Future<void> showSOSAlert({
    required String reporterName,
    required String location,
  }) async {
    if (kIsWeb) return;
    await initialize();
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'isnad_alerts',
        'تنبيهات إسناد',
        channelDescription: 'بلاغات وطوارئ',
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        enableVibration: true,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
    await _plugin.show(
      1001,
      '🚨 بلاغ طوارئ SOS',
      'مُبلِّغ: $reporterName | الموقع: $location',
      details,
    );
  }

  static Future<void> showNewReportAlert({required String reportId}) async {
    if (kIsWeb) return;
    await initialize();
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'isnad_alerts',
        'تنبيهات إسناد',
        channelDescription: 'بلاغات جديدة',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
    await _plugin.show(
      reportId.hashCode & 0x7fffffff,
      'بلاغ جديد',
      'رقم البلاغ: $reportId',
      details,
    );
  }

  static void debugLog(String msg) {
    if (kDebugMode) {
      debugPrint(msg);
    }
  }
}

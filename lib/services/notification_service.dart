import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static Future<void> initialize(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
  ) async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // Обробка натискання на нотифікацію
      },
    );
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    required FlutterLocalNotificationsPlugin fln,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'cycle_tracker_channel',
          'Cycle Tracker',
          channelDescription: 'Notifications for cycle tracking',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails();

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await fln.show(id, title, body, platformChannelSpecifics);
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required FlutterLocalNotificationsPlugin fln,
  }) async {
    // Перевіряємо, чи час не в минулому
    final now = DateTime.now();
    var finalScheduledTime = scheduledTime;

    if (scheduledTime.isBefore(now)) {
      // Якщо час вже минув, плануємо на завтра на той же час
      finalScheduledTime = scheduledTime.add(const Duration(days: 1));
      print('⚠️ Час був в минулому. Планується на: $finalScheduledTime');
    }

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'cycle_tracker_channel',
          'Cycle Tracker',
          channelDescription: 'Scheduled notifications for cycle tracking',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails();

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await fln.zonedSchedule(
      id,
      title,
      body,
      _convertToTZDateTime(finalScheduledTime),
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    print('✅ Нотифікація планується на: $finalScheduledTime');
  }

  static tz.TZDateTime _convertToTZDateTime(DateTime dateTime) {
    final tz.TZDateTime tzDateTime = tz.TZDateTime.from(dateTime, tz.local);
    print('🕐 TZ DateTime: $tzDateTime');
    return tzDateTime;
  }

  static Future<void> cancelNotification(
    int id,
    FlutterLocalNotificationsPlugin fln,
  ) async {
    await fln.cancel(id);
  }

  static Future<void> cancelAllNotifications(
    FlutterLocalNotificationsPlugin fln,
  ) async {
    await fln.cancelAll();
  }
}

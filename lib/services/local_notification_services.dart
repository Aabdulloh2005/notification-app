import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzl;
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationsService {
  static final _localNotification = FlutterLocalNotificationsPlugin();

  static bool notificationsEnabled = false;

  static Future<void> requestPermission() async {
    if (Platform.isAndroid) {
      final androidImplementation =
          _localNotification.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      final bool? grantedNotificationPermission =
          await androidImplementation?.requestNotificationsPermission();
      notificationsEnabled = grantedNotificationPermission ?? false;
    } else if (Platform.isIOS) {
      final bool? result = await _localNotification
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      notificationsEnabled = result ?? false;
    }
  }

  static Future<void> start() async {
    final currentTimeZone = await FlutterTimezone.getLocalTimezone();
    tzl.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));

    const androidInit = AndroidInitializationSettings('mipmap/ic_launcher');

    const notificationInit = InitializationSettings(
      android: androidInit,
    );

    await _localNotification.initialize(notificationInit);
  }

  static Future<void> showNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'goodChannelId',
      'goodChannelName',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _localNotification.show(
      0,
      'Pomodoro',
      'Boldi shuncha dars qigain yetadi dam ol',
      notificationDetails,
    );
  }

  static Future<void> showScheduledNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'goodChannelId',
      'goodChannelName',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      ticker: 'Ticker',
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _localNotification.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      notificationDetails,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true,
    );
  }
}
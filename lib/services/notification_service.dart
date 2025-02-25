import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static Future<void> onDidReceiveNotification(
      NotificationResponse notificationResponse) async {
    debugPrint("Notification receive");
  }

  Future<void> initNotification() async {
    try {
      const AndroidInitializationSettings androidInitializationSettings =
          AndroidInitializationSettings("@mipmap/ic_launcher");
      const DarwinInitializationSettings iOSInitializationSettings =
          DarwinInitializationSettings();
      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: androidInitializationSettings,
        iOS: iOSInitializationSettings,
      );
      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: onDidReceiveNotification,
        onDidReceiveBackgroundNotificationResponse: onDidReceiveNotification,
      );

      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }
  }

  Future<void> scheduleNotification(
      int id, String title, String body, DateTime scheduledDate) async {
    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'reminder_channel',
            'Appointment Reminders',
            channelDescription:
                'Notifications for upcoming blood donation appointments',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dateAndTime,
        androidScheduleMode: AndroidScheduleMode.alarmClock,
      );
      debugPrint('Saved?: $scheduledDate');
      _saveNotificationToPreferences(title, body, scheduledDate);
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }

  Future<void> _saveNotificationToPreferences(
      String title, String body, DateTime scheduledDate) async {
    final prefs = await SharedPreferences.getInstance();
    final notifications = prefs.getStringList('notifications') ?? [];

    final notificationData = jsonEncode({
      'title': title,
      'description': body,
      'time': '${scheduledDate.hour}:${scheduledDate.minute}',
    });

    notifications.add(notificationData);
    await prefs.setStringList('notifications', notifications);
  }
}

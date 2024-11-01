// ignore_for_file: deprecated_member_use

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
      );

      await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
      tz.initializeTimeZones();
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }
  }

  Future<void> scheduleNotification(
      int id, String title, String body, DateTime scheduledDate) async {
    try {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'your_channel_id',
            'your_channel_name',
            channelDescription: 'your_channel_description',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      debugPrint("Notification scheduled successfully for $scheduledDate");
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

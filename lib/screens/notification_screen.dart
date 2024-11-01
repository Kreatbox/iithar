import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, String>> notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final notificationStrings = prefs.getStringList('notifications') ?? [];
    setState(() {
      notifications = notificationStrings
          .map((notificationString) =>
              Map<String, String>.from(jsonDecode(notificationString)))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Align(
          alignment: Alignment.centerRight,
          child: Text(
            ' الإشعارات ',
            textAlign: TextAlign.right,
            style:
                TextStyle(fontFamily: 'HSI', fontSize: 30, color: Colors.black),
          ),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: notifications.isEmpty
            ? const Center(child: Text('لا توجد إشعارات'))
            : ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    color: Colors.white,
                    shadowColor: const Color(0xFFAE0E03),
                    child: ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            notifications[index]['title']!,
                            style: const TextStyle(
                                fontFamily: 'HSI',
                                fontSize: 20,
                                color: Colors.black),
                          ),
                          const SizedBox(width: 15),
                          const Icon(Icons.notifications,
                              color: Color(0xFFAE0E03)),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notifications[index]['description']!,
                            style: const TextStyle(
                                fontFamily: 'HSI',
                                fontSize: 20,
                                color: Colors.black),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            notifications[index]['time']!,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontFamily: 'HSI',
                            ),
                          ),
                        ],
                      ),
                      leading: const Icon(Icons.arrow_back_ios),
                      onTap: () {},
                    ),
                  );
                },
              ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  final List<Map<String, String>> notifications = [
    {
      'title': 'تم نشر طلب تبرع بزمرة دمك',
      'description': '',
      'time': 'قبل ساعة'
    },
  ];

  NotificationsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              ' الإشعارات ',
              textAlign: TextAlign.right,
              style: TextStyle(
                  fontFamily: 'HSI', fontSize: 30, color: Colors.black),
            ),
          ),
        ),
      ),
      body: ListView.builder(
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
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                        fontFamily: 'HSI', fontSize: 20, color: Colors.black),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  const Icon(Icons.notifications,
                      color: Color(
                        0xFFAE0E03,
                      )),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notifications[index]['description']!,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                        fontFamily: 'HSI', fontSize: 20, color: Colors.black),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    notifications[index]['time']!,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontFamily: 'HSI',
                    ),
                  ),
                ],
              ),
              leading: const Icon(Icons.arrow_back_ios),
              onTap: () {
                // Action when notification is tapped
              },
            ),
          );
        },
      ),
    );
  }
}

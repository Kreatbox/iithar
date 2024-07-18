import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  final List<Map<String, String>> notifications = [
  
    {
      'title': 'تم نشر طلب تبرع بزمرة دمك',
      'description': '',
      'time': 'قبل ساعة'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('الإشعارات'),
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(notifications[index]['title']!),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(notifications[index]['description']!),
                  SizedBox(height: 5),
                  Text(notifications[index]['time']!, style: TextStyle(color: Colors.grey)),
                ],
              ),
              leading: Icon(Icons.notifications, color:  Color(0xFFAE0E03)),
              trailing: Icon(Icons.arrow_forward_ios),
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

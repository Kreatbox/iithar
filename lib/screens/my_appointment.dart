import 'package:flutter/material.dart';

void main() {
  runApp(MyAppointmentScreen());
}

class MyAppointmentScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BookingSummaryScreen(),
    );
  }
}

class BookingSummaryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Align(
          alignment: Alignment.centerRight,
          child: Text(
            'ملخص الحجز',
            style: TextStyle(
              fontFamily: 'HSI',
              fontSize: 30,
              color: Colors.black,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildInfoSection(
              'بنك دم حمص',
              [
                InfoRow(
                  icon: Icons.calendar_today,
                  label: 'تاريخ الموعد',
                  value: '08 فبراير, 2025',
                ),
                Divider(),
                InfoRow(
                  icon: Icons.access_time,
                  label: 'وقت الموعد',
                  value: '10:30 ص',
                ),
                Divider(),
                InfoRow(
                  icon: Icons.hourglass_empty,
                  label: 'مدة التبرع',
                  value: '20 دقيقة',
                ),
                Divider(),
                InfoRow(
                  icon: Icons.local_hospital,
                  label: 'نوع التبرع',
                  value: 'الدم الكامل',
                ),
                Divider(),
                InfoRow(
                  icon: Icons.bloodtype,
                  label: 'فصيلة الدم',
                  value: 'O+',
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Functionality for editing the appointment
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFAE0E03),
                  ),
                  child: Text(
                    'تعديل الموعد',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'HSI',
                      fontSize: 25,
                      color: Colors.white,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Functionality for cancelling the appointment
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFAE0E03),
                  ),
                  child: Text(
                    'إلغاء الموعد',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'HSI',
                      fontSize: 25,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(112, 112, 112, 100),
              blurRadius: 5,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: 'HSI',
                fontSize: 30,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 16.0),
            ...children,
          ],
        ),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20.0, color: Color(0xFFAE0E03)),
        SizedBox(width: 8.0),
        Text(
          '$label: $value',
          style: TextStyle(
            fontFamily: 'HSI',
            fontSize: 15,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}

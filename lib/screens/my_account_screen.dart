import 'package:flutter/material.dart';


class MyAccountScreen extends StatelessWidget {
  const MyAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      body: Padding(padding: EdgeInsets.all(20),
       child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'المعلومات الشخصية',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            _buildProfileField('الاسم الأول', ''),
            _buildProfileField('اسم العائلة', ''),
            _buildProfileField('البريد الإلكتروني', ''),
            _buildProfileField('رقم الهاتف', ' '),
            _buildProfileField('الرقم القومي', ''),
            _buildProfileField('تاريخ الميلاد', ''),
            _buildProfileField('فصيلة الدم', ''),
            _buildProfileField('قابل للتبرع', ''),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
       Widget _buildProfileField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(value),
        ],
      ),
    );
  }
}
   
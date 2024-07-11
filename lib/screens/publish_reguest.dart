import 'package:flutter/material.dart';

class PublishReguest  extends StatelessWidget {
  const PublishReguest({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('انشر طلب بحاجة دم'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildRequestField(Icons.location_on, 'المدينة'),
            _buildRequestField(Icons.local_hospital, 'مركز التبرع'),
            _buildRequestField(Icons.bloodtype, 'زمرة الدم المطلوبة '),
            _buildRequestField(Icons.phone, 'رقم الهاتف'),
            _buildRequestField(Icons.note, ' أضف ملاحظة'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
              },
              child: Text('نشر'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFAE0E03),
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                textStyle: TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestField(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Color(0xFFAE0E03),),
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
     
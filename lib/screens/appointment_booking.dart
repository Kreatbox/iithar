import 'package:flutter/material.dart';

class AppointmentBookingScreen extends StatefulWidget {
  const AppointmentBookingScreen({super.key});

  @override
  _AppointmentBookingScreenState createState() => _AppointmentBookingScreenState();
  
}

class _AppointmentBookingScreenState extends State<AppointmentBookingScreen> {
  String? _selectedCenter;
  String? _selectedDate;
  String? _selectedTime;

  final List<String> _centers = [
    'بنك الدم - دمشق',
    'بنك الدم - حمص',
    'بنك الدم - حلب',
    'بنك الدم - حماة',
    'بنك الدم - طرطوس',
  ];

  final List<String> _dates = [
  
  ];

  final List<String> _times = [
    
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        
        title: Text('احجز موعد تبرع'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField(
              decoration: InputDecoration(
                labelText: 'اختر مركز ',
                border: OutlineInputBorder(),
              ),
              value: _selectedCenter,
              onChanged: (value) {
                setState(() {
                  _selectedCenter = value as String?;
                });
              },
              items: _centers.map((center) {
                return DropdownMenuItem(
                  value: center,
                  child: Text(center),
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField(
              decoration: InputDecoration(
                labelText: 'اختر تاريخ ',
                border: OutlineInputBorder(),
              ),
              value: _selectedDate,
              onChanged: (value) {
                setState(() {
                  _selectedDate = value as String?;
                });
              },
              items: _dates.map((date) {
                return DropdownMenuItem(
                  value: date,
                  child: Text(date),
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField(
              decoration: InputDecoration(
                labelText: 'اختر وقت ',
                border: OutlineInputBorder(),
              ),
              value: _selectedTime,
              onChanged: (value) {
                setState(() {
                  _selectedTime = value as String?;
                });
              },
              items: _times.map((time) {
                return DropdownMenuItem(
                  value: time,
                  child: Text(time),
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFAE0E03),
              ),
              onPressed: () {
                if (_selectedCenter != null && _selectedDate != null && _selectedTime != null) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('تأكيد الحجز '),
                        content: Text('تم حجز موعدك في $_selectedCenter في تاريخ $_selectedDate في وقت $_selectedTime'),
                        actions: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('تأكيد'),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('لم يتم استكمال الحجز  '),
                    ),
                  );
                }
              },
              child: Text('احجز موعد'),
            ),
          ],
        ),
      ),
    );
  }
}
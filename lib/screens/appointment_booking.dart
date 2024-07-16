import 'package:flutter/material.dart';

class AppointmentBookingScreen extends StatefulWidget {
  const AppointmentBookingScreen({super.key});

  @override
  _AppointmentBookingScreenState createState() => _AppointmentBookingScreenState();
}

class _AppointmentBookingScreenState extends State<AppointmentBookingScreen> {
  String? _selectedCenter;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  final List<String> _centers = [
    'بنك الدم - دمشق',
    'بنك الدم - حمص',
    'بنك الدم - حلب',
    'بنك الدم - حماة',
    'بنك الدم - طرطوس',
  ];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Color(0xFFAE0E03), // لون النص والرمز للعنوان
            colorScheme: ColorScheme.light(primary: Color(0xFFAE0E03)), // لون الأيقونات
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary), // لون النص للأزرار
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate)
      setState(() {
        _selectedDate = picked;
      });
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor:Color(0xFFAE0E03), // لون النص والرمز للعنوان
            colorScheme: ColorScheme.light(primary:Color(0xFFAE0E03)), // لون الأيقونات
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary), // لون النص للأزرار
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime)
      setState(() {
        _selectedTime = picked;
      });
  }

  void _resetSelections() {
    setState(() {
      _selectedCenter = null;
      _selectedDate = null;
      _selectedTime = null;
    });
  }

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
                labelText: 'اختر مركز',
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
            TextField(
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'اختر تاريخ',
                border: OutlineInputBorder(),
              ),
              onTap: () => _selectDate(context),
              controller: TextEditingController(
                text: _selectedDate == null
                    ? ''
                    : '${_selectedDate!.year}-${_selectedDate!.month}-${_selectedDate!.day}',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'اختر وقت',
                border: OutlineInputBorder(),
              ),
              onTap: () => _selectTime(context),
              controller: TextEditingController(
                text: _selectedTime == null
                    ? ''
                    : _selectedTime!.format(context),
              ),
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
                        title: Text('تأكيد الحجز'),
                        content: Text('تم حجز موعدك في $_selectedCenter في تاريخ ${_selectedDate!.year}-${_selectedDate!.month}-${_selectedDate!.day} في وقت ${_selectedTime!.format(context)}'),
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
                      content: Text('لم يتم استكمال الحجز'),
                    ),
                  );
                }
              },
              child: Text('احجز موعد'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:Color(0xFFAE0E03),
              ),
              onPressed: _resetSelections,
              child: Text('مسح البيانات المختارة'),
            ),
          ],
        ),
      ),
    );
  }
}

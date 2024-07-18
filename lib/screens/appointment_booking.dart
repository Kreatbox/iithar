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
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Expanded(
          child: Align(alignment:
          Alignment.centerRight,
            child:
            Text('حجز موعد تبرع بالدم ',
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontFamily: 'HSI', fontSize: 30, color: Colors.black)),
          ),
        ),
      ),
      body:
      Stack(children: [
        Image.asset(
        'assets/Images/Ve.png',
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      ),

        Padding(padding: const EdgeInsets.all(20.0),
         child :Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              alignment: AlignmentDirectional.topEnd,
              borderRadius: BorderRadius.circular(20),
              dropdownColor: Colors.white,
              decoration: InputDecoration(
                labelText: 'اختر مركز',
                labelStyle: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
                floatingLabelBehavior: FloatingLabelBehavior.always,
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              value: _selectedCenter,
              onChanged: (value) {
                setState(() {
                  _selectedCenter = value;
                });
              },
              items: _centers.map((center) {
                return DropdownMenuItem<String>(
                  alignment: AlignmentDirectional.topEnd,
                  value: center,
                  child: Text(
                    center,
                    textAlign: TextAlign.right,
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            Directionality(textDirection:  TextDirection.rtl,
           child: TextField(
              textAlign: TextAlign.right,
              //textDirection: TextDirection.ltr,
              readOnly: true,
              decoration: InputDecoration(
                floatingLabelAlignment: FloatingLabelAlignment.start,
                labelText: 'اختر تاريخ',
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15) ,)
              ),
              onTap: () => _selectDate(context),
              controller: TextEditingController(
                text: _selectedDate == null
                    ? ''
                    : '${_selectedDate!.year}-${_selectedDate!.month}-${_selectedDate!.day}',
              ),
            ),),
            SizedBox(height: 16),
        Directionality(textDirection:  TextDirection.rtl,
       child: TextField(
              textAlign: TextAlign.end,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'اختر وقت',
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15) ,)
              ),
              onTap: () => _selectTime(context),
              controller: TextEditingController(
                text: _selectedTime == null
                    ? ''
                    : _selectedTime!.format(context),
              ),
       ),),
            SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  fixedSize: Size(175, 45),
                  backgroundColor: const Color(0xFFAE0E03),
                  padding: const EdgeInsets.only(
                      right: 25.0, left: 25.0, top: 5.0, bottom: 1.0),
                  alignment: Alignment.center),

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
                child: Text(
                  'احجز موعد',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'HSI', fontSize: 25, color: Colors.white),
                )),
        const SizedBox(height: 20),


            ElevatedButton(
                style: ElevatedButton.styleFrom(fixedSize: Size(175, 45),
                    backgroundColor: const Color(0xFFAE0E03),
                    padding: const EdgeInsets.only(
                        right: 25.0, left: 25.0, top: 5.0, bottom: 1.0),
                    alignment: Alignment.center),
              onPressed: _resetSelections,
                child: Text(
                  'مسح البيانات ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'HSI', fontSize: 25, color: Colors.white),
                )),
        const SizedBox(height: 20),

          ],
         ), ),
            ]
      ),
    );
  }
}

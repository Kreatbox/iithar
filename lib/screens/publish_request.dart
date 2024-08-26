import 'package:flutter/material.dart';

class PublishRequest extends StatefulWidget {
  const PublishRequest({super.key});

  @override
  _PublishRequestState createState() => _PublishRequestState();
}

class _PublishRequestState extends State<PublishRequest> {
  String? _selectedBloodType;
  String? _selectedCity;
  String? _selectedBloodBank;
  String? _selectedMedicalCondition;
  TextEditingController _otherConditionController = TextEditingController();
  TextEditingController _dateTimeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: Text('نشر طلب بحاجة إلى دم ',
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontFamily: 'HSI', fontSize: 40, color: Colors.black)),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildRequestField(Icons.person, 'الاسم كاملاً '),
              _buildBloodTypeDialog(),
              _buildCityDialog(),
              _buildBloodBankDialog(),
              _buildMedicalConditionDialog(),
              _buildRequestField(Icons.phone, 'رقم الهاتف'),
              _buildDateTimeField(
                  Icons.access_time, 'تاريخ ووقت التبرع الممكن'),
              _buildRequestField(Icons.note, 'أضف ملاحظة'),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  fixedSize: Size(175, 45),
                  backgroundColor: const Color(0xFFAE0E03),
                  padding: const EdgeInsets.only(
                      right: 25.0, left: 25.0, top: 5.0, bottom: 1.0),
                  alignment: Alignment.center,
                ),
                onPressed: () {},
                child: Text(
                  'نشر الطلب ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'HSI', fontSize: 25, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCityDialog() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: () {
          _showCityDialog();
        },
        child: AbsorbPointer(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.location_on, color: Color(0xFFAE0E03)),
                labelText: _selectedCity ?? 'المدينة',
                labelStyle: TextStyle(
                  fontFamily: 'HSI',
                  fontSize: 18,
                  color: Colors.grey,),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
              style: const TextStyle(
                fontFamily: 'HSI',
                fontSize: 15,
                color: Colors.black,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ),
      ),
    );
  }

  void _showCityDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          backgroundColor: Colors.white,
          title: Text(
            'اختر المدينة',style: const TextStyle(
            fontFamily: 'HSI',
            fontSize: 25,
            color: Colors.black,
          ),
            textAlign: TextAlign.center,
          ),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                setState(() {
                  _selectedCity = 'حمص';
                });
                Navigator.pop(context);
              },
              child: const Text('حمص',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontFamily: 'HSI',
                  fontSize: 15,
                  color: Colors.black,
                ),),
            ),
            SimpleDialogOption(
              onPressed: () {
                setState(() {
                  _selectedCity = 'دمشق';
                });
                Navigator.pop(context);
              },
              child: const Text('دمشق',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontFamily: 'HSI',
                  fontSize: 15,
                  color: Colors.black,
                ),),
            ),
            SimpleDialogOption(
              onPressed: () {
                setState(() {
                  _selectedCity = 'حلب';
                });
                Navigator.pop(context);
              },
              child: const Text('حلب',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontFamily: 'HSI',
                  fontSize: 15,
                  color: Colors.black,
                ),),
            ),
            SimpleDialogOption(
              onPressed: () {
                setState(() {
                  _selectedCity = 'حماة';
                });
                Navigator.pop(context);
              },
              child: const Text('حماة',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontFamily: 'HSI',
                  fontSize: 15,
                  color: Colors.black,
                ),),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBloodBankDialog() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: () {
          _showBloodBankDialog();
        },
        child: AbsorbPointer(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: TextField(
              decoration: InputDecoration(
                prefixIcon:
                    Icon(Icons.local_hospital, color: Color(0xFFAE0E03)),
                labelText: _selectedBloodBank ?? 'موقع التبرع',
                labelStyle: TextStyle(
                  fontFamily: 'HSI',
                  fontSize: 18,
                  color: Colors.grey,),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ),
      ),
    );
  }

  void _showBloodBankDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          backgroundColor: Colors.white,
          title: Text('اختر موقع التبرع',
            textAlign: TextAlign.center,
            style: const TextStyle(
            fontFamily: 'HSI',
            fontSize: 25,
            color: Colors.black,
          ),),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                setState(() {
                  _selectedBloodBank = 'بنك الدم في حمص';
                });
                Navigator.pop(context);
              },
              child: const Text('بنك الدم في حمص',
              textAlign: TextAlign.right,
              style: const TextStyle(
              fontFamily: 'HSI',
              fontSize: 15,
              color: Colors.black,),
            ),),
            SimpleDialogOption(
              onPressed: () {
                setState(() {
                  _selectedBloodBank = 'بنك الدم في حماة';
                });
                Navigator.pop(context);
              },
              child: const Text('بنك الدم في حماة',textAlign: TextAlign.right,
                style: const TextStyle(
                  fontFamily: 'HSI',
                  fontSize: 15,
                  color: Colors.black,),),
            ),
            SimpleDialogOption(
              onPressed: () {
                setState(() {
                  _selectedBloodBank = 'بنك الدم في دمشق';
                });
                Navigator.pop(context);
              },
              child: const Text('بنك الدم في دمشق',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontFamily: 'HSI',
                  fontSize: 15,
                  color: Colors.black,),),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBloodTypeDialog() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: () {
          _showBloodTypeDialog();
        },
        child: AbsorbPointer(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.bloodtype, color: Color(0xFFAE0E03)),
                labelText: _selectedBloodType ?? 'زمرة الدم المطلوبة',
                labelStyle: TextStyle(
                  fontFamily: 'HSI',
                  fontSize: 18,
                  color: Colors.grey,),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ),
      ),
    );
  }

  void _showBloodTypeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          backgroundColor: Colors.white,
          title: Text('اختر زمرة الدم',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'HSI',
              fontSize: 25,
              color: Colors.black,),),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                setState(() {
                  _selectedBloodType = 'A+';
                });
                Navigator.pop(context);
              },
              child: const Text('A+',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontFamily: 'HSI',
                  fontSize: 15,
                  color: Colors.black,),),
            ),
            SimpleDialogOption(
              onPressed: () {
                setState(() {
                  _selectedBloodType = 'A-';
                });
                Navigator.pop(context);
              },
              child: const Text('A-',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontFamily: 'HSI',
                  fontSize: 15,
                  color: Colors.black,),),
            ),
            SimpleDialogOption(
              onPressed: () {
                setState(() {
                  _selectedBloodType = 'B+';
                });
                Navigator.pop(context);
              },
              child: const Text('B+',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontFamily: 'HSI',
                  fontSize: 15,
                  color: Colors.black,),),
            ),
            SimpleDialogOption(
              onPressed: () {
                setState(() {
                  _selectedBloodType = 'B-';
                });
                Navigator.pop(context);
              },
              child: const Text('B-',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontFamily: 'HSI',
                  fontSize: 15,
                  color: Colors.black,),),
            ),
            SimpleDialogOption(
              onPressed: () {
                setState(() {
                  _selectedBloodType = 'O+';
                });
                Navigator.pop(context);
              },
              child: const Text('O+',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontFamily: 'HSI',
                  fontSize: 15,
                  color: Colors.black,),),
            ),
            SimpleDialogOption(
              onPressed: () {
                setState(() {
                  _selectedBloodType = 'O-';
                });
                Navigator.pop(context);
              },
              child: const Text('O-',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontFamily: 'HSI',
                  fontSize: 15,
                  color: Colors.black,),),
            ),
            SimpleDialogOption(
              onPressed: () {
                setState(() {
                  _selectedBloodType = 'AB+';
                });
                Navigator.pop(context);
              },
              child: const Text('AB+',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontFamily: 'HSI',
                  fontSize: 15,
                  color: Colors.black,),),
            ),
            SimpleDialogOption(
              onPressed: () {
                setState(() {
                  _selectedBloodType = 'AB-';
                });
                Navigator.pop(context);
              },
              child: const Text('AB-',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontFamily: 'HSI',
                  fontSize: 15,
                  color: Colors.black,),),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMedicalConditionDialog() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              _showMedicalConditionDialog();
            },
            child: AbsorbPointer(
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.medical_services, color: Color(0xFFAE0E03)),
                    labelText: _selectedMedicalCondition ?? 'الحالة الطبية',
                    labelStyle: TextStyle(
                      fontFamily: 'HSI',
                      fontSize: 18,
                      color: Colors.grey,),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ),
          ),
          if (_selectedMedicalCondition == 'أخرى')
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: TextField(
                  controller: _otherConditionController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.note_add, color: Color(0xFFAE0E03)),
                    labelText: 'يرجى توضيح الحالة الطبية ',
                    labelStyle: TextStyle(
                      fontFamily: 'HSI',
                      fontSize: 18,
                      color: Colors.grey,),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ),
        ],
      ),
    );
  }


  void _showMedicalConditionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          backgroundColor:  Colors.white,
          title: Text('اختر الحالة الطبية',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'HSI',
              fontSize: 25,
              color: Colors.black,),),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                setState(() {
                  _selectedMedicalCondition = 'حادث';
                });
                Navigator.pop(context);
              },
              child: const Text('حادث',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontFamily: 'HSI',
                  fontSize: 15,
                  color: Colors.black,),),
            ),
            SimpleDialogOption(
              onPressed: () {
                setState(() {
                  _selectedMedicalCondition = 'مرض مزمن';
                });
                Navigator.pop(context);
              },
              child: const Text('مرض مزمن',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontFamily: 'HSI',
                  fontSize: 15,
                  color: Colors.black,),),
            ),
            SimpleDialogOption(
              onPressed: () {
                setState(() {
                  _selectedMedicalCondition = 'عملية جراحية';
                });
                Navigator.pop(context);
              },
              child: const Text('عملية جراحية',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontFamily: 'HSI',
                  fontSize: 15,
                  color: Colors.black,),),
            ),
            SimpleDialogOption(
              onPressed: () {
                setState(() {
                  _selectedMedicalCondition = 'ولادة';
                });
                Navigator.pop(context);
              },
              child: const Text('ولادة',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontFamily: 'HSI',
                  fontSize: 15,
                  color: Colors.black,),),
            ),
            SimpleDialogOption(
              onPressed: () {
                setState(() {
                  _selectedMedicalCondition = 'أخرى';
                });
                Navigator.pop(context);
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end
                ,
                children: [
                  const Text('أخرى',
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontFamily: 'HSI',
                      fontSize: 15,
                      color: Colors.black,),),

                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRequestField(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: TextField(
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Color(0xFFAE0E03)),
            labelText: label,
            labelStyle: TextStyle(
              fontFamily: 'HSI',
              fontSize: 18,
              color: Colors.grey,),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          textAlign: TextAlign.right,
        ),
      ),
    );
  }

  Widget _buildDateTimeField(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: () {
          _selectDateTime();
        },
        child: AbsorbPointer(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: TextField(
              controller: _dateTimeController,
              decoration: InputDecoration(

                prefixIcon: Icon(icon, color: Color(0xFFAE0E03)),
                labelText: label,
                labelStyle: TextStyle(
                  fontFamily: 'HSI',
                  fontSize: 18,
                  color: Colors.grey,),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),

      builder: (BuildContext context, Widget? child){
        return Theme(data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: Color(0xFFAE0E03),
            onPrimary: Colors.black,
            onSurface: Colors.black,
          ),
          dialogBackgroundColor: Colors.white,
        ), child:  child!
        );
      }
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
          builder: (BuildContext context, Widget? child){
            return Theme(data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: Color(0xFFAE0E03),
                onPrimary: Colors.black,
                onSurface: Colors.black,
              ),
              dialogBackgroundColor: Colors.white,
              timePickerTheme: TimePickerThemeData(
                dayPeriodTextColor: Colors.black,
                dayPeriodColor: WidgetStateColor.resolveWith((Set<WidgetState> states) {
                  if (states.contains(WidgetState.selected)) {
                    return Color(0xFFAE0E03);
                  }
                  return Colors.white;
                }),
              ),
            ), child:  child!
            );
          }
      );

      if (pickedTime != null) {
        final DateTime pickedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        setState(() {
          _dateTimeController.text = pickedDateTime.toString();
        });
      }
    }
  }
}

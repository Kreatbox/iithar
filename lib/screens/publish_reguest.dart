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
  String? _selectedUrgency;
  String? _selectedMedicalCondition;
  TextEditingController _otherConditionController = TextEditingController();
  TextEditingController _dateTimeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('انشر طلب بحاجة دم'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildRequestField(Icons.person, 'اسم المريض'),
              _buildBloodTypeDialog(),
              _buildCityDialog(),
              _buildBloodBankDialog(),
              _buildMedicalConditionDialog(),
              if (_selectedMedicalCondition == 'أخرى')
                _buildOtherMedicalConditionField(),
              _buildRequestField(Icons.phone, 'رقم الهاتف'),
              _buildDateTimeField(Icons.access_time, 'وقت التبرع الممكن'),
              _buildUrgencyDialog(),
              _buildRequestField(Icons.note, 'أضف ملاحظة'),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {},
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
          child: TextField(
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.location_on, color: Color(0xFFAE0E03)),
              labelText: _selectedCity ?? 'المدينة',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
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
          title: Text('اختر المدينة'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                setState(() {
                  _selectedCity = 'حمص';
                });
                Navigator.pop(context);
              },
              child: const Text('حمص'),
            ),
            SimpleDialogOption(
              onPressed: () {
                setState(() {
                  _selectedCity = 'دمشق';
                });
                Navigator.pop(context);
              },
              child: const Text('دمشق'),
            ),
            SimpleDialogOption(
              onPressed: () {
                setState(() {
                  _selectedCity = 'حلب';
                });
                Navigator.pop(context);
              },
              child: const Text('حلب'),
            ),
            SimpleDialogOption(
              onPressed: () {
                setState(() {
                  _selectedCity = 'حماة';
                });
                Navigator.pop(context);
              },
              child: const Text('حماة'),
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
          child: TextField(
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.local_hospital, color: Color(0xFFAE0E03)),
              labelText: _selectedBloodBank ?? 'موقع التبرع',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
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
          title: Text('اختر موقع التبرع',),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                setState(() {
                  _selectedBloodBank = 'بنك الدم في حمص';
                });
                Navigator.pop(context);
              },
              child: const Text('بنك الدم في حمص'),
            ),
            SimpleDialogOption(
              onPressed: () {
                setState(() {
                  _selectedBloodBank = 'بنك الدم في حماة';
                });
                Navigator.pop(context);
              },
              child: const Text('بنك الدم في حماة'),
            ),
            SimpleDialogOption(
              onPressed: () {
                setState(() {
                  _selectedBloodBank = 'بنك الدم في دمشق';
                });
                Navigator.pop(context);
              },
              child: const Text('بنك الدم في دمشق'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildUrgencyDialog() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: () {
          _showUrgencyDialog();
        },
        child: AbsorbPointer(
          child: TextField(
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.priority_high, color: Color(0xFFAE0E03)),
              labelText: _selectedUrgency ?? 'أهمية التبرع',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showUrgencyDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text('اختر أهمية التبرع'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                setState(() {
                  _selectedUrgency = 'مستعجل';
                });
                Navigator.pop(context);
              },
              child: const Text('مستعجل'),
            ),
            SimpleDialogOption(
              onPressed: () {
                setState(() {
                  _selectedUrgency = 'طارئ';
                });
                Navigator.pop(context);
              },
              child: const Text('طارئ'),
            ),
            SimpleDialogOption(
              onPressed: () {
                setState(() {
                  _selectedUrgency = 'قليل الأهمية';
                });
                Navigator.pop(context);
              },
              child: const Text('قليل الأهمية'),
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
          child: TextField(
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.bloodtype, color: Color(0xFFAE0E03)),
              labelText: _selectedBloodType ?? 'زمرة الدم المطلوبة',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
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
          title: Text('اختر زمرة الدم'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                setState(() {
                  _selectedBloodType = 'A+';
                });
                Navigator.pop(context);
              },
              child: const Text('A+'),
            ),
            SimpleDialogOption(
              onPressed: () {
                setState(() {
                  _selectedBloodType = 'A-';
                });
                Navigator.pop(context);
              },
              child: const Text('A-'),
            ),
            SimpleDialogOption(
              onPressed: () {
                setState(() {
                  _selectedBloodType = 'B+';
                });
                Navigator.pop(context);
              },
              child: const Text('B+'),
            ),
            SimpleDialogOption(
              onPressed: () {
                setState(() {
                  _selectedBloodType = 'B-';
                });
                Navigator.pop(context);
              },
              child: const Text('B-'),
            ),
            SimpleDialogOption(
              onPressed: () {
                setState(() {
                  _selectedBloodType = 'AB+';
                });
                Navigator.pop(context);
              },
              child: const Text('AB+'),
            ),
            SimpleDialogOption(
              onPressed: () {
                setState(() {
                  _selectedBloodType = 'AB-';
                });
                Navigator.pop(context);
              },
              child: const Text('AB-'),
            ),
            SimpleDialogOption(
              onPressed: () {
                setState(() {
                  _selectedBloodType = 'O+';
                });
                Navigator.pop(context);
              },
              child: const Text('O+'),
            ),
            SimpleDialogOption(
              onPressed: () {
                setState(() {
                  _selectedBloodType = 'O-';
                });
                Navigator.pop(context);
              },
              child: const Text('O-'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMedicalConditionDialog() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: () {
          _showMedicalConditionDialog();
        },
        child: AbsorbPointer(
          child: TextField(
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.medical_services, color: Color(0xFFAE0E03)),
              labelText: _selectedMedicalCondition ?? 'الحالة الطبية',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showMedicalConditionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text('اختر الحالة الطبية'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                setState(() {
                  _selectedMedicalCondition = 'جراحة';
                });
                Navigator.pop(context);
              },
              child: const Text('جراحة'),
            ),
            SimpleDialogOption(
              onPressed: () {
                setState(() {
                  _selectedMedicalCondition = 'حادث';
                });
                Navigator.pop(context);
              },
              child: const Text('حادث'),
            ),
            SimpleDialogOption(
              onPressed: () {
                setState(() {
                  _selectedMedicalCondition = 'مرض مزمن';
                });
                Navigator.pop(context);
              },
              child: const Text('مرض مزمن'),
            ),
            SimpleDialogOption(
              onPressed: () {
                setState(() {
                  _selectedMedicalCondition = 'أخرى';
                });
                Navigator.pop(context);
              },
              child: const Text('أخرى'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOtherMedicalConditionField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: _otherConditionController,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.edit, color: Color(0xFFAE0E03)),
          labelText: 'أدخل الحالة الأخرى',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _buildRequestField(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Color(0xFFAE0E03)),
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimeField(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        readOnly: true,
        controller: _dateTimeController,
        onTap: () {
          _selectDateTime(context);
        },
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Color(0xFFAE0E03)),
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        keyboardType: TextInputType.datetime,
      ),
    );
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );
    if (picked != null) {
      final TimeOfDay? timePicked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (timePicked != null) {
        setState(() {
          _dateTimeController.text =
              '${picked.year}-${picked.month}-${picked.day} ${timePicked.hour}:${timePicked.minute}';
        });
      }
    }
  }
}

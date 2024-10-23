// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:iithar/models/blood_bank.dart';
import 'package:iithar/services/data_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PublishRequest extends StatefulWidget {
  const PublishRequest({super.key});

  @override
  PublishRequestState createState() => PublishRequestState();
}

class PublishRequestState extends State<PublishRequest> {
  List<BloodBank> _bloodBanks = [];
  bool _isLoadingBloodBanks = true;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  String? _selectedBloodType;
  String? _selectedBloodBank;
  String? _selectedBloodBankId;
  String? _selectedMedicalCondition;
  final TextEditingController _otherConditionController =
      TextEditingController();
  final TextEditingController _dateTimeController = TextEditingController();

  DateTime now = DateTime.now();
  @override
  void initState() {
    super.initState();
    _loadBloodBanks();
  }

  Future<void> _loadBloodBanks() async {
    DataService dataService = DataService();
    List<BloodBank> banks = await dataService.loadBankData();
    setState(() {
      _bloodBanks = banks;
      _isLoadingBloodBanks = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Expanded(
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
              _buildRequestField(Icons.person, 'الاسم كاملاً', _nameController),
              _buildBloodTypeDialog(),
              _buildBloodBankDialog(),
              _buildMedicalConditionDialog(),
              _buildRequestField(Icons.phone, 'رقم الهاتف', _phoneController),
              _buildDateTimeField(
                  Icons.access_time, 'تاريخ ووقت التبرع الممكن'),
              _buildRequestField(Icons.note, 'أضف ملاحظة', _noteController),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  fixedSize: const Size(175, 45),
                  backgroundColor: const Color(0xFFAE0E03),
                  padding: const EdgeInsets.only(
                      right: 25.0, left: 25.0, top: 5.0, bottom: 1.0),
                  alignment: Alignment.center,
                ),
                onPressed: _saveRequest,
                child: const Text(
                  'نشر الطلب ',
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
        ),
      ),
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
                    const Icon(Icons.local_hospital, color: Color(0xFFAE0E03)),
                labelText: _selectedBloodBank ?? 'موقع التبرع',
                labelStyle: const TextStyle(
                  fontFamily: 'HSI',
                  fontSize: 18,
                  color: Colors.grey,
                ),
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
        title: Column(
          children: [
            const Text(
              'اختر موقع التبرع',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'HSI',
                fontSize: 25,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10), 
            const Divider(color: Colors.grey), 
          ],
        ),
          children: _isLoadingBloodBanks
              ? [const Center(child: CircularProgressIndicator())]
              : _bloodBanks.map((bloodBank) {
                  return SimpleDialogOption(
                    onPressed: () {
                      setState(() {
                        _selectedBloodBank = bloodBank.name;
                        _selectedBloodBankId = bloodBank.bankId;
                      });
                      Navigator.pop(context);
                    },
                    child: Text(
                      bloodBank.name,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontFamily: 'HSI',
                        fontSize: 15,
                        color: Colors.black,
                      ),
                    ),
                  );
                }).toList(),
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
                prefixIcon:
                    const Icon(Icons.bloodtype, color: Color(0xFFAE0E03)),
                labelText: _selectedBloodType ?? 'زمرة الدم المطلوبة',
                labelStyle: const TextStyle(
                  fontFamily: 'HSI',
                  fontSize: 18,
                  color: Colors.grey,
                ),
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

  Future<bool> _canPublishRequest() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    String? userId = currentUser?.uid;

    if (userId == null) {
      return false;
    }

    // Get the user's last request
    QuerySnapshot requestSnapshot = await FirebaseFirestore.instance
        .collection('requests')
        .where('userId', isEqualTo: userId)
        .orderBy('dateTime', descending: true)
        .limit(1)
        .get();
    debugPrint('${requestSnapshot.docs}');
    if (requestSnapshot.docs.isNotEmpty) {
      var lastRequest = requestSnapshot.docs.first;
      String lastCondition = lastRequest['medicalCondition'] ?? '';
      String? dateTimeString = lastRequest['dateTime'];
      DateTime lastDateTime = DateTime.parse(dateTimeString!);

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .get();

      // Check if the 'role' field exists
      if (userDoc.exists && userDoc.data() != null) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        if (userData.containsKey('points')) {
          int points = userData['points'];
          debugPrint('$points');
          if (points < -10) {
            return false;
          }
        }
      }

      // Check if the medical condition is "مرض مزمن"
      if (lastCondition == 'مرض مزمن') {
        return true;
      }

      // Check if the last appointment was more than 30 days ago
      DateTime now = DateTime.now();
      if (now.difference(lastDateTime).inDays > 1) {
        return true;
      }
    } else {
      return false;
    }

    return false;
  }

  void _showBloodTypeDialog() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'اختر زمرة الدم',
               textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'HSI',
                fontSize: 25,
                color: Colors.black,
              ),
            ),
              
              SizedBox(height: 20), 
              Divider(color: Colors.grey), 
              ListTile(
                title: Text(
                  'A+',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontFamily: 'HSI',
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                onTap: () {
                  setState(() {
                    _selectedBloodType = 'A+';
                  });
                  Navigator.pop(context);
                },
                leading: Icon(Icons.water_drop,   color: Color(0xFFAE0E03)),
              ),
              ListTile(
                title: Text(
                  'A-',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontFamily: 'HSI',
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                onTap: () {
                  setState(() {
                    _selectedBloodType = 'A-';
                  });
                  Navigator.pop(context);
                },
                leading: Icon(Icons.water_drop,   color: Color(0xFFAE0E03)),
              ),
              ListTile(
                title: Text(
                  'B+',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontFamily: 'HSI',
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                onTap: () {
                  setState(() {
                    _selectedBloodType = 'B+';
                  });
                  Navigator.pop(context);
                },
                leading: Icon(Icons.water_drop,   color: Color(0xFFAE0E03)),
              ),
              ListTile(
                title: Text(
                  'B-',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontFamily: 'HSI',
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                onTap: () {
                  setState(() {
                    _selectedBloodType = 'B-';
                  });
                  Navigator.pop(context);
                },
                leading: Icon(Icons.water_drop,   color: Color(0xFFAE0E03)),
              ),
              ListTile(
                title: Text(
                  'O+',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontFamily: 'HSI',
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                onTap: () {
                  setState(() {
                    _selectedBloodType = 'O+';
                  });
                  Navigator.pop(context);
                },
                leading: Icon(Icons.water_drop,   color: Color(0xFFAE0E03)),
              ),
              ListTile(
                title: Text(
                  'O-',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontFamily: 'HSI',
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                onTap: () {
                  setState(() {
                    _selectedBloodType = 'O-';
                  });
                  Navigator.pop(context);
                },
                leading: Icon(Icons.water_drop,   color: Color(0xFFAE0E03)),
              ),
              ListTile(
                title: Text(
                  'AB+',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontFamily: 'HSI',
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                onTap: () {
                  setState(() {
                    _selectedBloodType = 'AB+';
                  });
                  Navigator.pop(context);
                },
                leading: Icon(Icons.water_drop,   color: Color(0xFFAE0E03)),
              ),
              ListTile(
                title: Text(
                  'AB-',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontFamily: 'HSI',
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                onTap: () {
                  setState(() {
                    _selectedBloodType = 'AB-';
                  });
                  Navigator.pop(context);
                },
                leading: Icon(Icons.water_drop,   color: Color(0xFFAE0E03)),
              ),
            ],
          ),
        ),
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
                    prefixIcon: const Icon(Icons.medical_services,
                        color: Color(0xFFAE0E03)),
                    labelText: _selectedMedicalCondition ?? 'الحالة الطبية',
                    labelStyle: const TextStyle(
                      fontFamily: 'HSI',
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15)),
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
                    prefixIcon:
                        const Icon(Icons.note_add, color: Color(0xFFAE0E03)),
                    labelText: 'يرجى توضيح الحالة الطبية ',
                    labelStyle: const TextStyle(
                      fontFamily: 'HSI',
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                    
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
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'اختر الحالة الطبية',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'HSI',
                fontSize: 25,
                color: Colors.black,
              ),
            ),
              SizedBox(height: 20), 
              Divider(color: Colors.grey),
              ListTile(
                title: Text(
                  'حادث',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontFamily: 'HSI',
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                onTap: () {
                  setState(() {
                    _selectedMedicalCondition = 'حادث';
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text(
                  'مرض مزمن',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontFamily: 'HSI',
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                onTap: () {
                  setState(() {
                    _selectedMedicalCondition = 'مرض مزمن';
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text(
                  'عملية جراحية',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontFamily: 'HSI',
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                onTap: () {
                  setState(() {
                    _selectedMedicalCondition = 'عملية جراحية';
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text(
                  'ولادة',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontFamily: 'HSI',
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                onTap: () {
                  setState(() {
                    _selectedMedicalCondition = 'ولادة';
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text(
                  'أخرى',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontFamily: 'HSI',
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                onTap: () {
                  setState(() {
                    _selectedMedicalCondition = 'أخرى';
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}


  Widget _buildRequestField(
      IconData icon, String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: TextField(
          controller: controller, // Use the provided controller
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFFAE0E03)),
            labelText: label,
            labelStyle: const TextStyle(
              fontFamily: 'HSI',
              fontSize: 18,
              color: Colors.grey,
            ),
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
                prefixIcon: Icon(icon, color: const Color(0xFFAE0E03)),
                labelText: label,
                labelStyle: const TextStyle(
                  fontFamily: 'HSI',
                  fontSize: 18,
                  color: Colors.grey,
                ),
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

  Future<void> _saveRequest() async {
    // Ensure all required fields are filled
    if (_selectedBloodType == null ||
        _selectedBloodBank == null ||
        _selectedMedicalCondition == null ||
        _dateTimeController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'خطأ',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 20, fontFamily: 'BAHIJ', color: Colors.black),
            ),
            content: const Text(
              'يرجى ملء جميع الحقول المطلوبة',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 20, fontFamily: 'BAHIJ', color: Colors.black),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'حسناً',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'HSI', fontSize: 20, color: Colors.black),
                ),
              ),
            ],
          );
        },
      );
      return;
    }

    bool canPublish = await _canPublishRequest();

    if (!canPublish) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('خطأ'),
            content: const Text(
                'لا يمكنك نشر الطلب. لم تقم بتوثيق حاجتك للدم منذ آخر فترة', style: TextStyle(
                      fontFamily: 'HSI', fontSize: 20, color: Colors.black),),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('حسناً'),
              ),
            ],
          );
        },
      );
      return;
    }
    // Retrieve user information
    User? currentUser = FirebaseAuth.instance.currentUser;
    String? userId = currentUser?.uid;

    if (userId == null) {
      // If userId is null, show error
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('خطأ'),
            content: const Text('تعذر العثور على معرف المستخدم', style: TextStyle(
                      fontFamily: 'HSI', fontSize: 20, color: Colors.black),),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('حسناً'),
              ),
            ],
          );
        },
      );
      return;
    }

    String name = _nameController.text.trim();
    String phone = _phoneController.text.trim();
    String note = _noteController.text.trim();
    String bloodType = _selectedBloodType!;
    String bankId = _selectedBloodBankId!;
    String medicalCondition = _selectedMedicalCondition!;
    String otherCondition = _otherConditionController.text.trim();
    String dateTime = _dateTimeController.text.trim();

    Map<String, dynamic> requestData = {
      'userId': userId, // Add userId to the request data
      'name': name,
      'phone': phone,
      'note': note,
      'bloodType': bloodType,
      'bankId': bankId,
      'medicalCondition': medicalCondition,
      'otherCondition': otherCondition,
      'dateTime': dateTime,
      'state': '0'
    };

    try {
      await FirebaseFirestore.instance.collection('requests').add(requestData);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('نجاح'),
            content: const Text('تم نشر طلبك بنجاح'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('حسناً'),
              ),
            ],
          );
        },
      );

      Duration difference = DateTime.parse(dateTime).difference(now);

      if (difference.inHours <= 24 && difference.isNegative == false) {
        // هذا الطلب في غضون الـ 24 ساعة القادمة
        sendUrgentNotification(requestData); // إرسال إشعار
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('خطأ'),
            content: Text('حدث خطأ أثناء نشر طلبك: $e'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('حسناً'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> sendUrgentNotification(Map<String, dynamic> requestData) async {
    final url = Uri.parse(
        'YOUR_CLOUD_FUNCTION_URL'); // Replace with your deployed Cloud Function URL after activation

    final messageData = {
      "title": "طلب تبرع عاجل!",
      "body":
          "طلب تبرع عاجل للدم من نوع ${requestData['bloodType']} في الموقع ${requestData['location']}.",
      "data": {"requestId": requestData['id']},
      "topic": "urgent_requests", // تحديد الموضوع
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(messageData),
      );

      if (response.statusCode == 200) {
        debugPrint('Notification sent successfully!');
      } else {
        debugPrint(
            'Failed to send notification: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      debugPrint('Error sending notification: $e');
    }
  }

  Future<void> _selectDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
        builder: (BuildContext context, Widget? child) {
          return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Color(0xFFAE0E03),
                  onPrimary: Colors.black,
                  onSurface: Colors.black,
                ),
                dialogBackgroundColor: Colors.white,
              ),
              child: child!);
        });

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
          builder: (BuildContext context, Widget? child) {
            return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: Color(0xFFAE0E03),
                    onPrimary: Colors.black,
                    onSurface: Colors.black,
                  ),
                  dialogBackgroundColor: Colors.white,
                  timePickerTheme: TimePickerThemeData(
                    dayPeriodTextColor: Colors.black,
                    dayPeriodColor:
                        WidgetStateColor.resolveWith((Set<WidgetState> states) {
                      if (states.contains(WidgetState.selected)) {
                        return const Color(0xFFAE0E03);
                      }
                      return Colors.white;
                    }),
                  ),
                ),
                child: child!);
          });

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

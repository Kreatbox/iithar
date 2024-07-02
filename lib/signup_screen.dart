import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;

  //  متغيرات للتحكم في الحقول النصية
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _ssidController = TextEditingController();
  final _birthDateController = TextEditingController();
  String _selectedBloodType = 'A+'; //  قيمة افتراضية لنوع الدم

  @override
  void dispose() {
    //  التخلص من وحدات التحكم عند انتهاء الصفحة
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneNumberController.dispose();
    _ssidController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إنشاء حساب'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              //  حقول إدخال البيانات
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'الاسم الأول'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال اسمك الأول';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'اسم العائلة'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال اسم عائلتك';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'البريد الإلكتروني'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال بريدك الإلكتروني';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'كلمة المرور'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال كلمة المرور';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _phoneNumberController,
                decoration: const InputDecoration(labelText: 'رقم الهاتف'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال رقم هاتفك';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _ssidController,
                decoration: const InputDecoration(labelText: 'الرقم القومي'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال رقمك القومي';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _birthDateController,
                decoration: const InputDecoration(labelText: 'تاريخ الميلاد'),
                keyboardType: TextInputType.datetime,
                //  يمكنك إضافة DateTimePicker هنا
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال تاريخ ميلادك';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _selectedBloodType,
                decoration: const InputDecoration(labelText: 'فصيلة الدم'),
                items: <String>[
                  'A+',
                  'A-',
                  'B+',
                  'B-',
                  'AB+',
                  'AB-',
                  'O+',
                  'O-',
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedBloodType = newValue!;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    //  إنشاء حساب جديد
                    try {
                      UserCredential userCredential =
                      await _auth.createUserWithEmailAndPassword(
                          email: _emailController.text,
                          password: _passwordController.text);

                      //  حفظ بيانات المستخدم في Firestore
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(userCredential.user!.uid)
                          .set({
                        'firstName': _firstNameController.text,
                        'lastName': _lastNameController.text,
                        'email': _emailController.text,
                        'phoneNumber': _phoneNumberController.text,
                        'ssid': _ssidController.text,
                        'birthDate': _birthDateController.text,
                        'bloodType': _selectedBloodType,
                      });

                      //  الانتقال إلى الشاشة الرئيسية
                      Navigator.pushReplacementNamed(context, '/home');
                    } catch (e) {
                      if (kDebugMode) {
                        print('فشل إنشاء الحساب: ${e.toString()}');
                      }
                      //  عرض رسالة خطأ للمستخدم
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('فشل إنشاء الحساب')),
                      );
                    }
                  }
                },
                child: const Text('إنشاء حساب'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

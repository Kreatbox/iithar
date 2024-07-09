import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../navigation_menu.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;

  // Text controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _ssidController = TextEditingController();
  final _birthDateController = TextEditingController();
  String _selectedBloodType = 'A+';

  @override
  void dispose() {
    // Dispose controllers when the page is disposed
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
              // Input fields
              _buildTextField(
                  _firstNameController, 'الاسم الأول', 'يرجى إدخال اسمك الأول'),
              _buildTextField(
                  _lastNameController, 'اسم العائلة', 'يرجى إدخال اسم عائلتك'),
              _buildTextField(_emailController, 'البريد الإلكتروني',
                  'يرجى إدخال بريدك الإلكتروني',
                  isEmail: true),
              _buildTextField(
                  _passwordController, 'كلمة المرور', 'يرجى إدخال كلمة المرور',
                  isPassword: true),
              _buildTextField(
                  _phoneNumberController, 'رقم الهاتف', 'يرجى إدخال رقم هاتفك',
                  isPhone: true),
              _buildTextField(
                  _ssidController, 'الرقم القومي', 'يرجى إدخال رقمك القومي',
                  isNumber: true),
              _buildTextField(_birthDateController, 'تاريخ الميلاد',
                  'يرجى إدخال تاريخ ميلادك',
                  isDate: true),
              _buildDropdownField(),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    // Create a new account
                    try {
                      UserCredential userCredential =
                          await _auth.createUserWithEmailAndPassword(
                        email: _emailController.text,
                        password: _passwordController.text,
                      );

                      // Save user data in Firestore
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
                      // Navigate to the donation form screen
                      Navigator.pushReplacementNamed(context, '/form');
                    } catch (e) {
                      if (kDebugMode) {
                        print('فشل إنشاء الحساب: ${e.toString()}');
                      }
                      // Show error message to the user
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

  Widget _buildTextField(
      TextEditingController controller, String labelText, String errorText,
      {bool isEmail = false,
      bool isPassword = false,
      bool isPhone = false,
      bool isNumber = false,
      bool isDate = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      obscureText: isPassword,
      keyboardType: isEmail
          ? TextInputType.emailAddress
          : isPhone
              ? TextInputType.phone
              : isNumber
                  ? TextInputType.number
                  : isDate
                      ? TextInputType.datetime
                      : TextInputType.text,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return errorText;
        }
        return null;
      },
    );
  }

  Widget _buildDropdownField() {
    return DropdownButtonFormField<String>(
      value: _selectedBloodType,
      decoration: InputDecoration(
        labelText: 'فصيلة الدم',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      items: <String>['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
          .map((String value) {
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
    );
  }
}

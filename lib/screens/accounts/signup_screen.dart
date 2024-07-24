// ignore_for_file: use_build_context_synchronously, prefer_const_literals_to_create_immutables

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
  var _isButtonDisabled = false;
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _ssidController = TextEditingController();
  final _birthDateController = TextEditingController();

  // Ensure default values exist in the dropdown lists
  final List<String> _bloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-'
  ];
  final List<String> _genderTypes = ['ذكر', 'انثى'];

  // Default values
  String _selectedBloodType = 'A+';
  String _selectedGenderType = 'ذكر';

  @override
  void initState() {
    super.initState();
    // Verify default values
    if (!_bloodTypes.contains(_selectedBloodType)) {
      _selectedBloodType = _bloodTypes.first;
    }
    if (!_genderTypes.contains(_selectedGenderType)) {
      _selectedGenderType = _genderTypes.first;
    }
  }

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Align(
          alignment: Alignment.centerRight,
          child: Text(
            'إنشاء حساب ',
            textAlign: TextAlign.right,
            style:
                TextStyle(fontFamily: 'HSI', fontSize: 40, color: Colors.black),
          ),
        ),
      ),
      body: Stack(children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                _buildInfoSection('المعلومات الشخصية', [
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(_lastNameController,
                            'اسم العائلة', 'يرجى إدخال اسم عائلتك'),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildTextField(_firstNameController,
                            'الاسم الأول', 'يرجى إدخال اسمك الأول'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(
                      _ssidController, 'الرقم الوطني', 'يرجى إدخال رقمك القومي',
                      isNumber: true),
                  const SizedBox(height: 10),
                  _buildTextField(_phoneNumberController, 'رقم الهاتف',
                      'يرجى إدخال رقم هاتفك',
                      isPhone: true),
                  const SizedBox(height: 10),
                  _buildTextField(_birthDateController, 'تاريخ الميلاد',
                      'يرجى إدخال تاريخ ميلادك',
                      isDate: true),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdownField(),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: _buildDropdownFieldGender())
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(_emailController, 'البريد الإلكتروني',
                      'يرجى إدخال بريدك الإلكتروني',
                      isEmail: true),
                  const SizedBox(height: 10),
                  _buildTextField(_passwordController, 'كلمة المرور',
                      'يرجى إدخال كلمة المرور',
                      isPassword: true),
                  const SizedBox(height: 10),
                ]),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      fixedSize: const Size(175, 45),
                      backgroundColor: const Color(0xFFAE0E03),
                      padding: const EdgeInsets.only(
                          right: 25.0, left: 25.0, top: 5.0, bottom: 1.0),
                      alignment: Alignment.center),
                  onPressed: _isButtonDisabled
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            // Create a new account
                            setState(() {
                              _isButtonDisabled = true;
                            });
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
                                'genderType': _selectedGenderType,
                              });

                              // Navigate to the donation form screen
                              Navigator.pushReplacementNamed(context, '/form');
                            } catch (e) {
                              if (kDebugMode) {
                                print('فشل إنشاء الحساب: ${e.toString()}');
                              }
                              // Show error message to the user
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('فشل إنشاء الحساب')),
                              );
                              setState(() {
                                _isButtonDisabled = false;
                              });
                            }
                          }
                        },
                  child: const Text(
                    'إنشاء حساب',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'HSI', fontSize: 25, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String labelText, String errorText,
      {bool isEmail = false,
      bool isPassword = false,
      bool isPhone = false,
      bool isNumber = false,
      bool isDate = false}) {
    return Directionality(
        textDirection: TextDirection.rtl,
        child: TextFormField(
          textAlign: TextAlign.right,
          controller: controller,
          style: const TextStyle(
            fontFamily: 'HSI',
            fontSize: 15,
            color: Colors.black,
          ),
          decoration: InputDecoration(
            labelStyle: const TextStyle(
              fontFamily: 'HSI',
              fontSize: 15,
              color: Colors.black,
            ),
            labelText: labelText,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            alignLabelWithHint: true,
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
          validator: (values) {
            if (values == null || values.isEmpty) {
              return errorText;
            }
            return null;
          },
        ));
  }

  Widget _buildDropdownField() {
    return DropdownButtonFormField<String>(
      dropdownColor: Colors.white,
      alignment: AlignmentDirectional.center,
      style: const TextStyle(
        fontFamily: 'HSI',
        fontSize: 15,
        color: Colors.black,
      ),
      value: _selectedBloodType,
      decoration: InputDecoration(
        labelText: 'فصيلة الدم',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        alignLabelWithHint: true,
      ),
      items: _bloodTypes.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              value,
              textAlign: TextAlign.right,
            ),
          ),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedBloodType = newValue!;
        });
      },
      validator: (value) {
        if (value == null || !_bloodTypes.contains(value)) {
          return 'يرجى اختيار فصيلة دم صحيحة';
        }
        return null;
      },
    );
  }

  Widget _buildDropdownFieldGender() {
    return Directionality(
        textDirection: TextDirection.rtl,
        child: DropdownButtonFormField<String>(
          dropdownColor: Colors.white,
          alignment: AlignmentDirectional.center,
          style: const TextStyle(
            fontFamily: 'HSI',
            fontSize: 15,
            color: Colors.black,
          ),
          value: _selectedGenderType,
          decoration: InputDecoration(
            labelText: 'الجنس',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            alignLabelWithHint: true,
          ),
          items: _genderTypes.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                ),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedGenderType = newValue!;
            });
          },
          validator: (value) {
            if (value == null || !_genderTypes.contains(value)) {
              return 'يرجى اختيار فصيلة دم صحيحة';
            }
            return null;
          },
        ));
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              const BoxShadow(
                color: Color.fromRGBO(112, 112, 112, 100),
                blurRadius: 5,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'HSI',
                  fontSize: 25,
                ),
              ),
              const Divider(
                height: 22,
                thickness: 1.5,
              ),
              ...children,
            ],
          ),
        ));
  }
}

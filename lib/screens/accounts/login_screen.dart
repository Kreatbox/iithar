// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var _isButtonDisabled = false;
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              Image.asset(
                'assets/icons/logo.png',
                alignment: Alignment.center,
                width: 125,
                height: 125,
              ),
              const Text(
                '!مرحباً  بعودتك',
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontFamily: 'HSI', fontSize: 50, color: Color(0xFFAE0E03)),
              ),
              const SizedBox(height: 20),
              _buildInfoSection(' ', [
                _buildTextFieldemail(_emailController, 'البريد الإلكتروني',
                    'يرجى إدخال بريدك الإلكتروني'),
                const SizedBox(height: 10),
                _buildTextFieldpassword(_passwordController, 'كلمة المرور',
                    'يرجى إدخال كلمة المرور'),
                const SizedBox(height: 20),
              ]),
              const SizedBox(height: 20),
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
                            setState(() {
                              _isButtonDisabled = true;
                            });
                            try {
                              // Sign in with email and password
                              await _auth.signInWithEmailAndPassword(
                                email: _emailController.text,
                                password: _passwordController.text,
                              );
                              setState(() {
                                _isButtonDisabled = false;
                              });
                              // Navigate to home page using navgation widget
                              Navigator.pushReplacementNamed(context, '/nav');
                            } catch (e) {
                              // Show error message to the user
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('فشل تسجيل الدخول')),
                              );
                              setState(() {
                                _isButtonDisabled = false;
                              });
                            }
                          }
                        },
                  child: const Text(
                    'تسجيل الدخول',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'HSI', fontSize: 25, color: Colors.white),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

Widget _buildInfoSection(String title, List<Widget> children) {
  return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(112, 112, 112, 100),
              blurRadius: 5,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ));
}

Widget _buildTextFieldemail(
  TextEditingController controller,
  String labelText,
  String errorText,
) {
  return Directionality(
      textDirection: TextDirection.rtl,
      child: TextFormField(
        controller: controller,
        textAlign: TextAlign.right,
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
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'يرجى إدخال بريدك الإلكتروني';
          }
          return null;
        },
      ));
}

Widget _buildTextFieldpassword(
  TextEditingController controller,
  String labelText,
  String errorText,
) {
  return Directionality(
      textDirection: TextDirection.rtl,
      child: TextFormField(
        controller: controller,
        textAlign: TextAlign.right,
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
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'يرجى إدخال كلمة المرور';
          }
          return null;
        },
      ));
}

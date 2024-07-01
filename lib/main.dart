import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'login_screen.dart'; // استيراد ملف login_screen.dart

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/', // المسار الافتراضي للصفحة الأولى
      routes: {
        '/': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(), // إضافة مسار للصفحة الرئيسية
      },
    );
  }
}
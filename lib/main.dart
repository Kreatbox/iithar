import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'signup_screen.dart'; //  استيراد صفحة إنشاء الحساب

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'تطبيق التبرع بالدم',
      home: SignupScreen(), //  جعل SignupScreen هي الصفحة الرئيسية
    );
  }
}
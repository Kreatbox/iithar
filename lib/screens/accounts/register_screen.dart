import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(children: [
        Image.asset(
          'assets/Images/bg.png',
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 100,
            ),
            const Text('تبرع',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'HSI', fontSize: 60, color: Color(0xFFAE0E03))),
            const Text(
              'بالدم',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'HSI', fontSize: 90, color: Color(0xFFAE0E03)),
            ),
            const Text(
              'و أنقذ حياة',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'HSI', fontSize: 60, color: Color(0xFFAE0E03)),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFAE0E03),
                    padding: const EdgeInsets.only(
                        right: 25.0, left: 25.0, top: 5.0, bottom: 1.0),
                    alignment: Alignment.center),
                child: Text(
                  'تسجيل الدخول',
                  style: TextStyle(
                      fontFamily: 'HSI', fontSize: 25, color: Colors.white),
                )),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: () {
                  // Navigate to signup page
                  Navigator.pushNamed(context, '/signup');
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFAE0E03),
                    padding: const EdgeInsets.only(
                        right: 25.0, left: 25.0, top: 5.0, bottom: 1.0),
                    fixedSize: const Size(170, 25)),
                child: Text(
                  'إنشاء حساب',
                  style: TextStyle(
                      fontFamily: 'HSI', fontSize: 25, color: Colors.white),
                )),
            const SizedBox(height: 20),
          ],
        ),
      ]),
    );
  }
}

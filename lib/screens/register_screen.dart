import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class registerscreen extends StatelessWidget {
  const registerscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تطبيق التبرع بالدم'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              child: const Text('تسجيل الدخول'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/signup');
              },
              child: const Text('إنشاء حساب'),
            ),
            const SizedBox(height: 20),
            FirebaseAuth.instance.currentUser != null
                ? ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/userdata');
                    },
                    child: const Text('عرض بياناتي'),
                  )
                : Container(), // Display button only if user is logged in
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/map');
              },
              child: const Text('خريطة البنوك الدموية'),
            ),
          ],
        ),
      ),
    );
  }
}

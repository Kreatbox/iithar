import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class  registerscreen extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تطبيق التبرع بالدم'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              child: Text('تسجيل الدخول'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/signup');
              },
              child: Text('إنشاء حساب'),
            ),
            SizedBox(height: 20),
            FirebaseAuth.instance.currentUser != null
                ? ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/userdata');
              },
              child: Text('عرض بياناتي'),
            )
                : Container(), // Display button only if user is logged in
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/map');
              },
              child: Text('خريطة البنوك الدموية'),
            ),
          ],
        ),
      ),
    );
  }


}
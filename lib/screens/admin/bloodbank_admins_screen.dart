import 'package:flutter/material.dart';

class BloodbankAdminScreen extends StatelessWidget {
  const BloodbankAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Retrieve the role from the arguments
    final String role = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'انت المشرف على البنك رقم $role',
              style: const TextStyle(
                fontFamily: 'HSI', // Replace with your custom font if needed
                fontSize: 30,
                color: Color(0xFFAE0E03), // Customize text color if needed
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20), // Space between the text and the button
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/home');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFAE0E03),
              ),
              child: const Text(
                'الانتقال إلى الصفحة الرئيسية',
                style: TextStyle(
                  fontFamily: 'HSI',
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/signup_screen.dart';
import 'screens/login_screen.dart';
import 'screens/userdata_screen.dart'; // Import userdata screen
import 'screens/map_screen.dart'; // Import map screen
import 'package:firebase_auth/firebase_auth.dart';

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
    return MaterialApp(
      title: 'تطبيق التبرع بالدم',
                  locale: Locale('ar', 'SY'),
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/signup': (context) => SignupScreen(),
        '/login': (context) => LoginScreen(),
        '/userdata': (context) => UserDataScreen(user: FirebaseAuth.instance.currentUser!), // Pass current user to UserDataScreen
        '/map': (context) => MapScreen(), // Route to map screen
        
      },
    );
  }
}

class HomePage extends StatelessWidget {
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

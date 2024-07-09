import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:iithar/screens/home_screen.dart';
import 'package:iithar/screens/map_screen.dart';
import 'package:iithar/screens/onboarding_screen.dart';
import 'package:iithar/screens/register_screen.dart';
import 'firebase/firebase_options.dart';
import 'screens/signup_screen.dart';
import 'screens/login_screen.dart';
import 'screens/userdata_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> _isFirstRun() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstRun = prefs.getBool('isFirstRun') ?? true;
    if (isFirstRun) {
      await prefs.setBool('isFirstRun', false);
    }
    return isFirstRun;
  }

  Widget _getInitialScreen() {
    User? user = FirebaseAuth.instance.currentUser;

    return FutureBuilder<bool>(
      future: _isFirstRun(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        } else {
          bool isFirstRun = snapshot.data!;
          if (isFirstRun) {
            return const Onboarding();
          } else if (user == null) {
            return const RegisterScreen();
          } else {
            //here use HomeScreen instead of RegisterScreen when you finish the homescreen page
            return const HomeScreen(); //RegisterScreen();
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'تطبيق التبرع بالدم',
      locale: const Locale('ar', 'SY'),
      home: _getInitialScreen(),
      routes: {
        '/signup': (context) => const SignupScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/userdata': (context) => UserDataScreen(
            user: FirebaseAuth
                .instance.currentUser!), // Pass current user to UserDataScreen
        '/map': (context) => MapScreen(),
        '/onboarding': (context) => const Onboarding(),
      },
    );
  }
}

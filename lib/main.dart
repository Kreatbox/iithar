import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:iithar/screens/map_screen.dart';
import 'package:iithar/screens/onboarding_screen.dart';
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'تطبيق التبرع بالدم',
                  locale: const Locale('ar', 'SY'),
      initialRoute: '/',
      routes: {
        '/': (context) => const Onboarding(),
        '/signup': (context) => const SignupScreen(),
        '/login': (context) => const LoginScreen(),
        '/userdata': (context) => UserDataScreen(user: FirebaseAuth.instance.currentUser!), // Pass current user to UserDataScreen
        '/map': (context) => MapScreen(),
        '/onboarding': (context) => const Onboarding(),// Route to map screen
        
      },
    );
  }
}
  @override
  Widget build(BuildContext context) {
    return const Onboarding();
}

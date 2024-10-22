import 'package:flutter/services.dart';
import 'package:iithar/screens/accounts/contact_withus.dart';
import 'package:iithar/screens/accounts/my_requests.dart';
import 'package:iithar/screens/admin/admin_homescreen.dart';
import 'package:iithar/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:iithar/navigation_menu.dart';
import 'package:iithar/screens/accounts/personal_info.dart';
import 'package:iithar/screens/appointment_booking.dart';
import 'package:iithar/screens/donation_form.dart';
import 'package:iithar/screens/accounts/my_appointment.dart';
import 'package:iithar/screens/admin/bloodbank_admins_screen.dart';
import 'package:iithar/screens/accounts/my_donations.dart';
import 'package:iithar/screens/accounts/my_request.dart';
import 'package:iithar/screens/first_run/splash_screen.dart';
import 'package:iithar/screens/notification_screen.dart';
import 'package:iithar/screens/publish_request.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:iithar/screens/home_screen.dart';
import 'package:iithar/screens/map_screen.dart';
import 'package:iithar/screens/first_run/onboarding_screen.dart';
import 'package:iithar/screens/accounts/register_screen.dart';
import 'firebase/firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'screens/accounts/signup_screen.dart';
import 'screens/accounts/login_screen.dart';
import 'screens/accounts/userdata_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/data_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  WidgetsFlutterBinding.ensureInitialized();
  final DataService dataService = DataService();
  await dataService.fetchAndCacheBankData();
  final NotificationService notificationService = NotificationService();
  await notificationService.initNotification();
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Requesting permissions
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  debugPrint('User granted permission: ${settings.authorizationStatus}');

  // Get the FCM token
  String? token = await messaging.getToken();
  debugPrint("FCM Token: $token");

  // Subscribe to the topic for notifications
  await messaging.subscribeToTopic('urgent_requests');

  // Initialize message listener
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    debugPrint('Got a message whilst in the foreground!');
    debugPrint('Message data: ${message.data}');

    if (message.notification != null) {
      debugPrint(
          'Message also contained a notification: ${message.notification}');
    }
  });
  // تقييد التوجه على الوضع العمودي فقط
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

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
            return const SplashScreen();
          } else if (user == null) {
            return const RegisterScreen();
          } else {
            return const NavigationMenu();
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
        '/notifications': (context) => NotificationsScreen(),
        '/form': (context) => const DonationForm(),
        '/publishrequest': (context) => const PublishRequest(),
        '/appointment': (context) => const AppointmentBookingScreen(),
        '/nav': (context) => const NavigationMenu(),
        '/userdata': (context) =>
            UserDataScreen(user: FirebaseAuth.instance.currentUser!),
        '/map': (context) => const MapScreen(),
        '/onboarding': (context) => const Onboarding(),
        '/myappointment': (context) => const MyAppointmentScreen(),
        '/personalinfo': (context) =>
            UserinfoDataScreen(userinfo: FirebaseAuth.instance.currentUser!),
        '/myrequests': (context) => const MyRequests(),
        '/myrequest': (context) => const MyRequestScreen(),
        '/mydonations': (context) => const MyDonationsScreen(),
        '/bloodbankadmin': (context) => const BloodbankAdminScreen(),
        '/contactus': (context) => const ContactWithus(),
        '/admin': (context) => const BloodbankAdminScreen(),
        '/adminscreen': (context) => const AdminHomescreen(),
      },
    );
  }
}

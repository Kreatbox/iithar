import 'package:flutter/material.dart';
import 'package:iithar/screens/awareness_screen.dart';
import 'package:iithar/screens/home_screen.dart';
import 'package:iithar/screens/my_account_screen.dart';
import 'package:iithar/screens/notification_screen.dart';


class MainScreen extends StatefulWidget {
  MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  List<Widget> pages = [
    HomeScreen(),
    AwarenessScreen(),
    MyAccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        title: Row(
          children: [
            IconButton(
              icon: Icon(Icons.notifications),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return NotificationsScreen();
                }));
              },
            ),
            Spacer(), // Adds space between the icon and the text
            Text(
              'مرحباً أحمد',
              style: TextStyle(
                color: Colors.black, // Set the text color
              ),
              textAlign: TextAlign.right,
            ),
          ],
        ),
      ),
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (value) {
          setState(() {
            currentIndex = value;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(
              'web/icons/icon1.png',
              width: 24,
              height: 24,
            ),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'web/icons/icon3.png',
              width: 24,
              height: 24,
            ),
            label: 'طلب دم ',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'web/icons/icon2.png',
              width: 24,
              height: 24,
            ),
            label: 'الحساب',
          ),
        ],
      ),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iithar/screens/home_screen.dart';
import 'package:iithar/screens/publish_request.dart';
import 'package:iithar/screens/userdata_screen.dart';

class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());

    return Scaffold(backgroundColor: Colors.white,
      bottomNavigationBar: Container(height: 50,



        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,

          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(112, 112, 112,100).withOpacity(0.2),
              blurRadius: 15,
              //offset: Offset(0,20),
            )
          ],
          borderRadius: BorderRadius.circular(30),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30), // Add rounded corners
          child: Obx(
                () => NavigationBar(

              selectedIndex: controller.selectedIndex.value,
              onDestinationSelected: (index) => controller.selectedIndex.value = index,
              destinations: [
                NavigationDestination(
                  icon: Image.asset(
                    'assets/icons/icon1.png',
                    height: 20,
                  ),
                  label: 'الرئيسية',
                ),
                NavigationDestination(
                  icon: Image.asset(
                    'assets/icons/icon3.png',
                    height: 20,
                  ),
                  label: 'نشر',
                ),
                NavigationDestination(
                  icon: Image.asset(
                    'assets/icons/icon2.png',
                    height: 20,
                  ),
                  label: 'الحساب',
                ),
              ],
              indicatorColor: Colors.black12, // لون المؤشر المحدد
              backgroundColor: Colors.white,
                   height: 20, surfaceTintColor: Colors.white,shadowColor: Colors.cyan,
                  // ارتفاع شريط التنقل
            ),
          ),
        ),
      ),
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
    );
  }
}

class NavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;

  final screens = [
    const HomeScreen(),
    const PublishRequest(),
    UserDataScreen(user: FirebaseAuth.instance.currentUser!)
  ];
}

void main() {
  runApp(MaterialApp(
    home: NavigationMenu(),
  ));
}
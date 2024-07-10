import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iithar/screens/home_screen.dart';
import 'package:iithar/screens/publish_reguest.dart';
import 'package:iithar/screens/userdata_screen.dart';

class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    // Create and use NavigationController using GetX
    final controller = Get.put(Navigationcontroller());

    return Scaffold(
      // Use Obx to watch changes in selectedIndex to dynamically update the NavigationBar
      bottomNavigationBar: Obx(
        () => NavigationBar(
          height: 55,
          elevation: 0,
          // Set selectedIndex to match the value of selectedIndex in NavigationController
          selectedIndex: controller.selectedIndex.value,
          // Update selectedIndex when changing the destination in the NavigationBar
          onDestinationSelected: (index) =>
              controller.selectedIndex.value = index,

          destinations: [
            NavigationDestination(
              icon: Image.asset(
                'assets/icons/icon1.png',
                height: 30,
              ),
              label: 'الرئيسية',
            ),
            NavigationDestination(
                icon: Image.asset(
                  'assets/icons/icon3.png',
                  height: 30,
                ),
                label: 'نشر '),
            NavigationDestination(
                icon: Image.asset(
                  'assets/icons/icon2.png',
                  height: 30,
                ),
                label: 'الحساب'),
          ],
        ),
      ),
      // Use Obx to watch changes in selectedIndex to dynamically update the body content
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
    );
  }
}

class Navigationcontroller extends GetxController {
  // Variable selectedIndex to keep track of the current active screen index
  final Rx<int> selectedIndex = 0.obs;
  // List of different screens to navigate between based on selectedIndex
  final screens = [
    const HomeScreen(),
    const PublishReguest(),
    UserDataScreen(user: FirebaseAuth.instance.currentUser!)
  ];
}

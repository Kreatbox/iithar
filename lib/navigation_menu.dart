import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iithar/screens/home_screen.dart';
import 'package:iithar/screens/publish_request.dart';
import 'package:iithar/screens/accounts/userdata_screen.dart';

class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: Container(
        height: 50,
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(112, 112, 112, 100),
              blurRadius: 15,
            )
          ],
          borderRadius: BorderRadius.circular(30),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Obx(
            () => NavigationBar(
              selectedIndex: controller.selectedIndex.value,
              onDestinationSelected: (index) {
                controller.selectedIndex.value = index;
                debugPrint("Selected index: $index");
              },
              destinations: [
                NavigationDestination(
                  icon: Image.asset(
                    'assets/icons/icon1.png',
                    height: 20,
                  ),
                  label: '',
                ),
                const NavigationDestination(
                  icon:
                      Icon(Icons.bloodtype_outlined, color: Color(0xFFAE0E03)),
                  label: '',
                ),
                NavigationDestination(
                  icon: Image.asset(
                    'assets/icons/icon2.png',
                    height: 20,
                  ),
                  label: '',
                ),
              ],
              indicatorColor: Colors.black12,
              backgroundColor: Colors.white,
              height: 10,
              surfaceTintColor: Colors.white,
              shadowColor: Colors.cyan,
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

  final List<Widget> screens;

  NavigationController()
      : screens = [
          const HomeScreen(),
          const PublishRequest(),
          UserDataScreen(user: FirebaseAuth.instance.currentUser!)
        ];
}

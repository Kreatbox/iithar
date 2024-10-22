import 'package:flutter/material.dart';
import 'package:iithar/screens/accounts/my_appointment.dart';
import 'package:iithar/screens/admin/bank_appointment.dart';

class AdminHomescreen extends StatefulWidget {
  const AdminHomescreen({super.key});

  @override
  State<AdminHomescreen> createState() => _AdminHomescreenState();

}
late List<Map<String, dynamic>> items = [];
class _AdminHomescreenState extends State<AdminHomescreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Align(
          alignment: Alignment.centerRight,
          child: Text(
            'لوحة تحكم مدير البنك',
            textAlign: TextAlign.right,
            style:
                TextStyle(fontFamily: 'HSI', fontSize: 30, color: Colors.black),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(
              height: 40,
            ),
            const SizedBox(height: 5.0),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              mainAxisSpacing: 1.0,
              crossAxisSpacing: 1.0,
              childAspectRatio: 1, //نسبة العرض للارتفاع للعناصر
              children: [
                _buildGridItem('assets/icons/datetime.png', 'حجوزات التبرع',
                    () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const BankAppintment();
                  }));
                }),
                _buildGridItem('assets/icons/icon3.png', 'زمر الدم', () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const MyAppointmentScreen();
                  }));
                }),
                _buildGridItem('assets/icons/icon3.png', 'طوارئ', () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const MyAppointmentScreen();
                  }));
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildGridItem(String assetPath, String title, Function() onTap) {
  return ListView(padding: const EdgeInsets.all(5.0), children: [
    SizedBox(
      height: 100,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(112, 112, 112, 100),
              blurRadius: 5,
            ),
          ],
        ),
        child: InkWell(
          onTap: onTap,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 200,
                ),
                Image.asset(assetPath, height: 45),
                const SizedBox(height: 5.0), //  المسافة بين الصورة والنص
                Text(title,
                    style: const TextStyle(fontSize: 14, fontFamily: 'BAHIJ')),
              ],
            ),
          ),
        ),
      ),
    ),
  ]);
}

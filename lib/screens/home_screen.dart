import 'package:flutter/material.dart';
import 'package:iithar/components/donation_request_listview.dart';
import 'package:iithar/screens/awareness_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Card(
          color: Colors.red.shade50,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                Image.asset('assets/icons/icon10.png', height: 90),
                const SizedBox(height: 8.0),
                const Text(
                  'تبرعك بالدم، حياة لشخص آخر',
                  style: TextStyle(
                      fontSize: 18.0,
                      fontFamily: 'HSI',
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10.0),
        GridView.count(
          shrinkWrap: true,
          crossAxisCount: 2,
          mainAxisSpacing: 1.0,
          crossAxisSpacing: 1.0,
          childAspectRatio: 1.7, //نسبة العرض للارتفاع للعناصر
          children: [
            _buildGridItem('assets/icons/icon8.png', 'بنوك الدم', () {}),
            _buildGridItem('assets/icons/icon4.png', 'توعية', () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const AwarenessScreen();
              }));
            }),
            _buildGridItem('assets/icons/icon6.png', 'حجز موعد للتبرع', () {}),
            _buildGridItem('assets/icons/icon3.png', 'طوارئ', () {}),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                minimumSize: const Size(5, 5),
              ),
              child: const Text(
                'عرض المزيد',
                textAlign: TextAlign.left,
              ),
            ),
            const Text(
              'طلبات التبرع',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4.0),
        const DonationRequestsListView(),
      ],
    );
  }

  Widget _buildGridItem(String assetPath, String title, Function() onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(assetPath, height: 44),
              const SizedBox(height: 5.0), //  المسافة بين الصورة والنص
              Text(title, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}

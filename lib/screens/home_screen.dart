import 'package:flutter/material.dart';
import 'package:iithar/components/donation_request_listview.dart';
import 'package:iithar/screens/awareness_screen.dart';

class HomeScreen extends StatelessWidget {
   HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(16.0),
      children: [
        Card(
          color: Colors.red.shade50,
          child: Padding(
            padding: EdgeInsets.all(15.0),
            child: Column(
              children: [
                Image.asset('web/icons/icon10.png', height: 90),
                SizedBox(height: 8.0),
                Text(
                  'تبرعك بالدم، حياة لشخص آخر',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 10.0),
        GridView.count(
          shrinkWrap: true,
          crossAxisCount: 2,
          mainAxisSpacing: 1.0,
          crossAxisSpacing: 1.0,
          childAspectRatio: 1.7, //نسبة العرض للارتفاع للعناصر
          children: [
            _buildGridItem('web/icons/icon8.png', 'بنوك الدم', () {}),
            _buildGridItem('web/icons/icon4.png', 'توعية', () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return AwarenessScreen();
              }));
            }),
            _buildGridItem('web/icons/icon6.png', 'حجز موعد للتبرع', () {}),
            _buildGridItem('web/icons/icon3.png', 'طوارئ', () {}),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () {},
              child: Text(
                'عرض المزيد',
                textAlign: TextAlign.left,
              ),
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                minimumSize: Size(5, 5),
              ),
            ),
            Text(
              'طلبات التبرع',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 4.0),
        DonationRequestsListView(),
      ],
    );
  }

  Widget _buildGridItem(String assetPath, String title, Function() onTap,
      {double size = 40}) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(assetPath, height: 44),
              SizedBox(height: 5.0), //  المسافة بين الصورة والنص
              Text(title, style: TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}

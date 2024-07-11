import 'package:flutter/material.dart';
import 'package:iithar/components/donation_request_listview.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
          IconButton(
          icon: Image.asset(
              'assets/icons/icons8-notification-64.png', height: 30,),
        onPressed: () {
          Navigator.pushNamed(context, '/notifications');
          // Handle the notification icon press
          print('Notification icon pressed');
        },
      ), Expanded(
      child: Align(alignment:
      Alignment.centerRight,
        child:
        Text('مرحبا ',
            textAlign: TextAlign.right,
            style: TextStyle(
                fontFamily: 'HSI', fontSize: 40, color: Colors.black)),
      ),
    ),
    ],),),

      body: ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Card(
          color: Colors.red.shade50,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Image.asset('assets/icons/icon10.png', height: 75),
                const SizedBox(height: 8.0),
                Column(children: [Text(
                  'تبرعك بالـدم، حيـاة',
                  style: TextStyle(
                    fontSize: 30.0,
                    fontFamily: 'HSI',
                  ) ,
                ), Text(
                  ' لشـخص آخـر',
                  style: TextStyle(
                    fontSize: 30.0,
                    fontFamily: 'HSI',
                  ) ,
                ),]
                ),



              ],
            ),

          ),
        ),
        const SizedBox(height: 5.0),
        GridView.count(

          shrinkWrap: true,
          crossAxisCount: 3,
          mainAxisSpacing: 1.0,
          crossAxisSpacing: 1.0,
          childAspectRatio: 1, //نسبة العرض للارتفاع للعناصر
          children: [
            _buildGridItem('assets/icons/icon8.png', 'بنوك الدم', () {}),
            _buildGridItem('assets/icons/icon6.png', 'حجز موعد للتبرع', () {}),
            _buildGridItem('assets/icons/icon3.png', 'طوارئ', () {}),
          ],
        ), Container(height: 12,),
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
                style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'BAHIJ'),
                textAlign: TextAlign.left,
              ),
            ),
            const Text(
              'طلبات التبرع',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 40,
                fontFamily: 'HSI',
              ),
            ),
          ],
        ),
        const SizedBox(height: 4.0),
        const DonationRequestsListView(),
      ],
    ),
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
              Text(title, style: const TextStyle(fontSize: 14,fontFamily:'BAHIJ')),
            ],
          ),
        ),
      ),
    );

  }
}

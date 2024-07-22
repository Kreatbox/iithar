import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:iithar/components/donation_request_listview.dart';
import 'package:iithar/screens/appointment_booking.dart';
import 'package:iithar/screens/blood_banks.dart';
import 'package:iithar/screens/donation_requests.dart';

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
      padding: const EdgeInsets.all(15.0),
      children: [ Column(children: [
        Container(
            height: 125,
            width: 400,
            child: Padding(
              padding: const EdgeInsets.only(left: 5.0,right: 5.0,top: 1.0,bottom: 1.0),
              child:Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.white,
                boxShadow: [
                  BoxShadow( color:Color.fromRGBO(112, 112,112, 100),
                    blurRadius: 5,
                  ),

                ],),
             child:  Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Image.asset('assets/icons/icon10.png', height: 75),
                  const SizedBox(height: 8.0),
                  Column( mainAxisAlignment: MainAxisAlignment.center,
                    children: [Text(
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
                  ),],
                  ),

                ],
              ),
    ),
            ),),
        Container(height: 12,),
        const SizedBox(height: 5.0),
        GridView.count(

          shrinkWrap: true,
          crossAxisCount: 3,
          mainAxisSpacing: 1.0,
          crossAxisSpacing: 1.0,
          childAspectRatio: 1, //نسبة العرض للارتفاع للعناصر
          children: [
            _buildGridItem('assets/icons/icon8.png', 'بنوك الدم', (){
                 Navigator.push(context, MaterialPageRoute(builder: (context) {
                return BloodBanksScreen();
              }));
            }),
            _buildGridItem('assets/icons/icon6.png', 'حجز موعد للتبرع', () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
                return AppointmentBookingScreen();
              }));
            }),

            _buildGridItem('assets/icons/icon3.png', 'طوارئ', () {
             Navigator.push(context, MaterialPageRoute(builder: (context) {
                return DonationRequestScreen();
              }));
            }),
          ],
        ),
        Container(height: 12,),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () {
             Navigator.push(context, MaterialPageRoute(builder: (context) {
                return DonationRequestScreen();
              }));},
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                minimumSize: const Size(5, 5),
              ),
              child: const Text(
                'عرض المزيد',
                style: TextStyle(
                    fontSize: 14,
                       color: Colors.black,
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
        const SizedBox(height: 10.0),
        const DonationRequestsListView(),
      ],),])
    );

  }

  Widget _buildGridItem(String assetPath, String title, Function() onTap) {
    return ListView(
        padding: const EdgeInsets.all(5.0),
        children:  [
    Container(
        height: 100,
        child:
         Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.white,
              boxShadow: [
                BoxShadow( color:Color.fromRGBO(112, 112,112, 100),
                  blurRadius: 5,
                ),

              ],),
        child: InkWell(
          onTap: onTap,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [Container(width: 200,),
                Image.asset(assetPath, height: 45),
                const SizedBox(height: 5.0), //  المسافة بين الصورة والنص
                Text(title, style: const TextStyle(fontSize: 14,fontFamily:'BAHIJ')),
              ],
            ),
          ),
        ),
      ),
    ),
    ]);

  }
}

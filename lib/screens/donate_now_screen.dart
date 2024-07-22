import 'package:flutter/material.dart';
import 'package:iithar/models/donation_request.dart';

class DonateNowScreen extends StatelessWidget {
  final DonationRequest donationRequest;
  const DonateNowScreen({super.key, required this.donationRequest});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Align(
          alignment: Alignment.centerRight,
          child: Text(
            'تفاصيل طلب التبرع',
            textAlign: TextAlign.right,
            style: TextStyle(
                fontFamily: 'HSI', fontSize: 30, color: Colors.black),
          ),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            UserInfoCard(),
          ],
        ),
      ),
    );
  }
}

class UserInfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 4.0,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    CircleAvatar(
                      backgroundColor:  Color(0xFFAE0E03),
                      radius: 20.0,
                      child: Icon(
                        Icons.person,color: Colors.white,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 16.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'احمد',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                              fontSize: 20,
                              fontFamily: 'BAHIJ'),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row( mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Icon(Icons.bloodtype, color: Color(0xFFAE0E03)),
                        SizedBox(width: 8.0),
                        Text(
                          'فصيلة الدم المطلوبة:',
                          style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'BAHIJ'),
                        ),
                        SizedBox(width: 16.0),
                        Text(
                          'O+',
                          style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'BAHIJ'),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.0),
                    Row( mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Icon(Icons.timer, color: Color(0xFFAE0E03)),
                        SizedBox(width: 8.0),
                        Text(
                          'الوقت المتبقي:',
                          style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'BAHIJ'),
                        ),
                        SizedBox(width: 16.0),
                        Text(
                          '20 دقيقة ',
                          style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'BAHIJ'),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Icon(Icons.location_on, color: Color(0xFFAE0E03)),
                        SizedBox(width: 8.0),
                        Text(
                          'الموقع:',
                          style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'BAHIJ'),
                        ),SizedBox(width:  16.0),
                        Text(
                          'دمشق',
                          style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'BAHIJ'),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    OutlinedButton.icon(
                        iconAlignment: IconAlignment.end,
                      style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Color(0xFFAE0E03))),
                      onPressed: () {
                        _showConfirmationDialog(context);
                      },
                       icon: Icon(Icons.favorite_border,color: Colors.white),
                      label: Text('ساهم بإنقاذ حياة',textAlign: TextAlign.left,style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'BAHIJ',color: Colors.white),
                      )
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text('تم إرسال قبول للمتبرع',
            textAlign: TextAlign.center,
            style: TextStyle(
          fontSize: 25,
          fontFamily: 'BAHIJ',color: Colors.black),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Image.asset('assets/icons/icon6.png',width:90,height: 90,),
              SizedBox(height: 16.0),
              Text('!شكراً لك على مساهمتك في إنقاذ حياة',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                  fontSize: 15,
                  fontFamily: 'BAHIJ',color: Colors.black)),
              SizedBox(height: 16.0),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('موافق',style: TextStyle(
                  fontSize: 15,
                  fontFamily: 'BAHIJ',color: Colors.black)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

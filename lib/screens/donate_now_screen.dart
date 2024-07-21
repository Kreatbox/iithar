import 'package:flutter/material.dart';
import 'package:iithar/models/donation_request.dart';

class DonateNowScreen extends StatelessWidget {
  final DonationRequest donationRequest;
  const DonateNowScreen({super.key, required this.donationRequest});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("تفاصيل طلب التبرع "),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 4.0,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 30.0,
                    child: Icon(Icons.person),
                  ),
                  SizedBox(width: 16.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'احمد',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              InfoRow(
                icon: Icons.bloodtype,
                label: 'فصيلة الدم المطلوبة',
                value: 'O+',
              ),
              InfoRow(
                icon: Icons.timer,
                label: 'الوقت المتبقي',
                value: ' ',
              ),
              InfoRow(
                icon: Icons.location_on,
                label: 'الموقع',
                value: 'دمشق',
              ),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  OutlinedButton.icon(
                    onPressed: () {
                      _showConfirmationDialog(context);
                    },
                    label: Text('ساهم بإنقاذ حياة'),
                  ),
                ],
              ),
            ],
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
          title: Text('تم إرسال قبول للمتبرع'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
                            Image.asset('assets/icons/icon10.png'),

              Text('شكراً لك على مساهمتك في إنقاذ حياة!'),
              SizedBox(height: 16.0),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('موافق'),
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

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: <Widget>[
          Icon(icon, color: Color(0xFFAE0E03)),
          SizedBox(width: 8.0),
          Text(
            label,
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

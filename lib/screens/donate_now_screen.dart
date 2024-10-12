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
            style:
                TextStyle(fontFamily: 'HSI', fontSize: 30, color: Colors.black),
          ),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            // Pass the donationRequest to UserInfoCard
            UserInfoCard(donationRequest: donationRequest),
          ],
        ),
      ),
    );
  }
}

class UserInfoCard extends StatelessWidget {
  final DonationRequest donationRequest;

  const UserInfoCard({super.key, required this.donationRequest});

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
                      backgroundColor: Colors.grey[20],
                      radius: 20.0,
                      child: const Icon(
                        Icons.person,
                        color: Color(0xFFAE0E03),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          donationRequest.name, // Use donationRequest name
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                              fontSize: 20, fontFamily: 'BAHIJ'),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        const Icon(Icons.bloodtype, color: Color(0xFFAE0E03)),
                        const SizedBox(width: 8.0),
                        const Text(
                          'فصيلة الدم المطلوبة:',
                          style: TextStyle(fontSize: 16, fontFamily: 'BAHIJ'),
                        ),
                        const SizedBox(width: 16.0),
                        Text(
                          donationRequest
                              .bloodType, // Use donationRequest bloodType
                          style: const TextStyle(
                              fontSize: 16, fontFamily: 'BAHIJ'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        const Icon(Icons.timer, color: Color(0xFFAE0E03)),
                        const SizedBox(width: 8.0),
                        const Text(
                          'الوقت المتبقي:',
                          style: TextStyle(fontSize: 16, fontFamily: 'BAHIJ'),
                        ),
                        const SizedBox(width: 16.0),
                        Text(
                          '20 دقيقة ', // Update with real data if available
                          style: const TextStyle(
                              fontSize: 16, fontFamily: 'BAHIJ'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        const Icon(Icons.location_on, color: Color(0xFFAE0E03)),
                        const SizedBox(width: 8.0),
                        const Text(
                          'الموقع:',
                          style: TextStyle(fontSize: 16, fontFamily: 'BAHIJ'),
                        ),
                        const SizedBox(width: 16.0),
                        Text(
                          donationRequest
                              .location, // Use donationRequest location
                          style: const TextStyle(
                              fontSize: 16, fontFamily: 'BAHIJ'),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    OutlinedButton.icon(
                        iconAlignment: IconAlignment.end,
                        style: const ButtonStyle(
                            backgroundColor:
                                WidgetStatePropertyAll(Color(0xFFAE0E03))),
                        onPressed: () {
                          _showConfirmationDialog(context);
                        },
                        icon: const Icon(Icons.favorite_border,
                            color: Colors.white),
                        label: const Text(
                          'ساهم بإنقاذ حياة',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'BAHIJ',
                              color: Colors.white),
                        )),
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
          title: const Text(
            'شكراً لك على مساهمتك في إنقاذ حياة',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 25, fontFamily: 'BAHIJ', color: Colors.black),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(height: 16.0),
              const Text('لقد تم إرسال قبول للمتبرع ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 18, fontFamily: 'BAHIJ', color: Colors.black)),
              const SizedBox(height: 25.0),
              Image.asset(
                'assets/icons/icon6.png',
                width: 90,
                height: 90,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('موافق',
                  style: TextStyle(
                      fontSize: 15, fontFamily: 'BAHIJ', color: Colors.black)),
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

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Ensure Firebase is initialized
  runApp(const MyRequestScreen());
}

class MyRequestScreen extends StatelessWidget {
  const MyRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BloodDonationRequestScreen(),
    );
  }
}

class BloodDonationRequestScreen extends StatelessWidget {
  const BloodDonationRequestScreen({super.key});

  Future<Map<String, dynamic>?> fetchLastRequest() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return null;
    }

    final userId = user.uid;

    final querySnapshot = await FirebaseFirestore.instance
        .collection('requests')
        .where('userId', isEqualTo: userId)
        .orderBy('dateTime', descending: true)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.data();
    }
    return null;
  }

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
            style: TextStyle(
              fontFamily: 'HSI',
              fontSize: 30,
              color: Colors.black,
            ),
          ),
        ),
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: fetchLastRequest(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('حدث خطأ ما.'));
          } else if (snapshot.hasData && snapshot.data != null) {
            final requestData = snapshot.data!;
            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('تفاصيل طلب التبرع'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('اسم المريض: ${requestData['name'] ?? 'غير معروف'}'),
                              Text('زمرة الدم: ${requestData['bloodType'] ?? 'غير معروف'}'),
                              Text('موقع التبرع: ${requestData['bloodBank'] ?? 'غير معروف'}'),
                              Text('الحالة الطبية: ${requestData['medicalCondition'] ?? 'غير معروف'}'),
                              Text('رقم الهاتف: ${requestData['phone'] ?? 'غير معروف'}'),
                              Text('تاريخ ووقت التبرع: ${requestData['dateTime'] ?? 'غير معروف'}'),
                              Text('ملاحظة: ${requestData['note'] ?? 'غير معروف'}'),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('إغلاق'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: BloodDonationRequestCard(
                    donationDateTime: requestData['dateTime'] ?? 'غير معروف',
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: Text('لا توجد طلبات.'));
          }
        },
      ),
    );
  }
}

class BloodDonationRequestCard extends StatelessWidget {
  final String donationDateTime;

  const BloodDonationRequestCard({
    super.key,
    required this.donationDateTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                Icon(Icons.calendar_today, size: 20.0, color: const Color(0xFFAE0E03)),
                const SizedBox(width: 8.0),
                Text(
                  'تاريخ ووقت التبرع: $donationDateTime',
                  style: const TextStyle(
                    fontFamily: 'HSI',
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

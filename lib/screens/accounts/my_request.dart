import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyRequestScreen extends StatelessWidget {
  const MyRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
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
                BloodDonationRequestCard(
                  patientName: requestData['name'] ?? 'غير معروف',
                  bloodType: requestData['bloodType'] ?? 'غير معروف',
                  donationLocation: requestData['bloodBank'] ?? 'غير معروف',
                  medicalCondition:
                      requestData['medicalCondition'] ?? 'غير معروف',
                  phoneNumber: requestData['phone'] ?? 'غير معروف',
                  donationDateTime: requestData['dateTime'] ?? 'غير معروف',
                  note: requestData['note'] ?? 'غير معروف',
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
  final String patientName;
  final String bloodType;
  final String donationLocation;
  final String medicalCondition;
  final String phoneNumber;
  final String donationDateTime;
  final String note;

  const BloodDonationRequestCard({
    super.key,
    required this.patientName,
    required this.bloodType,
    required this.donationLocation,
    required this.medicalCondition,
    required this.phoneNumber,
    required this.donationDateTime,
    required this.note,
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
            _buildInfoSection(
              'تفاصيل طلب التبرع',
              [
                InfoRow(
                  icon: Icons.person,
                  label: 'اسم المريض',
                  value: patientName,
                ),
                const Divider(),
                InfoRow(
                  icon: Icons.bloodtype,
                  label: 'زمرة الدم',
                  value: bloodType,
                ),
                const Divider(),
                InfoRow(
                  icon: Icons.location_on,
                  label: 'موقع التبرع',
                  value: donationLocation,
                ),
                const Divider(),
                InfoRow(
                  icon: Icons.local_hospital,
                  label: 'الحالة الطبية',
                  value: medicalCondition,
                ),
                const Divider(),
                InfoRow(
                  icon: Icons.phone,
                  label: 'رقم الهاتف',
                  value: phoneNumber,
                ),
                const Divider(),
                InfoRow(
                  icon: Icons.calendar_today,
                  label: 'تاريخ ووقت التبرع',
                  value: donationDateTime,
                ),
                const Divider(),
                InfoRow(
                  icon: Icons.note,
                  label: 'ملاحظة',
                  value: note,
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Center(
              child: ButtonBar(
                alignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFAE0E03),
                    ),
                    child: const Text(
                      'تعديل',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'HSI',
                        fontSize: 25,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFAE0E03),
                    ),
                    child: const Text(
                      'حذف',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'HSI',
                        fontSize: 25,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(112, 112, 112, 0.2),
              blurRadius: 5,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontFamily: 'HSI',
                fontSize: 30,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16.0),
            ...children,
          ],
        ),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const InfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20.0, color: const Color(0xFFAE0E03)),
        const SizedBox(width: 8.0),
        Text(
          '$label: $value',
          style: const TextStyle(
            fontFamily: 'HSI',
            fontSize: 15,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}

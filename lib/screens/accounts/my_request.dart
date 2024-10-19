// ignore_for_file: use_build_context_synchronously

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:iithar/models/blood_bank.dart';
import 'package:iithar/services/data_service.dart';
import 'package:latlong2/latlong.dart';

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

class BloodDonationRequestScreen extends StatefulWidget {
  const BloodDonationRequestScreen({super.key});

  @override
  BloodDonationRequestScreenState createState() =>
      BloodDonationRequestScreenState();
}

class BloodDonationRequestScreenState
    extends State<BloodDonationRequestScreen> {
  late List<BloodBank> bloodBanks = [];

  @override
  void initState() {
    super.initState();
    fetchBloodBanks();
  }

  Future<void> fetchBloodBanks() async {
    final DataService dataService = DataService();
    bloodBanks = await dataService.loadBankData();
  }

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
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final requestDoc = querySnapshot.docs.first;
      final requestData = requestDoc.data();

      // أضف الـ requestId إلى البيانات
      requestData['id'] = requestDoc.id;

      return requestData;
    }
    return null;
  }

  Future<void> deleteRequest(String requestId) async {
    try {
      // Fetch the request document to check for acceptedUserId
      final requestDoc = await FirebaseFirestore.instance
          .collection('requests')
          .doc(requestId)
          .get();

      if (requestDoc.exists) {
        final requestData = requestDoc.data();
        // Check if acceptedUserId exists
        if (requestData?['acceptedUserId'] != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('هذا الطلب تم الرد عليه ولا يمكن حذفه')),
          );
        } else {
          // Proceed to delete if acceptedUserId is not present
          await FirebaseFirestore.instance
              .collection('requests')
              .doc(requestId)
              .delete();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم حذف الطلب بنجاح')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل في حذف الطلب')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('طلب التبرع بالدم',
            style: TextStyle(color: Colors.black)),
        centerTitle: true,
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
            String bankId = requestData['bankId'];
            String bankName = 'Unknown Bank';

            // البحث عن اسم بنك الدم باستخدام bankId
            BloodBank? bank = bloodBanks.firstWhere(
              (b) => b.bankId == bankId,
              orElse: () => BloodBank(
                  bankId: '',
                  name: 'Unknown Bank',
                  hours: '',
                  phoneNumber: '',
                  location: const LatLng(0, 0),
                  place: ''),
            );
            bankName = bank.name;

            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                BloodDonationRequestCard(
                  patientName: requestData['name'] ?? 'غير معروف',
                  bloodType: requestData['bloodType'] ?? 'غير معروف',
                  donationLocation: bankName,
                  medicalCondition:
                      requestData['medicalCondition'] ?? 'غير معروف',
                  phoneNumber: requestData['phone'] ?? 'غير معروف',
                  donationDateTime: requestData['dateTime'] ?? 'غير معروف',
                  note: requestData['note'] ?? 'غير معروف',
                  onDelete: () {
                    deleteRequest(
                        requestData['id']); // تمرير الـ requestId المحفوظ الآن
                    Navigator.pushNamed(context, '/myrequests');
                  },
                )
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
  final VoidCallback onDelete;

  const BloodDonationRequestCard({
    super.key,
    required this.patientName,
    required this.bloodType,
    required this.donationLocation,
    required this.medicalCondition,
    required this.phoneNumber,
    required this.donationDateTime,
    required this.note,
    required this.onDelete,
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
                  value: donationDateTime.substring(0, 16),
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
                    onPressed: onDelete,
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

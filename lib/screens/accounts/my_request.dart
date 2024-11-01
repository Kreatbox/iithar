// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iithar/models/blood_bank.dart';
import 'package:iithar/services/data_service.dart';
import 'package:latlong2/latlong.dart';

class MyRequestScreen extends StatelessWidget {
  const MyRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String id = ModalRoute.of(context)?.settings.arguments as String;

    return BloodDonationRequestScreen(id: id);
  }
}

class BloodDonationRequestScreen extends StatefulWidget {
  final String id;
  const BloodDonationRequestScreen({super.key, required this.id});

  @override
  BloodDonationRequestScreenState createState() =>
      BloodDonationRequestScreenState();
}

class BloodDonationRequestScreenState
    extends State<BloodDonationRequestScreen> {
  late List<BloodBank> bloodBanks = [];
  String requestUserId = '';
  String userId = '';

  @override
  void initState() {
    super.initState();
    fetchBloodBanks();
    userId = getUserId();
  }

  String getUserId() {
    final User? user = FirebaseAuth.instance.currentUser;
    String userId = user!.uid;
    return userId;
  }

  Future<void> decreasePoints() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint("No user is currently logged in.");
        return;
      }
      userId = user.uid;
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      int currentPoints = userDoc.data()?['points'] ?? 0;
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'points': currentPoints - 1,
      });
    } catch (e) {
      debugPrint("Failed to update points: $e");
    }
  }

  Future<void> fetchBloodBanks() async {
    final DataService dataService = DataService();
    bloodBanks = await dataService.loadBankData();
  }

  Future<Map<String, dynamic>?> fetchRequestById(String id) async {
    final requestDoc =
        await FirebaseFirestore.instance.collection('requests').doc(id).get();

    if (requestDoc.exists) {
      final requestData = requestDoc.data()!;
      requestData['id'] = requestDoc.id;
      requestUserId = requestDoc['userId'];

      return requestData;
    }
    return null;
  }

  Future<void> deleteRequest(
      String id, String requestDateTime, String requestState) async {
    try {
      DateTime requestDate = DateTime.parse(requestDateTime);
      DateTime now = DateTime.now();

      if (requestState == "1") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لا يمكن حذف الطلب لأنه تم قبوله')),
        );
        return;
      }

      if (requestDate.isBefore(now)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لا يمكن حذف الطلب لأنه في تاريخ سابق')),
        );
        return;
      }
      await FirebaseFirestore.instance.collection('requests').doc(id).delete();
      decreasePoints();
      Navigator.pushReplacementNamed(context, '/myrequests');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حذف الطلب بنجاح')),
      );
    } catch (e) {
      debugPrint("Failed to delete request: $e");
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
        title: const Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              'طلب التبرع بالدم',
              textAlign: TextAlign.right,
              style: TextStyle(
                  fontFamily: 'HSI', fontSize: 30, color: Colors.black),
            ),
          ),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: fetchRequestById(widget.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('حدث خطأ ما.'));
          } else if (snapshot.hasData && snapshot.data != null) {
            final requestData = snapshot.data!;
            String bankId = requestData['bankId'];
            String bankName = 'Unknown Bank';
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
            debugPrint('$userId and $requestUserId');
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
                  userId: userId,
                  requestUserId: requestUserId,
                  onDelete: () {
                    deleteRequest(
                      requestData['id'],
                      requestData['dateTime'],
                      requestData['state'],
                    );
                  },
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
  final String userId;
  final String requestUserId;
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
    required this.userId,
    required this.requestUserId,
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
              ' تفاصيل طلب التبرع',
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
            if (userId == requestUserId)
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
              color: Colors.grey,
              blurRadius: 5.0,
              spreadRadius: 0.0,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 25,
                fontFamily: 'HSI',
                fontWeight: FontWeight.bold,
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
        Icon(icon, size: 24.0, color: const Color(0xFFAE0E03)),
        const SizedBox(width: 8.0),
        Expanded(
          child: Text(
            '$label:    $value',
            style: const TextStyle(fontFamily: 'HSI', fontSize: 16),
          ),
        ),
      ],
    );
  }
}

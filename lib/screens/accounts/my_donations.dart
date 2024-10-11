// ignore_for_file: use_build_context_synchronously
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyDonationsScreen extends StatelessWidget {
  const MyDonationsScreen({super.key});

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
              'تبرعاتي ',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: 'HSI',
                fontSize: 30,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
      body: const DonationsList(),
    );
  }
}

class DonationsList extends StatefulWidget {
  const DonationsList({super.key});

  @override
  DonationsListState createState() => DonationsListState();
}

class DonationsListState extends State<DonationsList> {
  late Future<List<Map<String, dynamic>>> _donationsData;

  @override
  void initState() {
    super.initState();
    _donationsData = _fetchDonationsData();
  }

  Future<List<Map<String, dynamic>>> _fetchDonationsData() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('userId', isEqualTo: user.uid)
          .orderBy('timestamp', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => {'id': doc.id, 'data': doc.data()})
          .toList();
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _donationsData,
      builder: (BuildContext context,
          AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('حدث خطأ أثناء تحميل البيانات'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('لا توجد بيانات متاحة'));
        } else {
          final donations = snapshot.data!;
          return ListView.builder(
            itemCount: donations.length,
            itemBuilder: (context, index) {
              final donationData = donations[index]['data'];
              return _buildDonationCard(donationData);
            },
          );
        }
      },
    );
  }

  Widget _buildDonationCard(Map<String, dynamic> donationData) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(112, 112, 112, 100),
                blurRadius: 5,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                donationData['center'] ?? 'Unknown Center',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontFamily: 'HSI',
                  fontSize: 30,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16.0),
              InfoRow(
                icon: Icons.calendar_today,
                label: 'تاريخ الموعد',
                value: donationData['date'] ?? 'Unknown Date',
              ),
              const Divider(),
              InfoRow(
                icon: Icons.access_time,
                label: 'وقت الموعد',
                value: donationData['timeSlot'] ?? 'Unknown Time',
              ),
              const Divider(),
              InfoRow(
                icon: Icons.local_hospital,
                label: 'نوع التبرع',
                value: donationData['donationType'] ?? 'Unknown Type',
              ),
              const Divider(),
              InfoRow(
                icon: donationData['done'] ? Icons.check_circle : Icons.cancel,
                label: 'الحالة',
                value: donationData['done'] ? 'تمت' : 'لم تتم',
              ),
            ],
          ),
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

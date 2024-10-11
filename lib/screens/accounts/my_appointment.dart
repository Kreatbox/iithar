// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyAppointmentScreen extends StatelessWidget {
  const MyAppointmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: BookingSummaryScreen(),
    );
  }
}

class BookingSummaryScreen extends StatefulWidget {
  const BookingSummaryScreen({super.key});

  @override
  BookingSummaryScreenState createState() => BookingSummaryScreenState();
}

class BookingSummaryScreenState extends State<BookingSummaryScreen> {
  var _isButtonDisabled = false;
  late Future<Map<String, dynamic>?> _appointmentData;

  @override
  void initState() {
    super.initState();
    _appointmentData = _fetchAppointmentData();
  }

  Future<Map<String, dynamic>?> _fetchAppointmentData() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final oneWeekAgo = DateTime.now().subtract(const Duration(days: 7));

      final querySnapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('userId', isEqualTo: user.uid)
          .where('timestamp', isGreaterThan: Timestamp.fromDate(oneWeekAgo))
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return {
          'id': querySnapshot.docs.first.id,
          'data': querySnapshot.docs.first.data(),
        };
      }
    }
    return null;
  }

  Future<void> _deleteAppointment(String appointmentId) async {
    await FirebaseFirestore.instance
        .collection('appointments')
        .doc(appointmentId)
        .delete();
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
            'ملخص الحجز',
            style: TextStyle(
              fontFamily: 'HSI',
              fontSize: 30,
              color: Colors.black,
            ),
          ),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _appointmentData,
        builder: (BuildContext context,
            AsyncSnapshot<Map<String, dynamic>?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('حدث خطأ أثناء تحميل البيانات'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('لا توجد بيانات متاحة'));
          } else {
            final appointmentId = snapshot.data!['id'];
            final appointmentData = snapshot.data!['data'];
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildInfoSection(
                    appointmentData['center'] ?? 'Unknown Center',
                    [
                      InfoRow(
                        icon: Icons.calendar_today,
                        label: 'تاريخ الموعد',
                        value: appointmentData['date'] ?? 'Unknown Date',
                      ),
                      const Divider(),
                      InfoRow(
                        icon: Icons.access_time,
                        label: 'وقت الموعد',
                        value: appointmentData['timeSlot'] ?? 'Unknown Time',
                      ),
                      const Divider(),
                      const InfoRow(
                        icon: Icons.hourglass_empty,
                        label: 'مدة التبرع',
                        value: '15 دقيقة',
                      ),
                      const Divider(),
                      InfoRow(
                        icon: Icons.local_hospital,
                        label: 'نوع التبرع',
                        value:
                            appointmentData['donationType'] ?? 'Unknown Type',
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: _isButtonDisabled
                            ? null
                            : () async {
                                if (appointmentId != null) {
                                  setState(() {
                                    _isButtonDisabled = true;
                                  });
                                  await _deleteAppointment(appointmentId);
                                  setState(() {
                                    _appointmentData = _fetchAppointmentData();
                                  });
                                }
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text(
                                        'إلغاء الموعد',
                                        style: TextStyle(
                                          fontFamily: 'HSI',
                                          fontSize: 25,
                                          color: Colors.black,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      content: const Text(
                                        'تم إلغاء الموعد. ننصحك بحجز موعد آخر بأقرب فرصة.',
                                        style: TextStyle(
                                          fontFamily: 'HSI',
                                          fontSize: 20,
                                          color: Colors.black,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text(
                                            'حسناً',
                                            style: TextStyle(
                                              fontFamily: 'HSI',
                                              fontSize: 20,
                                              color: Color(0xFFAE0E03),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFAE0E03),
                        ),
                        child: const Text(
                          'إلغاء الموعد',
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
                ],
              ),
            );
          }
        },
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
              color: Color.fromRGBO(112, 112, 112, 100),
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

// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iithar/models/donation_request.dart';
import 'package:iithar/services/notification_service.dart';
import 'package:intl/intl.dart';
import '../models/blood_bank.dart';
import '../services/data_service.dart';
import 'dart:ui' as ui;

class DonateNowScreen extends StatelessWidget {
  final DonationRequest donationRequest;

  const DonateNowScreen({super.key, required this.donationRequest});

  @override
  Widget build(BuildContext context) {
    DateTime requestDateTime = DateTime.parse(donationRequest.dateTime);
    Duration timeLeft = requestDateTime.isAfter(DateTime.now())
        ? requestDateTime.difference(DateTime.now())
        : Duration.zero;

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
        child: FutureBuilder<List<BloodBank>>(
          future: DataService().loadBankData(), // Fetch bank data
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator(); // Show a loading indicator while fetching data
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text('No bank data available');
            } else {
              List<BloodBank> bankData = snapshot.data!;
              return Column(
                children: [
                  UserInfoCard(
                      donationRequest: donationRequest,
                      timeLeft: timeLeft,
                      bankData: bankData),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _confirmDonation(context, donationRequest, bankData);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFAE0E03),
                    ),
                    child: const Text(
                      'قبول الطلب',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'HSI',
                        fontSize: 25,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}

Future<String?> _createAppointment(String userId,
    DonationRequest donationRequest, List<BloodBank> bankData) async {
  DateTime requestDateTime = DateTime.parse(donationRequest.dateTime);
  final bank =
      bankData.firstWhere((bank) => bank.bankId == donationRequest.bankId);
  String center = bank.name;
  String donationType = "الدم الكامل";
  final String day = DateFormat('d').format(requestDateTime);
  final String year = DateFormat('yyyy').format(requestDateTime);
  final String month = _getMonthName(requestDateTime.month);
  String date = "$day $month $year";
  String timeSlot = DateFormat('hh:mm a').format(requestDateTime);
  Map<String, dynamic> appointmentData = {
    'center': center,
    'date': date,
    'donationType': donationType,
    'done': false,
    'timeSlot': timeSlot,
    'timestamp': FieldValue.serverTimestamp(),
    'userId': userId,
  };

  try {
    // إضافة البيانات إلى Firestore والحصول على مرجع المستند
    DocumentReference docRef = await FirebaseFirestore.instance
        .collection('appointments')
        .add(appointmentData);

    // استرجاع وإرجاع doc.id الخاص بالمستند الذي تم إنشاؤه
    return docRef.id;
  } catch (e) {
    debugPrint("Failed to create appointment: $e");
    return null;
  }
}

String _getMonthName(int month) {
  const monthNames = [
    'كانون الثاني',
    'شباط',
    'آذار',
    'نيسان',
    'أيار',
    'حزيران',
    'تموز',
    'آب',
    'أيلول',
    'تشرين الأول',
    'تشرين الثاني',
    'كانون الأول',
  ];
  return monthNames[month - 1];
}

Future<void> _scheduleDonationReminder(DonationRequest donationRequest) async {
  DateTime selectedDateTime = DateTime.parse(donationRequest.dateTime);
  DateTime reminderTime = selectedDateTime.subtract(const Duration(hours: 1));
  int notificationId =
      DateTime.now().month + DateTime.now().day + DateTime.now().hour;
  final NotificationService notificationService = NotificationService();
  await notificationService.scheduleNotification(
    notificationId,
    'موعد تبرع بالدم',
    'تذكير بموعدك للتبرع بالدم في ${donationRequest.bankId} في الساعة ${DateFormat('hh:mm a').format(selectedDateTime)} في التاريخ ${DateFormat('d MMMM yyyy').format(selectedDateTime)}',
    reminderTime,
  );
}

void _confirmDonation(BuildContext context, DonationRequest donationRequest,
    List<BloodBank> bankData) async {
  final User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    String userId = user.uid;

    // Check the last appointment date
    QuerySnapshot appointmentSnapshot = await FirebaseFirestore.instance
        .collection('appointments')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (appointmentSnapshot.docs.isNotEmpty) {
      Map<String, dynamic> lastAppointmentData =
          appointmentSnapshot.docs.first.data() as Map<String, dynamic>;
      DateTime lastAppointmentDate = lastAppointmentData['timestamp']
          .toDate(); // Use Firestore timestamp directly

      // Check if the last appointment was within the last month
      DateTime oneMonthAgo = DateTime.now().subtract(const Duration(days: 0));
      if (lastAppointmentDate.isAfter(oneMonthAgo)) {
        _showErrorDialog(
            context, 'لا يمكنك قبول الطلب. لقد قمت بالتبرع خلال الشهر الماضي.');
        return;
      }
    }

    // Proceed with the donation acceptance process

    try {
      String? acceptedDonation =
          await _createAppointment(userId, donationRequest, bankData);
      Map<String, dynamic> updatedData = {
        'state': '1',
        'acceptedDonation': acceptedDonation,
      };
      await FirebaseFirestore.instance
          .collection('requests')
          .doc(donationRequest.id)
          .update(updatedData);

      await _scheduleDonationReminder(donationRequest);
      _showConfirmationDialog(context);
    } catch (e) {
      if (kDebugMode) {
        print("Error updating donation request: $e");
      }
    }
  }
}

void _showErrorDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'تنبيه',
          textAlign: TextAlign.center,
          style:
              TextStyle(fontSize: 25, fontFamily: 'BAHIJ', color: Colors.black),
        ),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontSize: 18, fontFamily: 'BAHIJ', color: Colors.black),
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

void _showConfirmationDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'شكراً لك على مساهمتك في إنقاذ حياة',
          textAlign: TextAlign.center,
          style:
              TextStyle(fontSize: 25, fontFamily: 'BAHIJ', color: Colors.black),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(height: 16.0),
            const Text('لقد تم إرسال قبول للمتبرع',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 18, fontFamily: 'BAHIJ', color: Colors.black)),
            const SizedBox(height: 25.0),
            Image.asset('assets/icons/icon6.png', width: 90, height: 90),
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

class UserInfoCard extends StatelessWidget {
  final DonationRequest donationRequest;
  final Duration timeLeft;
  final List<BloodBank> bankData; // Add a reference to the bank data

  const UserInfoCard({
    super.key,
    required this.donationRequest,
    required this.timeLeft,
    required this.bankData, // Accept the bank data in the constructor
  });

  @override
  Widget build(BuildContext context) {
    // Find the bank name using bankId
    String bankName = _getBankName(donationRequest.bankId);
    debugPrint('$timeLeft');

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
            textDirection: ui.TextDirection.rtl,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    CircleAvatar(
                      backgroundColor: Colors.grey[20],
                      radius: 20.0,
                      child: const Icon(Icons.person,
                          color: Color(0xFFAE0E03), size: 20),
                    ),
                    const SizedBox(width: 16.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          donationRequest.name,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                              fontSize: 20, fontFamily: 'BAHIJ'),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                _buildDetailRow(
                  context,
                  icon: Icons.bloodtype,
                  label: 'فصيلة الدم المطلوبة:',
                  value: donationRequest.bloodType,
                ),
                _buildDetailRow(
                  context,
                  icon: Icons.timer,
                  label: 'الوقت المتبقي:',
                  value: _formatTimeLeft(timeLeft),
                ),
                _buildDetailRow(
                  context,
                  icon: Icons.location_on,
                  label: 'الموقع:',
                  value: bankName,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getBankName(String bankId) {
    // Find the bank name by bankId
    final bank = bankData.firstWhere((bank) => bank.bankId == bankId);
    return bank.name; // Return 'غير متوفر' if bank is not found
  }

  String _formatTimeLeft(Duration duration) {
    // Format the duration to days, hours, and minutes
    StringBuffer buffer = StringBuffer();
    if (duration.inDays > 0) {
      buffer.write('${duration.inDays} يوم و');
    }
    if (duration.inHours.remainder(24) > 0) {
      buffer.write('${duration.inHours.remainder(24)} ساعة');
    } else if (duration.inMinutes.remainder(24) > 0) {
      buffer.write('${duration.inHours.remainder(24)} دقيقة');
    }
    return buffer.toString();
  }

  Widget _buildDetailRow(BuildContext context,
      {required IconData icon, required String label, required String value}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Icon(icon, color: const Color(0xFFAE0E03)),
        const SizedBox(width: 8.0),
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontFamily: 'BAHIJ'),
        ),
        const SizedBox(width: 16.0),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontFamily: 'BAHIJ'),
        ),
      ],
    );
  }
}

// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iithar/models/blood_bank.dart';
import 'package:iithar/services/data_service.dart';
import 'package:intl/intl.dart';

class BankAppintment extends StatefulWidget {
  const BankAppintment({super.key});

  @override
  State<BankAppintment> createState() => _BankAppintmentState();
}

class _BankAppintmentState extends State<BankAppintment> {
  List<BloodBank> _bloodBanks = [];
  bool isOldDonations = false;
  bool isNewDonations = true;
  List<DonationRequest> newDonations = [];
  List<DonationRequest> oldDonations = [];
  List<DonationRequest> donationRequests = [];

  @override
  void initState() {
    super.initState();
    _loadAppointments();
    _loadBloodBanks();
  }

  Future<void> _loadBloodBanks() async {
    DataService dataService = DataService();
    List<BloodBank> banks = await dataService.loadBankData();
    setState(() {
      _bloodBanks = banks;
    });
  }

  final Map<String, String> arabicToEnglishMonths = {
    'كانون الثاني': 'January',
    'شباط': 'February',
    'آذار': 'March',
    'نيسان': 'April',
    'أيار': 'May',
    'حزيران': 'June',
    'تموز': 'July',
    'آب': 'August',
    'أيلول': 'September',
    'تشرين الأول': 'October',
    'تشرين الثاني': 'November',
    'كانون الأول': 'December',
  };

  String convertArabicDateToEnglish(String arabicDate) {
    arabicToEnglishMonths.forEach((arabicMonth, englishMonth) {
      arabicDate = arabicDate.replaceAll(arabicMonth, englishMonth);
    });
    return arabicDate;
  }

  // Function to load appointments and corresponding user data
  Future<void> _loadAppointments() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .get();

      final id =
          userDoc.data()!['role']; // Access the 'role' field from Firestore

      // Get all appointments from Firestore
      String bankName =
          _bloodBanks.firstWhere((bank) => bank.bankId == id).name;
      final appointmentSnapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('center', isEqualTo: bankName)
          .where('done', isEqualTo: false)
          .get();

      // Iterate through each appointment
      for (var doc in appointmentSnapshot.docs) {
        var data = doc.data();
        String userId = data['userId']; // Extract userId from appointment
        // Fetch user data from Firestore based on userId
        final userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();
        if (userSnapshot.exists) {
          var userData = userSnapshot.data()!;
          String englishDate = convertArabicDateToEnglish(data['date']);
          String fullDateTimeString = '$englishDate ${data['timeSlot']}}';
          DateTime selectedDateTime =
              DateFormat('d MMMM yyyy hh:mm a').parse(fullDateTimeString);
          final oneHourAgo = DateTime.now().subtract(const Duration(hours: 1));
          if (selectedDateTime.isAfter(oneHourAgo)) {
            newDonations.add(
              DonationRequest(
                firstName: userData['firstName'],
                lastName: userData['lastName'],
                bloodType: userData['bloodType'],
                ssid: userData['ssid'],
                date: selectedDateTime,
                status: data['done'],
                userId: data['userId'],
                appointmentId: doc.id,
              ),
            );
          } else {
            oldDonations.add(
              DonationRequest(
                firstName: userData['firstName'],
                lastName: userData['lastName'],
                bloodType: userData['bloodType'],
                ssid: userData['ssid'],
                date: selectedDateTime,
                status: data['done'],
                userId: data['userId'],
                appointmentId: doc.id,
              ),
            );
          }
        }
      }
      newDonations.sort((a, b) => a.date.compareTo(b.date));
      oldDonations.sort((a, b) => a.date.compareTo(b.date));
    } catch (e) {
      // Handle any errors
      debugPrint("Error loading appointments: $e");
    }
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
            'مواعيد التبرع',
            style: TextStyle(
              fontFamily: 'HSI',
              fontSize: 30,
              color: Colors.black,
            ),
          ),
        ),
        elevation: 0,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _filterChip(
                    context,
                    label: 'المواعيد القديمة',
                    isSelected: isOldDonations,
                    onSelected: (value) {
                      setState(() {
                        isOldDonations = true; // تحديث حالة الزر الأول
                        isNewDonations = false;
                        if (isOldDonations) {
                          donationRequests = oldDonations;
                        }
                      });
                    },
                  ),
                  const SizedBox(width: 15),
                  _filterChip(
                    context,
                    label: 'المواعيد الجديدة',
                    isSelected: isNewDonations,
                    onSelected: (value) {
                      setState(() {
                        isNewDonations = true; // تحديث حالة الزر الثاني
                        isOldDonations = false;
                        if (isNewDonations) {
                          donationRequests = newDonations;
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: donationRequests.length,
              itemBuilder: (context, index) {
                DonationRequest request = donationRequests[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(width: 0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    title: Row(
                      children: [
                        if (isNewDonations)
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shadowColor:
                                  const Color.fromRGBO(112, 112, 112, 0.4),
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            onPressed: () {
                              _confirmDonation(request);
                            },
                            child: const Text(
                              'تأكيد التبرع',
                              style: TextStyle(
                                fontFamily: 'BAHIJ',
                                fontSize: 18,
                                color: Color(0xFFAE0E03),
                              ),
                            ),
                          ),
                        const SizedBox(width: 10.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'اسم المتبرع: ${request.firstName + request.lastName}',
                                style: const TextStyle(
                                  fontFamily: 'HSI',
                                  fontSize: 18,
                                  color: Colors.black,
                                ),
                              ),
                              Text('زمرة الدم: ${request.bloodType}',
                                  style: const TextStyle(
                                    fontFamily: 'HSI',
                                    fontSize: 18,
                                    color: Colors.black,
                                  )),
                              Text('الرقم الوطني: ${request.ssid}',
                                  style: const TextStyle(
                                    fontFamily: 'HSI',
                                    fontSize: 18,
                                    color: Colors.black,
                                  )),
                              Text(
                                  'تاريخ ووقت التبرع: ${request.date.toLocal()}'
                                      .substring(0, 35),
                                  style: const TextStyle(
                                    fontFamily: 'HSI',
                                    fontSize: 18,
                                    color: Colors.black,
                                  )),
                              Text('حالة التبرع: ${request.status}',
                                  style: const TextStyle(
                                    fontFamily: 'HSI',
                                    fontSize: 18,
                                    color: Colors.black,
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDonation(DonationRequest request) async {
    setState(() {
      request.status = true; // Update the local status to true
    });
    try {
      // Update the user's validated field
      await FirebaseFirestore.instance
          .collection('users')
          .doc(request.userId)
          .update({'validated': true});
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(request.userId) // Get the user's document
          .get();
      int currentPoints =
          userDoc.data()?['points'] ?? 0; // Get current points or default to 0
      await FirebaseFirestore.instance
          .collection('users')
          .doc(request.userId)
          .update({'points': currentPoints + 1}); // Increment points by 1
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(request.appointmentId) // Use the appointmentId from the request
          .update({'done': true}); // Mark it as done
      newDonations.removeWhere(
          (donation) => donation.appointmentId == request.appointmentId);
      donationRequests = newDonations;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'تأكيد التبرع',
                  style: TextStyle(
                    fontFamily: 'HSI',
                    fontSize: 25,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 16),
                Text(
                  'تم تأكيد التبرع بنجاح',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'HSI',
                    fontSize: 25,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFAE0E03),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text(
                  'موافق',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'HSI',
                    fontSize: 25,
                    color: Colors.white,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      debugPrint("Error confirming donation: $e");
    }
  }

  Widget _filterChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required ValueChanged<bool> onSelected,
  }) {
    return FilterChip(
      labelPadding: const EdgeInsets.all(0),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
        side: BorderSide(
          color: isSelected
              ? const Color(0xFFAE0E03)
              : const Color.fromRGBO(112, 112, 112, 1),
        ),
      ),
      label: Text(
        label,
        style: TextStyle(
          fontFamily: 'HSI',
          fontSize: 18,
          color: isSelected
              ? const Color(0xFFAE0E03)
              : const Color.fromRGBO(112, 112, 112, 1),
        ),
      ),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: Colors.white,
    );
  }
}

class DonationRequest {
  final String firstName;
  final String lastName;
  final String bloodType;
  final String ssid;
  final DateTime date;
  bool status;
  final String userId;
  final String appointmentId;

  DonationRequest({
    required this.firstName,
    required this.lastName,
    required this.bloodType,
    required this.ssid,
    required this.date,
    required this.status,
    required this.userId,
    required this.appointmentId,
  });
}

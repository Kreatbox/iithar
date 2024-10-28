// ignore_for_file: use_build_context_synchronously

import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iithar/models/blood_bank.dart';
import 'package:iithar/services/data_service.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

class BankAppintment extends StatefulWidget {
  const BankAppintment({super.key});

  @override
  State<BankAppintment> createState() => _BankAppintmentState();
}

class _BankAppintmentState extends State<BankAppintment> {
  List<BloodBank> _bloodBanks = [];
  bool isOldDonations = false;
  bool isNewDonations = true;
  bool _isLoading = true; // Loading state
  List<DonationRequest> newDonations = [];
  List<DonationRequest> oldDonations = [];
  List<DonationRequest> donationRequests = [];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    // Show loading indicator
    setState(() => _isLoading = true);
    await _loadBloodBanks(); // Load blood banks first
    await _loadAppointments(); // Then load appointments
    setState(() => _isLoading = false); // Hide loading indicator
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

  Future<void> _loadAppointments() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;

      // Fetch user role from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .get();
      final userRole = userDoc.data()?['role'] ?? '';

      // Find the bank name based on role
      String bankName = _bloodBanks
          .firstWhere((bank) => bank.bankId == userRole,
              orElse: () => BloodBank(
                  bankId: '',
                  name: '',
                  hours: '',
                  phoneNumber: '',
                  location: const LatLng(0, 0),
                  place: ''))
          .name;

      if (bankName.isEmpty) return; // Exit if bank not found

      // Get appointments filtered by bank name and status
      final appointmentSnapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('center', isEqualTo: bankName)
          .where('done', isEqualTo: false)
          .get();

      // Populate donations lists
      List<DonationRequest> newDonationsTemp = [];
      List<DonationRequest> oldDonationsTemp = [];

      for (var doc in appointmentSnapshot.docs) {
        var data = doc.data();
        String userId = data['userId'];
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
          var donationRequest = DonationRequest(
            firstName: userData['firstName'],
            lastName: userData['lastName'],
            bloodType: userData['bloodType'],
            ssid: userData['ssid'],
            date: selectedDateTime,
            status: data['done'],
            userId: data['userId'],
            appointmentId: doc.id,
          );

          if (selectedDateTime.isAfter(oneHourAgo)) {
            newDonationsTemp.add(donationRequest);
          } else {
            oldDonationsTemp.add(donationRequest);
          }
        }
      }

      // Update lists and sort them
      setState(() {
        newDonations = newDonationsTemp
          ..sort((a, b) => a.date.compareTo(b.date));
        oldDonations = oldDonationsTemp
          ..sort((a, b) => a.date.compareTo(b.date));
        donationRequests = newDonations;
      });
    } catch (e) {
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
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator()) // Show loading indicator
          : Column(
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
                              isOldDonations = true;
                              isNewDonations = false;
                              donationRequests = oldDonations;
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
                              isNewDonations = true;
                              isOldDonations = false;
                              donationRequests = newDonations;
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
                      return _buildDonationTile(request);
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildDonationTile(DonationRequest request) {
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
                  shadowColor: const Color.fromRGBO(112, 112, 112, 0.4),
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
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Directionality(
                    textDirection: ui.TextDirection.rtl,
                    child: Text(
                      'اسم المتبرع: ${request.firstName + request.lastName}',
                      style: const TextStyle(
                        fontFamily: 'HSI',
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Directionality(
                    textDirection: ui.TextDirection.rtl,
                    child: Text('زمرة الدم: ${request.bloodType}'),
                  ),
                  Directionality(
                    textDirection: ui.TextDirection.rtl,
                    child: Text('رقم الهوية: ${request.ssid}'),
                  ),
                  Directionality(
                    textDirection: ui.TextDirection.rtl,
                    child: Text(
                        'التاريخ والوقت: ${DateFormat('d MMMM yyyy hh:mm a').format(request.date)}'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDonation(DonationRequest request) async {
    try {
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(request.appointmentId)
          .update({'done': true});
      setState(() {
        newDonations.remove(request);
        donationRequests = newDonations;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تأكيد التبرع بنجاح')),
      );
    } catch (e) {
      debugPrint("Error confirming donation: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حدث خطأ أثناء تأكيد التبرع')),
      );
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

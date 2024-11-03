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
  bool _isButtonDisabled = false;
  bool isOldDonations = false;
  bool isNewDonations = true;
  bool _isLoading = true;
  List<DonationRequest> newDonations = [];
  List<DonationRequest> oldDonations = [];
  List<DonationRequest> donationRequests = [];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() => _isLoading = true);
    await _loadBloodBanks();
    await _loadAppointments();
    setState(() => _isLoading = false);
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
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .get();
      final userRole = userDoc.data()?['role'] ?? '';
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
      if (bankName.isEmpty) return;
      final appointmentSnapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('center', isEqualTo: bankName)
          .where('done', isEqualTo: false)
          .get();

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
            phoneNumber: userData['phoneNumber'],
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
          ? const Center(child: CircularProgressIndicator())
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
                onPressed: _isButtonDisabled
                    ? null
                    : () async {
                        setState(() {
                          _isButtonDisabled = true;
                        });
                        final userSnapshot = await FirebaseFirestore.instance
                            .collection('users')
                            .doc(request.userId)
                            .get();
                        bool isValidated =
                            userSnapshot.data()?['validated'] == true;
                        if (isValidated) {
                          _confirmDonation(request);
                          setState(() {
                            _isButtonDisabled = false;
                          });
                        } else {
                          TextEditingController firstNameController =
                              TextEditingController(text: request.firstName);
                          TextEditingController lastNameController =
                              TextEditingController(text: request.lastName);
                          TextEditingController ssidController =
                              TextEditingController(text: request.ssid);
                          TextEditingController phoneNumberController =
                              TextEditingController(text: request.phoneNumber);
                          String selectedBloodType = request.bloodType;
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(

                                backgroundColor: Colors.white,

                                title: const Text("تعديل المعلومات",textAlign: TextAlign.right,),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextField( textAlign: TextAlign.right,
                                      controller: firstNameController,
                                      decoration: const InputDecoration(
                                        alignLabelWithHint: true,
                                          labelText: "اسم المتبرع",),
                                    ),
                                    TextField(
                                      textAlign: TextAlign.right, // محاذاة النص لليمين
                                      controller: lastNameController,
                                      decoration:  InputDecoration(alignLabelWithHint: true,
                                        labelText: "اسم العائلة",
                                        hintText: "أدخل اسم العائلة", // إضافة تلميح نصي
                                      ),
                                      // ضبط اتجاه النص ليكون من اليمين إلى اليسار
                                    ),


                                    TextField(
                                      textAlign: TextAlign.right,
                                      controller: ssidController,
                                      decoration: const InputDecoration(
                                          labelText: "الرقم الوطني"),
                                      keyboardType: TextInputType.number,
                                    ),
                                    DropdownButtonFormField<String>(

                                      value: selectedBloodType,
                                      items: [
                                        'A+',
                                        'A-',
                                        'B+',
                                        'B-',
                                        'O+',
                                        'O-',
                                        'AB+',
                                        'AB-'
                                      ]
                                          .map((bloodType) =>
                                              DropdownMenuItem<String>(
                                                alignment: Alignment.topRight,
                                                value: bloodType,
                                                child: Text(bloodType),
                                              ))
                                          .toList(),
                                      onChanged: (value) {
                                        if (value != null) {
                                          setState(() {
                                            selectedBloodType = value;
                                          });
                                        }
                                      },
                                      decoration: const InputDecoration(hintTextDirection: ui.TextDirection.rtl,
                                          labelText: "زمرة الدم"),
                                    ),
                                    TextField( textDirection: ui.TextDirection.rtl,
                                      controller: phoneNumberController,
                                      decoration: const InputDecoration(
                                          labelText: "رقم الجوال"),
                                      keyboardType: TextInputType.number,
                                    ),
                                  ],
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text("إلغاء"),
                                    onPressed: () {
                                      setState(() {
                                        _isButtonDisabled = false;
                                      });
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  ElevatedButton(
                                    child: const Text("حفظ"),
                                    onPressed: () async {
                                      try {
                                        await FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(request.userId)
                                            .update({
                                          'firstName': firstNameController.text,
                                          'lastName': lastNameController.text,
                                          'ssid': ssidController.text,
                                          'bloodType': selectedBloodType,
                                          'phoneNumber':
                                              phoneNumberController.text,
                                          'validated': true,
                                        });
                                        _confirmDonation(request);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text('تم توثيق الحساب')),
                                        );
                                        setState(() {
                                          _isButtonDisabled = false;
                                        });
                                        Navigator.of(context).pop();
                                      } catch (e) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  'خطأ في توثيق الحساب: $e')),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        }
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
                    child: Text( textAlign: TextAlign.right,
                      'اسم المتبرع: ${request.firstName} ${request.lastName}',
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
                    child: Text('رقم الهاتف: ${request.phoneNumber}'),
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
      final requestsSnapshot = await FirebaseFirestore.instance
          .collection('requests')
          .where('acceptedDonation', isEqualTo: request.appointmentId)
          .get();
      if (requestsSnapshot.docs.isEmpty) {
        final User? user = FirebaseAuth.instance.currentUser;
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .get();
        final userRole = userDoc.data()?['role'] ?? '';
        await FirebaseFirestore.instance
            .collection('amounts')
            .doc(userRole)
            .update({
          request.bloodType: FieldValue.increment(1),
        });
        await FirebaseFirestore.instance.collection('amountLogs').add({
          'bankId': userRole,
          'timestamp': FieldValue.serverTimestamp(),
          'userId': request.userId,
          request.bloodType: 1,
        });
      }
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
  final String phoneNumber;
  final DateTime date;
  bool status;
  final String userId;
  final String appointmentId;

  DonationRequest({
    required this.firstName,
    required this.lastName,
    required this.bloodType,
    required this.ssid,
    required this.phoneNumber,
    required this.date,
    required this.status,
    required this.userId,
    required this.appointmentId,
  });
}

// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentBookingScreen extends StatefulWidget {
  const AppointmentBookingScreen({super.key});

  @override
  _AppointmentBookingScreenState createState() =>
      _AppointmentBookingScreenState();
}

class _AppointmentBookingScreenState extends State<AppointmentBookingScreen> {
  bool _isButtonDisabled = false;
  String? _selectedCenter;
  String? _selectedDonationType;
  String? _selectedDate;
  String? _selectedTimeSlot;

  final List<String> _centers = [
    'بنك الدم - دمشق',
    'بنك الدم - حمص',
    'بنك الدم - حلب',
    'بنك الدم - حماة',
    'بنك الدم - طرطوس',
  ];

  final List<String> _donationTypes = [
    'الدم الكامل',
    'الصفائح الدموية',
  ];

  final List<String> _dates = [
    '7 مايو',
    '8 مايو',
    '9 مايو',
    '10 مايو',
    '11 مايو',
    '12 مايو',
  ];

  final List<String> _timeSlots = [
    '11:30 ص',
    '12:00 م',
    '12:30 م',
    '01:00 م',
    '01:30 م',
    '02:00 م',
  ];

  void _resetSelections() {
    setState(() {
      _selectedCenter = null;
      _selectedDonationType = null;
      _selectedDate = null;
      _selectedTimeSlot = null;
    });
  }

  Future<void> _saveBooking() async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      await FirebaseFirestore.instance.collection('appointments').add({
        'userId': user.uid,
        'center': _selectedCenter,
        'donationType': _selectedDonationType,
        'date': _selectedDate,
        'timeSlot': _selectedTimeSlot,
        'timestamp': FieldValue.serverTimestamp(),
      });
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
              'حجز موعد تبرع بالدم',
              textAlign: TextAlign.right,
              style: TextStyle(
                  fontFamily: 'HSI', fontSize: 30, color: Colors.black),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Image.asset(
            'assets/Images/Ve.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('اختر مركز'),
                          content: SizedBox(
                            width: double.maxFinite,
                            child: ListView(
                              shrinkWrap: true,
                              children: _centers.map((center) {
                                return ListTile(
                                  title:
                                      Text(center, textAlign: TextAlign.right),
                                  onTap: () {
                                    setState(() {
                                      _selectedCenter = center;
                                    });
                                    Navigator.of(context).pop();
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: AbsorbPointer(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: _selectedCenter ?? 'اختر مركز',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'اختر نوع التبرع',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _donationTypes.map((type) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedDonationType = type;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          color: _selectedDonationType == type
                              ? const Color(0xFFAE0E03)
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          type,
                          style: TextStyle(
                            color: _selectedDonationType == type
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                const Text(
                  'اختر تاريخ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _dates.map((date) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedDate = date;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                            color: _selectedDate == date
                                ? const Color(0xFFAE0E03)
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            date,
                            style: TextStyle(
                              color: _selectedDate == date
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'اختر وقت',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _timeSlots.map((slot) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedTimeSlot = slot;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                            color: _selectedTimeSlot == slot
                                ? const Color(0xFFAE0E03)
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            slot,
                            style: TextStyle(
                              color: _selectedTimeSlot == slot
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFAE0E03),
                  ),
                  onPressed: _isButtonDisabled
                      ? null
                      : () async {
                          if (_selectedCenter != null &&
                              _selectedDonationType != null &&
                              _selectedDate != null &&
                              _selectedTimeSlot != null) {
                            setState(() {
                              _isButtonDisabled = true;
                            });
                            await _saveBooking();
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('تأكيد الحجز'),
                                  content: Text(
                                      'تم حجز موعدك في $_selectedCenter للتبرع بـ $_selectedDonationType في تاريخ $_selectedDate في وقت $_selectedTimeSlot'),
                                  actions: [
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        setState(() {
                                          _isButtonDisabled = false;
                                        });
                                      },
                                      child: const Text('تأكيد'),
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('لم يتم استكمال الحجز'),
                              ),
                            );
                          }
                        },
                  child: const Text(
                    'احجز موعد',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'HSI', fontSize: 25, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      fixedSize: const Size(175, 45),
                      backgroundColor: const Color(0xFFAE0E03),
                      padding: const EdgeInsets.only(
                          right: 25.0, left: 25.0, top: 5.0, bottom: 1.0),
                      alignment: Alignment.center),
                  onPressed: _resetSelections,
                  child: const Text(
                    'مسح البيانات',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'HSI', fontSize: 25, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

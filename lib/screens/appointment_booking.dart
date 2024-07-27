import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:latlong2/latlong.dart';

class AppointmentBookingScreen extends StatefulWidget {
  const AppointmentBookingScreen({super.key});

  @override
  AppointmentBookingScreenState createState() =>
      AppointmentBookingScreenState();
}

class AppointmentBookingScreenState extends State<AppointmentBookingScreen> {
  bool _isButtonDisabled = false;
  String? _selectedCenter;
  String? _selectedDonationType;
  String? _selectedDate;
  String? _selectedTimeSlot;
  List<BloodBank> _bloodBanks = [];
  Map<String, String> _bankHours = {}; // Map for bankId to hours

  final List<String> _donationTypes = [
    'الدم الكامل',
    'الصفائح الدموية',
  ];

  List<String> _dates = [];
  List<String> _timeSlots = [];

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ar', null).then((_) {
      setState(() {
        _generateDates();
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final Map<String, dynamic>? arguments =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final String? defaultBankId = arguments?['bankId'];
      final String? hours = arguments?['hours'];

      _fetchBloodBanks(defaultBankId, hours);
    });
  }

  Future<void> _fetchBloodBanks(String? defaultBankId, String? hours) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot querySnapshot = await firestore.collection('banks').get();

    final List<BloodBank> fetchedBanks = [];
    final Map<String, String> bankHours = {};

    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      String bankId = doc.id;
      String name = data['name'];
      String hours = data['hours'];
      String phoneNumber = data['phoneNumber'];
      String location = data['location'];
      List<String> coordinates = location.split(',');
      double latitude = double.parse(coordinates[0]);
      double longitude = double.parse(coordinates[1]);
      fetchedBanks.add(BloodBank(
        bankId: bankId,
        name: name,
        hours: hours,
        phoneNumber: phoneNumber,
        location: LatLng(latitude, longitude),
      ));
      bankHours[bankId] = hours; // Updated to store hours as a string
    }

    setState(() {
      _bloodBanks = fetchedBanks;
      _bankHours = bankHours;

      if (fetchedBanks.isNotEmpty) {
        final defaultBank = (defaultBankId != null)
            ? fetchedBanks.firstWhere(
                (bank) => bank.bankId == defaultBankId,
                orElse: () => fetchedBanks[0],
              )
            : fetchedBanks[0];
        _selectedCenter = defaultBank.name;
        final hours = _bankHours[defaultBank.bankId] ?? '';
        _updateTimeSlots(hours);
      }
    });
  }

  void _generateDates() {
    final DateFormat formatter = DateFormat('d MMMM', 'ar');
    final DateTime today = DateTime.now();
    _dates = List.generate(7, (index) {
      final DateTime date = today.add(Duration(days: index));
      return formatter.format(date);
    });
  }

  void _updateTimeSlots(String hours) {
    final List<String> splitHours = hours.split(' - ');
    if (splitHours.length != 2) {
      return; // Invalid hours format
    }

    final DateFormat timeFormat = DateFormat('H:mm');
    final DateTime openingTime = timeFormat.parse(splitHours[0]);
    final DateTime closingTime = timeFormat.parse(splitHours[1]);

    // Ensure the last booking is at least 15 minutes before closing
    final DateTime lastPossibleTime =
        closingTime.subtract(const Duration(minutes: 15));

    List<String> slots = [];
    DateTime currentTime = openingTime;

    while (currentTime.isBefore(lastPossibleTime)) {
      slots.add(DateFormat('hh:mm a').format(currentTime));
      currentTime = currentTime.add(const Duration(minutes: 15));
    }

    setState(() {
      _timeSlots = slots;
    });
  }

  void _resetSelections() {
    setState(() {
      _selectedCenter = _bloodBanks.isNotEmpty ? _bloodBanks[0].name : null;
      _selectedDonationType = null;
      _selectedDate = null;
      _selectedTimeSlot = null;

      if (_selectedCenter != null) {
        final hours = _bankHours[_bloodBanks
                .firstWhere((bank) => bank.name == _selectedCenter)
                .bankId] ??
            '';
        _updateTimeSlots(hours);
      }
    });
  }

  Future<bool> _hasExistingBookingForCurrentMonth() async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final now = DateTime.now();
      final oneMonthAgo = now.subtract(const Duration(days: 30));

      final querySnapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('userId', isEqualTo: user.uid)
          .where('timestamp', isGreaterThanOrEqualTo: oneMonthAgo)
          .get();

      return querySnapshot.docs.isNotEmpty;
    }

    return false;
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
        'done': false,
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
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'اختر مركز تبرع',
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 25, fontFamily: 'HSI'),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: Colors.white,
                          actionsAlignment: MainAxisAlignment.start,
                          title: const Text(
                            'مراكز التبرع',
                            textAlign: TextAlign.right,
                          ),
                          content: SizedBox(
                            width: double.maxFinite,
                            child: ListView(
                              shrinkWrap: true,
                              children: _bloodBanks.map((bank) {
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedCenter = bank.name;
                                      _updateTimeSlots(
                                          _bankHours[bank.bankId] ?? '');
                                    });
                                    Navigator.of(context).pop();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 5),
                                    decoration: BoxDecoration(
                                      color: _selectedCenter == bank.name
                                          ? const Color(0xFFAE0E03)
                                          : Colors.grey[200],
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Text(
                                      bank.name,
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        color: _selectedCenter == bank.name
                                            ? Colors.white
                                            : Colors.black,
                                        fontFamily: 'HSI',
                                      ),
                                    ),
                                  ),
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
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                const Text(
                  'اختر نوع التبرع',
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 25, fontFamily: 'HSI'),
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
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          type,
                          style: TextStyle(
                            color: _selectedDonationType == type
                                ? Colors.white
                                : Colors.black,
                            fontFamily: 'HSI',
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 25),
                const Text(
                  'اختر تاريخ',
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 25, fontFamily: 'HSI'),
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
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            date,
                            style: TextStyle(
                              color: _selectedDate == date
                                  ? Colors.white
                                  : Colors.black,
                              fontFamily: 'HSI',
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 25),
                const Text(
                  'اختر وقت',
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 25, fontFamily: 'HSI'),
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
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            slot,
                            style: TextStyle(
                              color: _selectedTimeSlot == slot
                                  ? Colors.white
                                  : Colors.black,
                              fontFamily: 'HSI',
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 400),
              Container(
                alignment: Alignment.center,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size(175, 45),
                    backgroundColor: const Color(0xFFAE0E03),
                    padding: const EdgeInsets.only(
                        right: 25.0, left: 25.0, top: 5.0, bottom: 1.0),
                    alignment: Alignment.center,
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
                            final hasBooking =
                                await _hasExistingBookingForCurrentMonth();
                            if (hasBooking) {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('تحذير'),
                                    content: const Text(
                                        'لا يمكنك حجز موعد أكثر من مرة في الشهر.'),
                                    actions: [
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          setState(() {
                                            _isButtonDisabled = false;
                                          });
                                        },
                                        child: const Text('موافق'),
                                      ),
                                    ],
                                  );
                                },
                              );
                              return;
                            }
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
              ),
              const SizedBox(height: 10),
              Container(
                alignment: Alignment.center,
                child: ElevatedButton(
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
              ),
              const SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }
}

class BloodBank {
  final String bankId;
  final String name;
  final String hours;
  final String phoneNumber;
  final LatLng location;

  BloodBank({
    required this.bankId,
    required this.name,
    required this.hours,
    required this.phoneNumber,
    required this.location,
  });
}

// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:iithar/services/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:iithar/models/blood_bank.dart';
import 'package:iithar/services/data_service.dart';
import 'dart:ui' as ui;

class AppointmentBookingScreen extends StatefulWidget {
  const AppointmentBookingScreen({super.key});

  @override
  AppointmentBookingScreenState createState() =>
      AppointmentBookingScreenState();
}

class AppointmentBookingScreenState extends State<AppointmentBookingScreen> {
  bool _isButtonDisabled = false;
  String? _selectedCenter;
  String? _selectedBank;
  String? _selectedDonationType;
  String? _selectedDate;
  String? _selectedTimeSlot;
  List<BloodBank> _bloodBanks = [];
  Map<String, String> _bankHours = {};

  final List<String> _donationTypes = [
    'الدم الكامل',
    'الصفائح الدموية',
  ];
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

  Future<void> updateFavouriteBank(String userId, String bankId) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'favouriteBank': bankId,
      });
      debugPrint("Favourite bank updated successfully");
    } catch (e) {
      debugPrint("Failed to update favourite bank: $e");
    }
  }

  Future<void> _fetchBloodBanks(String? defaultBankId, String? hours) async {
    final dataService = DataService();
    List<BloodBank> fetchedBanks = await dataService.loadBankData();
    final Map<String, String> bankHours = {};

    if (fetchedBanks.isEmpty) {
      return;
    }

    for (var bank in fetchedBanks) {
      bankHours[bank.bankId] = bank.hours;
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
        _selectedBank = defaultBank.bankId;
        final hours = _bankHours[defaultBank.bankId] ?? '';
        _updateTimeSlots(hours);
      }
    });
  }

  void _generateDates() {
    final DateTime today = DateTime.now();
    final List<String> arabicMonths = [
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
    _dates = List.generate(7, (index) {
      final DateTime date = today.add(Duration(days: index));
      final String day = DateFormat('d').format(date);
      final String month = arabicMonths[date.month - 1];
      final String year = DateFormat('yyyy').format(date);
      return '$day $month $year';
    });
  }

  void _updateTimeSlots(String hours) {
    final List<String> splitHours = hours.split(' - ');
    if (splitHours.length != 2) {
      return;
    }

    final DateFormat timeFormat = DateFormat('H:mm');
    final DateTime openingTime = timeFormat.parse(splitHours[0]);
    final DateTime closingTime = timeFormat.parse(splitHours[1]);

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
      _selectedBank = null;
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
      final englishDate = convertArabicDateToEnglish('$_selectedDate');
      final fullDateTimeString = '$englishDate $_selectedTimeSlot';
      final DateTime selectedDateTime =
          DateFormat('d MMMM yyyy hh:mm a').parse(fullDateTimeString);
      final oneMonthAgo = selectedDateTime.subtract(const Duration(days: 30));
      final querySnapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('userId', isEqualTo: user.uid)
          .get();
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final String arabicDateStr = data['date'];
        final String timeSlotStr = data['timeSlot'];
        final String englishDateStr = convertArabicDateToEnglish(arabicDateStr);
        final DateTime appointmentDateTime =
            DateFormat('d MMMM yyyy hh:mm a', 'en')
                .parse('$englishDateStr $timeSlotStr');
        if (appointmentDateTime.isAfter(oneMonthAgo) &&
            appointmentDateTime.isBefore(now)) {
          return true;
        }
      }
    }
    return false;
  }

  Future<bool> _requestExists() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('center', isEqualTo: _selectedCenter)
          .where('date', isEqualTo: "$_selectedDate")
          .where('timeSlot', isEqualTo: _selectedTimeSlot)
          .get();

      if (querySnapshot.docs.length >= 2) {
        return true;
      }
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
        'date': "$_selectedDate",
        'timeSlot': _selectedTimeSlot,
        'timestamp': FieldValue.serverTimestamp(),
        'done': false,
      });
      updateFavouriteBank(user.uid, _selectedBank!);
      final englishDate = convertArabicDateToEnglish('$_selectedDate');
      final fullDateTimeString = '$englishDate $_selectedTimeSlot';
      final DateTime selectedDateTime =
          DateFormat('d MMMM yyyy hh:mm a').parse(fullDateTimeString);
      final DateTime reminderTime =
          selectedDateTime.subtract(const Duration(hours: 1));
      final int notificationId = DateTime.now().millisecondsSinceEpoch ~/ 60000;
      final NotificationService notificationService = NotificationService();
      try {
        await notificationService.scheduleNotification(
          notificationId,
          'موعد تبرع بالدم',
          'تذكير بموعدك للتبرع بالدم في $_selectedCenter في الساعة $_selectedTimeSlot في التاريخ $_selectedDate',
          reminderTime,
        );
      } catch (e) {
        debugPrint('Error scheduling notification: $e');
      }
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          actionsAlignment: MainAxisAlignment.start,
                          title: const Text(
                            'مراكز التبرع',
                            style: TextStyle(fontSize: 25, fontFamily: 'HSI'),
                            textAlign: TextAlign.center,
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
                                      _selectedBank = bank.bankId;
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
                    child: Container(
                      width: 400,
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        _selectedCenter ?? 'اختر مركز',
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                            fontSize: 20,
                            fontFamily: 'HSI',
                            color: Colors.black),
                      ),
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
                            child: Directionality(
                              textDirection: ui.TextDirection.rtl,
                              child: Text(
                                date,
                                style: TextStyle(
                                  color: _selectedDate == date
                                      ? Colors.white
                                      : Colors.black,
                                  fontFamily: 'HSI',
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ));
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
                            final hasAnotherConflict = await _requestExists();
                            if (hasBooking) {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text(
                                      'تحذير',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'HSI',
                                        fontSize: 25,
                                        color: Colors.black,
                                      ),
                                    ),
                                    content: const Text(
                                      'لا يمكنك حجز موعد أكثر من مرة في الشهر',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'HSI',
                                        fontSize: 15,
                                        color: Colors.black,
                                      ),
                                    ),
                                    actions: [
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFFAE0E03),
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          setState(() {
                                            _isButtonDisabled = false;
                                          });
                                        },
                                        child: const Text(
                                          'موافق',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontFamily: 'HSI',
                                            fontSize: 15,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                              return;
                            } else if (hasAnotherConflict) {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text(
                                      'تحذير',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'HSI',
                                        fontSize: 25,
                                        color: Colors.black,
                                      ),
                                    ),
                                    content: const Text(
                                      ' لا يمكنك حجز موعد في هذا الوقت المحدد هناك موعد موجود في هذا الوقت',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'HSI',
                                        fontSize: 15,
                                        color: Colors.black,
                                      ),
                                    ),
                                    actions: [
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFFAE0E03),
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          setState(() {
                                            _isButtonDisabled = false;
                                          });
                                        },
                                        child: const Text(
                                          'موافق',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontFamily: 'HSI',
                                            fontSize: 15,
                                            color: Colors.white,
                                          ),
                                        ),
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
                                  title: const Text(
                                    'تأكيد الحجز',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontFamily: 'HSI',
                                        fontSize: 15,
                                        color: Colors.black),
                                  ),
                                  content: Text(
                                      'تم حجز موعدك في $_selectedCenter للتبرع بـ $_selectedDonationType في تاريخ $_selectedDate في وقت $_selectedTimeSlot'),
                                  actions: [
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          fixedSize: const Size(100, 45),
                                          backgroundColor:
                                              const Color(0xFFAE0E03),
                                          padding: const EdgeInsets.only(
                                              top: 5.0, bottom: 1.0),
                                          alignment: Alignment.center),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        setState(() {
                                          _isButtonDisabled = false;
                                        });
                                      },
                                      child: const Text(
                                        'تأكيد',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontFamily: 'HSI',
                                            fontSize: 15,
                                            color: Colors.white),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text(
                                    'لم يتم استكمال الحجز',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'HSI',
                                      fontSize: 25,
                                      color: Colors.black,
                                    ),
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text(
                                        'حسناً',
                                        style: TextStyle(
                                          fontFamily: 'HSI',
                                          fontSize: 18,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
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

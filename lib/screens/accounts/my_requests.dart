import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:iithar/models/blood_bank.dart';
import 'package:iithar/services/data_service.dart'; // استيراد DataService

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class MyRequests extends StatefulWidget {
  const MyRequests({super.key});

  @override
  State<MyRequests> createState() => _MyRequestsState();
}

class _MyRequestsState extends State<MyRequests> {
  late List<Map<String, dynamic>> items = [];
  late List<BloodBank> bloodBanks = []; // قائمة بنوك الدم
  bool isLoaded = false;

  // استدعاء بيانات البنوك والطلبات
  Future<void> fetchData() async {
    final DataService dataService = DataService();

    // تحميل بيانات البنوك
    bloodBanks = await dataService.loadBankData();

    // استدعاء الطلبات
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        isLoaded = true; // لا يوجد مستخدم، لذا نعتبر التحميل مكتملًا
      });
      return;
    }

    final userId = user.uid;
    final querySnapshot = await FirebaseFirestore.instance
        .collection('requests')
        .where('userId', isEqualTo: userId)
        .orderBy('dateTime', descending: true)
        .get();

    List<Map<String, dynamic>> tempList = [];
    if (querySnapshot.docs.isNotEmpty) {
      for (var element in querySnapshot.docs) {
        tempList.add(element.data());
      }
    }

    // ضبط الحالة حتى إذا لم تكن هناك بيانات
    setState(() {
      items = tempList;
      isLoaded = true;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchData(); // استدعاء البيانات
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
            'جميع الطلبات',
            style: TextStyle(
              fontFamily: 'HSI',
              fontSize: 30,
              color: Colors.black,
            ),
          ),
        ),
        elevation: 0,
      ),
      body: isLoaded
          ? items.isNotEmpty
              ? ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    // البحث عن اسم بنك الدم باستخدام bankId
                    String bankId = items[index]["bankId"];
                    String bankName =
                        'Unknown Bank'; // اسم افتراضي في حال لم يُعثر على البنك
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

                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                            side: const BorderSide(width: 0.5),
                            borderRadius: BorderRadius.circular(20)),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
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
                                Navigator.pushNamed(context, '/myrequest');
                              },
                              child: const Text(
                                'عرض التفاصيل',
                                style: TextStyle(
                                  fontFamily: 'BAHIJ',
                                  color: Color(0xFFAE0E03),
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      items[index]["dateTime"] != null
                                          ? items[index]["dateTime"]
                                              .substring(0, 16)
                                          : "غير متوفر",
                                      style: const TextStyle(
                                          fontFamily: 'BAHIJ', fontSize: 14),
                                    ),
                                    Text(
                                      items[index]["medicalCondition"] ??
                                          "غير متوفر",
                                      style: const TextStyle(
                                          fontFamily: 'BAHIJ', fontSize: 14),
                                    ),
                                    Text(
                                      bankName, // عرض اسم بنك الدم
                                      style: const TextStyle(
                                          fontFamily: 'BAHIJ', fontSize: 14),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 10.0),
                                const Icon(
                                  Icons.bloodtype,
                                  color: Color(0xFFAE0E03),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  })
              : const Center(
                  child: Text(
                    'لا توجد طلبات حتى الآن',
                    style: TextStyle(fontFamily: 'BAHIJ', fontSize: 16),
                  ),
                )
          : const Center(
              child: CircularProgressIndicator(),
            ), // Show loading indicator while data is being loaded
    );
  }
}

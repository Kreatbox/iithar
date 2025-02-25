import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BankDonationRequests extends StatefulWidget {
  const BankDonationRequests({super.key});

  @override
  State<BankDonationRequests> createState() => _BankDonationRequestsState();
}

class _BankDonationRequestsState extends State<BankDonationRequests> {
  final oneHourAgo = DateTime.now().subtract(const Duration(hours: 1));

  bool isOldDonations = false;
  bool isNewDonations = true;
  String? bankId;
  int count = 0;

  final TextEditingController _verificationCodeController =
      TextEditingController();
  @override
  void initState() {
    super.initState();
    _loadId();
  }

  Future<void> _loadId() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      setState(() {
        bankId = userDoc.data()?['role'];
      });
    }
  }

  Future<Map<String, String>> _fetchUserNames(List<String> userIds) async {
    final Map<String, String> userNames = {};
    for (var userId in userIds) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      String firstName = userDoc.data()?['firstName'] ?? "";
      String lastName = userDoc.data()?['lastName'] ?? "";
      userNames[userId] = "$firstName $lastName";
    }
    return userNames;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Align(
          alignment: Alignment.centerRight,
          child: Text(
            'طلبات الطوارئ',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontFamily: 'HSI',
              fontSize: 30,
              color: Colors.black,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _filterChip(
                    context,
                    label: 'الطلبات القديمة',
                    isSelected: isOldDonations,
                    onSelected: (value) {
                      setState(() {
                        isOldDonations = value;
                        isNewDonations = !value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: bankId == null
                ? const Center(child: CircularProgressIndicator())
                : StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('requests')
                        .where('bankId', isEqualTo: bankId)
                        .orderBy('dateTime', descending: false)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                            child: Text("No donation requests found"));
                      }
                      final items = snapshot.data!.docs.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return data['name'] != null && data['trusted'] == null;
                      }).map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return {
                          "id": doc.id,
                          "bloodType": data["bloodType"] ?? "Unknown",
                          "userId": data["userId"] ?? "no username",
                          "username": data["name"] ?? "No Name",
                          "dateTime":
                              data["dateTime"] ?? DateTime.now().toString(),
                          "medicalCondition":
                              data["medicalCondition"] ?? "No Condition",
                          "state": data["state"] ?? "0",
                        };
                      }).toList();
                      final oldRequests = items.where((item) {
                        DateTime requestDateTime =
                            DateTime.parse(item["dateTime"]);
                        return requestDateTime.isBefore(oneHourAgo);
                      }).toList();

                      final newRequests = items.where((item) {
                        DateTime requestDateTime =
                            DateTime.parse(item["dateTime"]);
                        return requestDateTime.isAfter(oneHourAgo);
                      }).toList();
                      final filteredItems =
                          isOldDonations ? oldRequests : newRequests;
                      return FutureBuilder<Map<String, String>>(
                        future: _fetchUserNames(
                            items.map((e) => e['userId'] as String).toList()),
                        builder: (context, nameSnapshot) {
                          if (nameSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          if (!nameSnapshot.hasData ||
                              nameSnapshot.data!.isEmpty) {
                            return const Center(
                                child: Text("No donation requests found"));
                          }

                          final userNames = nameSnapshot.data!;

                          return ListView.builder(
                            padding: const EdgeInsets.all(15.0),
                            itemCount: filteredItems.length,
                            itemBuilder: (context, index) {
                              final item = filteredItems[index];
                              final username =
                                  userNames[item['userId']] ?? item['username'];
                              return Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.grey,
                                        spreadRadius: 3,
                                        blurRadius: 5,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: ListTile(
                                    shape: RoundedRectangleBorder(
                                      side: const BorderSide(width: 0.5),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    title: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '${item["bloodType"]}   :الزمرة',
                                          style: const TextStyle(
                                              fontFamily: 'BAHIJ',
                                              fontSize: 14),
                                        ),
                                        Directionality(
                                          textDirection: TextDirection.rtl,
                                          child: Text(
                                            'اسم المستخدم:    $username',
                                            style: const TextStyle(
                                                fontFamily: 'BAHIJ',
                                                fontSize: 14),
                                          ),
                                        ),
                                        Directionality(
                                          textDirection: TextDirection.rtl,
                                          child: Text(
                                            'اسم المريض:    ${item["username"]}',
                                            style: const TextStyle(
                                                fontFamily: 'BAHIJ',
                                                fontSize: 14),
                                          ),
                                        ),
                                        Directionality(
                                          textDirection: TextDirection.rtl,
                                          child: Text(
                                            'التاريخ:   ${(item["dateTime"]).substring(0, 16)}',
                                            style: const TextStyle(
                                                fontFamily: 'BAHIJ',
                                                fontSize: 14),
                                          ),
                                        ),
                                        Text(
                                          'المرض:   ${(item["medicalCondition"])}',
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(
                                            fontFamily: 'BAHIJ',
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          'الحالة:   ${(item["state"] == "1") ? "مقبولة" : "غير مقبولة"}',
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(
                                            fontFamily: 'BAHIJ',
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.pushNamed(
                                                  context,
                                                  '/myrequest',
                                                  arguments: items[index]["id"],
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    const Color(0xFFAE0E03),
                                                shadowColor: Colors.grey,
                                                elevation: 4,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                ),
                                                minimumSize: const Size(50, 30),
                                              ),
                                              child: const Text(
                                                'تفاصيل',
                                                style: TextStyle(
                                                  fontFamily: 'BAHIJ',
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                String code =
                                                    _verificationCodeController
                                                        .text;
                                                if (code.isNotEmpty) {
                                                  final int? numberCode =
                                                      int.tryParse(code);
                                                  if (numberCode != null) {
                                                    FirebaseFirestore.instance
                                                        .collection('requests')
                                                        .doc(items[index]["id"])
                                                        .update({
                                                      'trusted': code
                                                    }).then((_) {
                                                      FirebaseFirestore.instance
                                                          .collection('amounts')
                                                          .doc(bankId)
                                                          .update({
                                                        item['bloodType']:
                                                            FieldValue
                                                                .increment(-1),
                                                      });
                                                      FirebaseFirestore.instance
                                                          .collection(
                                                              'amountLogs')
                                                          .add({
                                                        'bankId': bankId,
                                                        'timestamp': FieldValue
                                                            .serverTimestamp(),
                                                        'userId':
                                                            item['userId'],
                                                        item['bloodType']: -1,
                                                      });
                                                      _verificationCodeController
                                                          .clear();
                                                    }).catchError((error) {
                                                      debugPrint(
                                                          "Error updating request: $error");
                                                    });
                                                  } else {
                                                    debugPrint(
                                                        "Entered code is not a valid number");
                                                  }
                                                }
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    const Color(0xFFAE0E03),
                                                shadowColor: Colors.grey,
                                                elevation: 4,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                ),
                                                minimumSize: const Size(50, 30),
                                              ),
                                              child: const Text(
                                                'توثيق',
                                                style: TextStyle(
                                                  fontFamily: 'BAHIJ',
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 80,
                                              height: 32,
                                              child: TextField(
                                                controller:
                                                    _verificationCodeController,
                                                decoration: InputDecoration(
                                                  hintText: 'أدخل رقم',
                                                  hintStyle: const TextStyle(
                                                    color: Color(0xFFAE0E03),
                                                    fontFamily: 'BAHIJ',
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30.0),
                                                    borderSide:
                                                        const BorderSide(
                                                            color: Colors.grey),
                                                  ),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30.0),
                                                    borderSide:
                                                        const BorderSide(
                                                            color: Colors.grey),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30.0),
                                                    borderSide:
                                                        const BorderSide(
                                                            color: Color(
                                                                0xFFAE0E03),
                                                            width: 2.0),
                                                  ),
                                                ),
                                                textAlign: TextAlign.center,
                                                keyboardType:
                                                    TextInputType.number,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

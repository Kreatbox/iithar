import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BankDonationRequests extends StatefulWidget {
  const BankDonationRequests({super.key});

  @override
  State<BankDonationRequests> createState() => _BankDonationRequestsState();
}

class _BankDonationRequestsState extends State<BankDonationRequests> {
  bool isOldDonations = true;
  bool isNewDonations = false;
  String? bankId; // Make bankId nullable

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
                    label: 'تعيين مركز محدد',
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
                        return data['name'] != null;
                      }).map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return {
                          "id": doc.id,
                          "bloodType": data["bloodType"] ?? "Unknown",
                          "username": data["name"] ?? "No Name",
                          "dateTime":
                              data["dateTime"] ?? DateTime.now().toString(),
                          "medicalCondition":
                              data["medicalCondition"] ?? "No Condition",
                        };
                      }).toList();

                      return ListView.builder(
                        padding: const EdgeInsets.all(15.0),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ListTile(
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(width: 0.5),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'الزمرة: ${items[index]["bloodType"]}',
                                          style: const TextStyle(
                                              fontFamily: 'BAHIJ',
                                              fontSize: 16),
                                        ),
                                        Text(
                                          'الاسم: ${items[index]["username"]}',
                                          style: const TextStyle(
                                              fontFamily: 'BAHIJ',
                                              fontSize: 14),
                                        ),
                                        Text(
                                          'التاريخ: ${(items[index]["dateTime"]).substring(0, 16)}',
                                          style: const TextStyle(
                                              fontFamily: 'BAHIJ',
                                              fontSize: 14),
                                        ),
                                        Text(
                                          'المرض: ${(items[index]["medicalCondition"])}',
                                          style: const TextStyle(
                                              fontFamily: 'BAHIJ',
                                              fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10.0),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      shadowColor: const Color.fromRGBO(
                                          112, 112, 112, 0.4),
                                      elevation: 5,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.pushNamed(
                                        context,
                                        '/myrequest',
                                        arguments: items[index]["id"],
                                      );
                                    },
                                    child: const Text(
                                      'توثيق',
                                      style: TextStyle(
                                        fontFamily: 'BAHIJ',
                                        color: Color(0xFFAE0E03),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
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

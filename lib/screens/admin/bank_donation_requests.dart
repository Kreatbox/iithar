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
  String? bankId;

  final TextEditingController _verificationCodeController = TextEditingController();
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
                        return const Center(child: Text("No donation requests found"));
                      }
                      final items = snapshot.data!.docs.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return data['name'] != null;
                      }).map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return {
                          "id": doc.id,
                          "bloodType": data["bloodType"] ?? "Unknown",
                          "userId": data["userId"] ?? "no username",
                          "username": data["name"] ?? "No Name",
                          "dateTime": data["dateTime"] ?? DateTime.now().toString(),
                          "medicalCondition": data["medicalCondition"] ?? "No Condition",
                        };
                      }).toList();

                      return ListView.builder(
                        padding: const EdgeInsets.all(15.0),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 3,
                                    blurRadius: 5,
                                    offset: Offset(0, 3), // تغير موضع الظل
                                  ),
                                ],
                              ),
                              child: ListTile(
                                shape: RoundedRectangleBorder(
                                  side: const BorderSide(width: 0.5),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${items[index]["bloodType"]}   :الزمرة',
                                      style: const TextStyle(fontFamily: 'BAHIJ', fontSize: 16),
                                    ),
                                    Text(
                                      'اسم المستخدم:    ${items[index]["userId"]}',
                                      style: const TextStyle(fontFamily: 'BAHIJ', fontSize: 14),
                                    ),
                                    Text(
                                      'اسم المريض:    ${items[index]["username"]}',
                                      style: const TextStyle(fontFamily: 'BAHIJ', fontSize: 14),
                                    ),
                                    Text(
                                      'التاريخ:   ${(items[index]["dateTime"]).substring(0, 16)}',
                                      style: const TextStyle(fontFamily: 'BAHIJ', fontSize: 14),
                                    ),
                                    Text(
                                      'المرض:   ${(items[index]["medicalCondition"])}', textAlign: TextAlign.right,
                                      style: const TextStyle(fontFamily: 'BAHIJ', fontSize: 14,),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                            backgroundColor: Color(0xFFAE0E03),
                                            shadowColor: Colors.grey,
                                            elevation: 4,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(15),
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
                                            String code = _verificationCodeController.text;
                                            if (code.isNotEmpty) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'تم التوثيق بنجاح يمكنه نشر العدد المحدد من الطلبات',
                                                    style: TextStyle(fontFamily: 'BAHIJ'),
                                                    textAlign: TextAlign.right,
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Color(0xFFAE0E03),
                                            shadowColor: Colors.grey,
                                            elevation: 4,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(15),
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
                                            controller: _verificationCodeController,
                                            decoration: InputDecoration(
                                              hintText: 'أدخل رقم',
                                              hintStyle: TextStyle(
                                                color: Color(0xFFAE0E03),
                                                fontFamily: 'BAHIJ',
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              filled: true,
                                              fillColor: Colors.white.withOpacity(0.5),
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(30.0),
                                                borderSide: BorderSide(color: Colors.grey),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(30.0),
                                                borderSide: BorderSide(color: Colors.grey),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(30.0),
                                                borderSide: BorderSide(color: Color(0xFFAE0E03), width: 2.0),
                                              ),
                                            ),
                                            textAlign: TextAlign.center,
                                            keyboardType: TextInputType.number,
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
                  ),
          ),
        ],
      ),
    );
  }
}

// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BloodAmount extends StatefulWidget {
  const BloodAmount({super.key});
  @override
  State<BloodAmount> createState() => _BloodAmountState();
}

class _BloodAmountState extends State<BloodAmount> {
  final User? user = FirebaseAuth.instance.currentUser;
  String bloodType = "A+";
  @override
  void initState() {
    super.initState();
    _fetchBloodAmounts();
  }

  final List<String> bloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'O+',
    'O-',
    'AB+',
    'AB-'
  ];

  final Map<String, dynamic> bloodTypeQuantities = {
    'A+': 0,
    'A-': 0,
    'B+': 0,
    'B-': 0,
    'O+': 0,
    'O-': 0,
    'AB+': 0,
    'AB-': 0,
  };
  final Map<String, dynamic> counterQuantities = {
    'A+': 0,
    'A-': 0,
    'B+': 0,
    'B-': 0,
    'O+': 0,
    'O-': 0,
    'AB+': 0,
    'AB-': 0,
  };
  Map<String, bool> requestExists = {};
  Future<void> _addRequest(String bloodType) async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .get();
    final bankId = userDoc.data()!['role'];
    await FirebaseFirestore.instance.collection('requests').add({
      'bankId': bankId,
      'bloodType': bloodType,
    });

    setState(() {
      requestExists[bloodType] = true; // قم بتحديث حالة الطلب
    });
  }

  Future<void> _removeRequest(String bloodType) async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .get();
    final bankId = userDoc.data()!['role'];
    var requestQuery = await FirebaseFirestore.instance
        .collection('requests')
        .where('bankId', isEqualTo: bankId)
        .where('bloodType', isEqualTo: bloodType)
        .get();
    var filteredRequests = requestQuery.docs.where((doc) {
      return !doc.data().containsKey('userId') || doc['userId'] == null;
    }).toList();

    if (filteredRequests.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('requests')
          .doc(filteredRequests.first.id)
          .delete();

      setState(() {
        requestExists[bloodType] = false; // قم بتحديث حالة الطلب
      });
    }
  }

  Future<void> _fetchBloodAmounts() async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .get();
    final bankId = userDoc.data()!['role']; // Assuming role is the bankId

    // Fetch the current blood amounts from Firestore
    final amountDoc = await FirebaseFirestore.instance
        .collection('amounts')
        .doc(bankId)
        .get();

    if (amountDoc.exists) {
      setState(() {
        bloodTypeQuantities['A+'] = amountDoc['A+'] ?? 0;
        bloodTypeQuantities['A-'] = amountDoc['A-'] ?? 0;
        bloodTypeQuantities['B+'] = amountDoc['B+'] ?? 0;
        bloodTypeQuantities['B-'] = amountDoc['B-'] ?? 0;
        bloodTypeQuantities['O+'] = amountDoc['O+'] ?? 0;
        bloodTypeQuantities['O-'] = amountDoc['O-'] ?? 0;
        bloodTypeQuantities['AB+'] = amountDoc['AB+'] ?? 0;
        bloodTypeQuantities['AB-'] = amountDoc['AB-'] ?? 0;
      });
    }
    for (String bloodType in bloodTypes) {
      var requestQuery = await FirebaseFirestore.instance
          .collection('requests')
          .where('bankId', isEqualTo: bankId)
          .where('bloodType', isEqualTo: bloodType)
          .get();
      var filteredRequests = requestQuery.docs.where((doc) {
        return !doc.data().containsKey('userId') || doc['userId'] == null;
      }).toList();
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        setState(() {
          // إذا كان الطلب موجودًا نضع القيمة true، وإلا false
          requestExists[bloodType] = filteredRequests.isNotEmpty;
        });
      }
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
            'فئات الدم في البنك',
            textAlign: TextAlign.right,
            style:
                TextStyle(fontFamily: 'HSI', fontSize: 30, color: Colors.black),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "تعديل",
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontFamily: 'HSI',
                    fontSize: 22,
                    color: Colors.black,
                  ),
                ),
                SizedBox(width: 25),
                Text(
                  "الكمية الحالية",
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontFamily: 'HSI',
                    fontSize: 22,
                    color: Colors.black,
                  ),
                ),
                SizedBox(
                  width: 25,
                ),
                Text(
                  "الزمرة",
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontFamily: 'HSI',
                    fontSize: 22,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const Divider(
              color: Color(0xFFAE0E03),
              thickness: 5,
            ),
            Expanded(
              child: GridView.builder(
                itemCount: bloodTypes.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  childAspectRatio:
                      6.0, // Adjust to fit items properly in a row
                ),
                itemBuilder: (context, index) {
                  String bloodType = bloodTypes[index];
                  int currentQuantity = bloodTypeQuantities[bloodType]! +
                      counterQuantities[bloodType]!;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _customizableCounter(
                          initialCount: counterQuantities[bloodType],
                          currentBloodAmount: bloodTypeQuantities[bloodType],
                          onChanged: (newQuantity) {
                            setState(() {
                              currentQuantity =
                                  bloodTypeQuantities[bloodType]! +
                                      counterQuantities[bloodType]!;
                              counterQuantities[bloodType] = newQuantity;
                            });
                          },
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                        SizedBox(
                          width: 50,
                          child: Text(
                            "$currentQuantity",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'HSI',
                              fontSize: 20,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 45,
                        ),
                        SizedBox(
                          width: 50,
                          child: Text(
                            bloodType,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'HSI',
                              fontSize: 20,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 35,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                fixedSize: const Size(250, 45),
                backgroundColor: const Color(0xFFAE0E03),
                padding: const EdgeInsets.only(
                    right: 25.0, left: 25.0, top: 5.0, bottom: 1.0),
                alignment: Alignment.center,
              ),
              onPressed: () async {
                showBloodDialog();
              },
              child: const Text(
                'إضافة طلب نوع دم',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'HSI',
                  fontSize: 25,
                  color: Colors.white,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size(180, 45),
                    backgroundColor: const Color(0xFFAE0E03),
                    padding: const EdgeInsets.only(
                        right: 25.0, left: 25.0, top: 5.0, bottom: 1.0),
                    alignment: Alignment.center,
                  ),
                  onPressed: () async {
                    final userDoc = await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user?.uid)
                        .get();
                    final bankId =
                        userDoc.data()!['role']; // Assuming role is the bankId

                    final amountDoc = await FirebaseFirestore.instance
                        .collection('amounts')
                        .doc(bankId)
                        .get();

                    Map<String, dynamic> firestoreQuantities =
                        amountDoc.data() as Map<String, dynamic>;

                    // Loop through the bloodTypeQuantities and calculate the differences
                    for (String bloodType in bloodTypeQuantities.keys) {
                      int firestoreQuantity =
                          firestoreQuantities[bloodType] ?? 0;
                      int changeQuantity = counterQuantities[bloodType] ?? 0;

                      // حساب الكمية النهائية
                      int updatedQuantity = firestoreQuantity + changeQuantity;

                      // التحقق من أن الكمية النهائية ليست سالبة
                      if (updatedQuantity >= 0) {
                        // تحديث القيمة فقط إذا تغيرت
                        if (changeQuantity != 0) {
                          await FirebaseFirestore.instance
                              .collection('amounts')
                              .doc(bankId)
                              .update({bloodType: updatedQuantity});
                        }
                      } else {
                        // هنا يمكنك إضافة منطق للتعامل مع حالة القيمة السالبة
                        debugPrint(
                            "Cannot update $bloodType as the resulting quantity is negative.");
                      }
                    }
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text(
      'تم تحديث الكميات بنجاح',
      style: TextStyle(
        fontFamily: 'HSI',
        fontSize: 20,
        color: Colors.white, 
      ),
      textAlign: TextAlign.center,
    ),
       backgroundColor: const Color(0xFFAE0E03),    
    behavior: SnackBarBehavior.floating, 
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10), 
    ),
  ),
);
                  },
                  child: const Text(
                    'إضافة',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'HSI',
                      fontSize: 25,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                IconButton(
                  icon: const Icon(
                    Icons.refresh,
                    color: Color(0xFFAE0E03),
                    size: 30,
                  ),
                  onPressed: () {
                    setState(() {
                      for (String key in counterQuantities.keys) {
                        counterQuantities[key] = 0;
                      }
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void showBloodDialog() {
    // عرض نافذة منبثقة (Popup) لإدارة الطلب
    showDialog(
      context: context,
      builder: (BuildContext context) {
        bool exists = requestExists[bloodType] ?? false;
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'إدارة طلب دم',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontFamily: 'HSI',
              fontSize: 22,
              color: Colors.black,
            ),
          ),
          content: const Text(
            'انشاء أو إزالة طلب لزمرة دم محددة؟',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontFamily: 'HSI',
              fontSize: 22,
              color: Colors.black,
            ),
          ),
          actions: [
            _buildBloodTypeDialog((selectedType) {
              setState(() {
                bloodType = selectedType; // Update blood type here
              });
            }),
            TextButton(
              child: const Text(
                'إلغاء',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontFamily: 'HSI',
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    exists ? const Color(0xFFAE0E03) : Colors.green,
              ),
              child: Text(
                exists ? 'إزالة' : 'إضافة',
                style: const TextStyle(
                  fontFamily: 'HSI',
                  fontSize: 22,
                  color: Colors.white,
                ),
              ),
              onPressed: () async {
                if (exists) {
                  _removeRequest(bloodType);
                } else {
                  _addRequest(bloodType);
                }
                // إغلاق النافذة المنبثقة بعد الإجراء
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildBloodTypeDialog(Function(String) onBloodTypeSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: () {
          _showBloodTypeDialog(onBloodTypeSelected); // Pass the callback
        },
        child: AbsorbPointer(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: TextField(
              decoration: InputDecoration(
                prefixIcon:
                    const Icon(Icons.bloodtype, color: Color(0xFFAE0E03)),
                labelText: bloodType,
                labelStyle: const TextStyle(
                  fontFamily: 'HSI',
                  fontSize: 18,
                  color: Colors.grey,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ),
      ),
    );
  }

  void _showBloodTypeDialog(Function(String) onBloodTypeSelected) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'اختر زمرة الدم',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'HSI',
                    fontSize: 25,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                const Divider(color: Colors.grey),
                ...bloodTypes.map((type) => ListTile(
                      title: Text(
                        type,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontFamily: 'HSI',
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                      onTap: () {
                        onBloodTypeSelected(type); // Call the callback here
                        Navigator.pop(context);
                        Navigator.pop(context);
                        showBloodDialog();
                      },
                      leading: const Icon(Icons.water_drop,
                          color: Color(0xFFAE0E03)),
                    )),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _customizableCounter({
    required int initialCount,
    required int currentBloodAmount,
    required Function(int) onChanged,
  }) {
    TextEditingController controller =
        TextEditingController(text: initialCount.toString());

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFAE0E03),
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.remove, color: Colors.white),
            onPressed: () {
              int currentCount = int.tryParse(controller.text) ?? initialCount;
              if (currentCount > -currentBloodAmount) {
                setState(() {
                  currentCount--;
                  controller.text = currentCount.toString();
                  onChanged(currentCount);
                });
              }
            },
          ),
          SizedBox(
            width: 30,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'HSI',
                fontSize: 20,
                color: Colors.white,
              ),
              onSubmitted: (value) {
                int newValue = int.tryParse(value) ?? initialCount;
                setState(() {
                  controller.text = newValue.toString();
                  onChanged(newValue);
                });
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              int currentCount = int.tryParse(controller.text) ?? initialCount;
              setState(() {
                if (currentCount < -currentBloodAmount) {
                  currentCount = -currentBloodAmount;
                  controller.text = currentCount.toString();
                  onChanged(currentCount);
                } else {
                  currentCount++;
                  controller.text = currentCount.toString();
                  onChanged(currentCount);
                }
              });
            },
          ),
        ],
      ),
    );
  }
}

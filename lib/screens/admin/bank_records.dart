import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BankRecords extends StatefulWidget {
  const BankRecords({super.key});

  @override
  State<BankRecords> createState() => _BankRecordsState();
}

class _BankRecordsState extends State<BankRecords> {
  List<Map<String, dynamic>> amountLogs = [];

  @override
  void initState() {
    super.initState();
    fetchAmountLogs();
  }

  Future<void> fetchAmountLogs() async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('amountLogs')
        .orderBy('timestamp', descending: true) // Newest to oldest
        .get();

    for (var doc in snapshot.docs) {
      Map<String, dynamic> log = doc.data() as Map<String, dynamic>;
      String userId = log['userId'];

      // Fetch user details
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      String firstName = userDoc['firstName'];
      String lastName = userDoc['lastName'];

      log['userName'] = '$firstName $lastName';
      amountLogs.add(log);
    }

    setState(() {});
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
            'سجلات البنك',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontFamily: 'HSI',
              fontSize: 30,
              color: Colors.black,
            ),
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: amountLogs.length,
        itemBuilder: (context, index) {
          final log = amountLogs[index];
          final timestamp = (log['timestamp'] as Timestamp).toDate();
          final formattedTime =
              "${timestamp.year}-${timestamp.month}-${timestamp.day} "
              "${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}";

          return Padding(
            padding: const EdgeInsets.all(15.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.grey,
                    blurRadius: 10.0,
                    spreadRadius: 1.0,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  side: const BorderSide(width: 1),
                  borderRadius: BorderRadius.circular(20),
                ),
                title: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(formattedTime),
                        const SizedBox(width: 10),
                        const Text(
                          ":التاريخ",
                          style: TextStyle(
                              fontFamily: 'BAHIJ',
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          log['userName'],
                          style: const TextStyle(
                              fontFamily: 'BAHIJ', fontSize: 14),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          ":اسم المعدل",
                          style: TextStyle(
                              fontFamily: 'BAHIJ',
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          ":التعديلات",
                          style: TextStyle(
                              fontFamily: 'BAHIJ',
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: GridView.count(
                        shrinkWrap: true,
                        crossAxisCount: 3,
                        crossAxisSpacing: 5.0,
                        mainAxisSpacing: 5.0,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: 3,
                        children: [
                          for (String bloodType in log.keys)
                            if (bloodType != 'userId' &&
                                bloodType != 'userName' &&
                                bloodType != 'timestamp' &&
                                bloodType != 'bankId')
                              Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.grey,
                                      blurRadius: 5.0,
                                      spreadRadius: 0.0,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text(
                                      '${log[bloodType]}',
                                      style: const TextStyle(
                                          fontFamily: 'BAHIJ', fontSize: 14),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      ':$bloodType',
                                      style: const TextStyle(
                                          fontFamily: 'BAHIJ',
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const Icon(
                                      Icons.bloodtype_outlined,
                                      color: Color(0xFFAE0E03),
                                      size: 18,
                                    ),
                                  ],
                                ),
                              ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

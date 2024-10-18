import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class MyRequests extends StatefulWidget {
  const MyRequests({super.key});

  @override
  State<MyRequests> createState() => _MyRequestsState();
}

class _MyRequestsState extends State<MyRequests> {
  late List<Map<String, dynamic>> items = [];
  bool isLoaded = false;

  Future<void> fetchLastRequest() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }
    final userId = user.uid;
    final querySnapshot = await FirebaseFirestore.instance
        .collection('requests')
        .where('userId', isEqualTo: userId)
        .orderBy('dateTime', descending: true)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      List<Map<String, dynamic>> tempList = [];
      querySnapshot.docs.forEach((element) {
        tempList.add(element.data());
      });
      setState(() {
        items = tempList;
        isLoaded = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchLastRequest();
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
          ? ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
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
                              items[index]["dateTime"] ?? "not given" , // يمكنك إضافة قيمة هنا
                              style: const TextStyle(
                                  fontFamily: 'BAHIJ', fontSize: 14),
                            ),
                            Text(
                              items[index]["medicalCondition"]?? "not given", // يجب إضافة قيمة هنا
                              style: const TextStyle(
                                  fontFamily: 'BAHIJ', fontSize: 14),
                            )
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
          : const Center(child: CircularProgressIndicator()), // عرض مؤشر التحميل إذا لم يتم تحميل البيانات بعد
    );
  }
}

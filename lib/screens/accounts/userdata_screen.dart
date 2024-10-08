// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserDataScreen extends StatelessWidget {
  final User user;

  const UserDataScreen({super.key, required this.user});

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
                ' الحساب ',
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontFamily: 'HSI', fontSize: 30, color: Colors.black),
              ),
            ),
          ),
        ),
        body: Stack(children: [
          Image.asset(
            'assets/Images/Ve.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('حدث خطأ: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SingleChildScrollView(
                            padding: EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text('لا توجد بيانات'),
                                SizedBox(height: 20),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      fixedSize: Size(175, 45),
                                      backgroundColor: Color(0xFFAE0E03),
                                      padding: EdgeInsets.only(
                                          right: 25.0,
                                          left: 25.0,
                                          top: 5.0,
                                          bottom: 1.0),
                                      alignment: Alignment.center),
                                  onPressed: () async {
                                    await FirebaseAuth.instance.signOut();
                                    Navigator.pushReplacementNamed(
                                        context, '/register');
                                  },
                                  child: Text(
                                    'تسجيل الخروج',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontFamily: 'HSI',
                                        fontSize: 25,
                                        color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ]);
                  }
                  return Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          const SizedBox(height: 20),
                          _buildInfoSection('إعدادات', [
                            Row(
                              children: [
                                TextButton.icon(
                                    label: Text(
                                      'معلوماتي الشخصية',
                                      style: const TextStyle(
                                          fontSize: 20,
                                          fontFamily: 'HSI',
                                          color: Colors.black),
                                      textAlign: TextAlign.right,
                                    ),
                                    icon: Icon(
                                      Icons.person,
                                      color: Color(0xFFAE0E03),
                                      size: 30,
                                    ),
                                    onPressed: () {
                                      Navigator.pushNamed(
                                          context, '/personalinfo');
                                    }),
                                const Spacer(),
                              ],
                            ),
                            Row(
                              children: [
                                TextButton.icon(
                                    label: Text(
                                      'مواعيدي',
                                      style: const TextStyle(
                                          fontSize: 20,
                                          fontFamily: 'HSI',
                                          color: Colors.black),
                                      textAlign: TextAlign.right,
                                    ),
                                    icon: Icon(
                                      Icons.list,
                                      color: Color(0xFFAE0E03),
                                      size: 30,
                                    ),
                                    onPressed: () {
                                      Navigator.pushNamed(
                                          context, '/myappointment');
                                    }),
                                const Spacer(),
                              ],
                            ),
                            Row(
                              children: [
                                TextButton.icon(
                                    label: Text(
                                      'طلباتي',
                                      style: const TextStyle(
                                          fontSize: 20,
                                          fontFamily: 'HSI',
                                          color: Colors.black),
                                      textAlign: TextAlign.right,
                                    ),
                                    icon: Icon(
                                      Icons.list,
                                      color: Color(0xFFAE0E03),
                                      size: 30,
                                    ),
                                    onPressed: () {
                                      Navigator.pushNamed(
                                          context, '/myrequest');
                                    }),
                                const Spacer(),
                              ],
                            ),
                            Row(
                              children: [
                                TextButton.icon(
                                    label: Text(
                                      'تبرعاتي',
                                      style: const TextStyle(
                                          fontSize: 20,
                                          fontFamily: 'HSI',
                                          color: Colors.black),
                                      textAlign: TextAlign.right,
                                    ),
                                    icon: Icon(
                                      Icons.list,
                                      color: Color(0xFFAE0E03),
                                      size: 30,
                                    ),
                                    onPressed: () {
                                      Navigator.pushNamed(
                                          context, '/mydonations');
                                    }),
                                const Spacer(),
                              ],
                            )
                          ]),
                          const SizedBox(
                            height: 40,
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                fixedSize: const Size(175, 45),
                                backgroundColor: const Color(0xFFAE0E03),
                                padding: const EdgeInsets.only(
                                    right: 25.0,
                                    left: 25.0,
                                    top: 5.0,
                                    bottom: 1.0),
                                alignment: Alignment.center),
                            onPressed: () async {
                              await FirebaseAuth.instance.signOut();
                              Navigator.pushReplacementNamed(
                                  context, '/register');
                            },
                            child: const Text(
                              'تسجيل الخروج',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontFamily: 'HSI',
                                  fontSize: 25,
                                  color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ]),
          )
        ]));
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(112, 112, 112, 100),
                blurRadius: 5,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'HSI',
                  fontSize: 25,
                ),
              ),
              const Divider(
                thickness: 1.5,
              ),
              ...children,
            ],
          ),
        ));
  }
}

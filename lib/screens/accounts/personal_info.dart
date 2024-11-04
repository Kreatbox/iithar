import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserinfoDataScreen extends StatelessWidget {
  final User userinfo;
  const UserinfoDataScreen({super.key, required this.userinfo});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Align(
          alignment: Alignment.centerRight,
          child: Text(
            'معلومات الحساب ',
            textAlign: TextAlign.right,
            style:
                TextStyle(fontFamily: 'HSI', fontSize: 30, color: Colors.black),
          ),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(userinfo.uid)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('حدث خطأ: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('لا توجد بيانات'),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            );
          }
          var userData = snapshot.data!.data() as Map<String, dynamic>;
          bool hasFormAnswer = userData.containsKey('formAnswer');
          String formAnswer = hasFormAnswer ? userData['formAnswer'] : '';
          bool isEligibleForDonation = formAnswer == '000000000';
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 20),
                  _buildInfoSection('المعلومات الشخصية', [
                    _buildInfoRow('الاسم', userData['firstName']),
                    const Divider(),
                    _buildInfoRow('اسم العائلة', userData['lastName']),
                    const Divider(),
                    _buildInfoRow('تاريخ الميلاد', userData['birthDate']),
                    const Divider(),
                    _buildInfoRow('فصيلة الدم', userData['bloodType']),
                    const Divider(),
                    _buildInfoRow('الجنس', userData['genderType']),
                    const Divider(),
                    _buildInfoRow('رقم الجوال', '${userData['phoneNumber']}'),
                    const Divider(),
                    _buildInfoRow('الرقم الوطني', userData['ssid']),
                    const Divider(),
                    _buildInfoRow(
                        'قابل للتبرع', isEligibleForDonation ? 'نعم' : 'لا'),
                  ]),
                  const SizedBox(height: 20),
                  if (!hasFormAnswer)
                    const Text(
                      'لم تقم بملء استبيان التبرع بعد. يرجى ملء الاستبيان لإكمال بياناتك.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'HSI', fontSize: 18, color: Colors.red),
                    ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFAE0E03),
                        padding: const EdgeInsets.only(
                            right: 25.0, left: 25.0, top: 5.0, bottom: 1.0),
                        alignment: Alignment.center),
                    onPressed: () {
                      Navigator.pushNamed(context, '/form');
                    },
                    child: const Text(
                      'ملء استبيان التبرع',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'HSI', fontSize: 25, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 18, fontFamily: 'HSI'),
            textAlign: TextAlign.right,
          ),
          const Spacer(),
          Text(value),
        ],
      ),
    );
  }
}

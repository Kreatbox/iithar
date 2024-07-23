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
        title:  Text('المعلومات الشخصية ',textAlign: TextAlign.right,
                style: TextStyle(
                    fontFamily: 'HSI', fontSize: 30, color: Colors.black),),),
      body: 
      FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('حدث خطأ: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('لا توجد بيانات'));
          }

          // Access user data from Firestore
          var userData = snapshot.data!.data() as Map<String, dynamic>;
          
          bool hasFormAnswer = userData.containsKey('formAnswer');
          String formAnswer = hasFormAnswer ? userData['formAnswer'] : '';
          bool isEligibleForDonation = formAnswer == '000000000';

          return Center(
            child: SingleChildScrollView(
              
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _buildProfilePictureSection(),
                  const SizedBox(height: 20),
                  _buildInfoSection('المعلومات الشخصية', [
                    _buildInfoRow('الاسم', userData['firstName']),
                    _buildInfoRow('اسم العائلة', userData['lastName']),
                    _buildInfoRow('تاريخ الميلاد', userData['birthDate']),
                    _buildInfoRow('فصيلة الدم', userData['bloodType']),
                    _buildInfoRow('رقم الجوال', '${userData['phoneNumber']}'),
                    _buildInfoRow(' الرقم الوطني', userData['ssid']),

                  ]),
                   const SizedBox(height: 20),
                       if (!hasFormAnswer) ...[
                    const Text(
                      'لم تقم بملء استبيان التبرع بعد. يرجى ملء الاستبيان لإكمال بياناتك.',
                      style: TextStyle(color: Colors.red, fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/form');
                      },
                      child: const Text('ملء استبيان التبرع'),
                    ),
                  ],
                  _buildInfoSection('مواعيدي ', [
                  ]),
                  const SizedBox(height: 20),
                  
                  ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      fixedSize: const Size(175, 45),
                      backgroundColor: const Color(0xFFAE0E03),
                      padding: const EdgeInsets.only(
                          right: 25.0, left: 25.0, top: 5.0, bottom: 1.0),
                      alignment: Alignment.center),
               
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.pushReplacementNamed(context, '/register');
                    },
                    child: const Text('تسجيل الخروج',textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'HSI', fontSize: 25, color: Colors.white),),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  Widget _buildProfilePictureSection() {
    
    return Center(
      child: Column(
        children: [     
          const CircleAvatar(
            radius: 50,
backgroundColor:     Color(0xFFAE0E03),
         ),
          TextButton(
            onPressed: () {
            },
            child:  Text('تغيير الصورة الشخصية '   ,  style:   TextStyle(fontSize: 22, fontFamily: 'HSI'
 , color: Colors.black),
),
          ),
        ],
      ),
    );
  }
  Widget _buildInfoSection(String title, List<Widget> children) {
    return Container(
      
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
              color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
            BoxShadow( color:Color.fromRGBO(112, 112,112, 100),
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
              fontSize: 18,
            ),
          ),
          const Divider(),
          ...children,
        ],
      ),
    );
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


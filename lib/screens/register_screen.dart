import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class  registerscreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
          children: [
            Image.asset('assets/Images/intro.png',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(height: 100,),
                Text('تبرع', textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'HSI',
                        fontSize: 60,
                        color: Color(0xFFAE0E03)
                    )),
                Text('بالدم', textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'HSI',
                      fontSize: 90,
                      color: Color(0xFFAE0E03)
                  ),
                ), Text('و أنقذ حياة', textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'HSI',
                      fontSize: 60,
                      color: Color(0xFFAE0E03)
                  ),
                ),
                SizedBox(height: 30),
                ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    child: Text('تسجيل الدخول', style: TextStyle(
                        fontFamily: 'HSI',
                        fontSize: 25,
                        color: Colors.white
                    ),),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFAE0E03),
                        padding: EdgeInsets.only(
                            right: 25.0, left: 25.0, top: 5.0, bottom: 1.0),
                        alignment: Alignment.center
                    )
                ),

                SizedBox(height: 20),
                ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/signup');
                    },
                    child: Text('إنشاء حساب', style: TextStyle(
                        fontFamily: 'HSI',
                        fontSize: 25,
                        color: Colors.white
                    ),),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFAE0E03),
                        padding: EdgeInsets.only(
                            right: 25.0, left: 25.0, top: 5.0, bottom: 1.0),
                        fixedSize: Size(170, 25)
                    )
                ),
                SizedBox(height: 20),
                FirebaseAuth.instance.currentUser != null
                    ? ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/userdata');
                  },
                  child: Text('عرض بياناتي'),
                )
                    : Container(), // Display button only if user is logged in

              ],
            ),
          ]),
    );
  }
}
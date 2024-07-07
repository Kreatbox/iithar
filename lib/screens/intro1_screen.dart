import 'package:flutter/material.dart';

class Intro1Screen extends StatelessWidget {
  const Intro1Screen({super.key});

  @override
  Widget build(BuildContext) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            height: 150,
          ),
          Image.asset(
            'assets/Images/girl.png',
            alignment: Alignment.center,
            width: 320,
            height: 350,
          ),
          const Text(
            'تبرعك يمكن أن ينقذ حياة',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: 'HSI', fontSize: 40, color: Color(0xFFAE0E03)),
          ),
        ],
      ),
    );
  }
}

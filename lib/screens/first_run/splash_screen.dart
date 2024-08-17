import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'intro1_screen.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatelessWidget{
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context){
    return AnimatedSplashScreen(
      splash: Column(
        children: [
          Center(
            child: Lottie.asset('assets/Animation/icon99.json'),
          )
        ],
      ) ,nextScreen: Onboarding(),
      duration: 3500,
      backgroundColor: Colors.white,
    );
  }
}
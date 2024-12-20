import 'package:flutter/material.dart';
import 'package:iithar/screens/first_run/intro1_screen.dart';
import 'package:iithar/screens/first_run/intro2_screen.dart';
import 'package:iithar/screens/accounts/register_screen.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _Onboardingscreenstate();
}

class _Onboardingscreenstate extends State<Onboarding> {
  final PageController _controller = PageController();
  bool onlastpage = false;
  bool onpreviouspage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                onlastpage = (index == 1);
                onpreviouspage = (index == 0);
              });
            },
            children: const [Intro1Screen(), Intro2Screen()],
          ),
          Container(
            alignment: const Alignment(0, 0.93),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                onpreviouspage
                    ? GestureDetector(
                        onTap: () {
                          _controller.nextPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeIn,
                          );
                        },
                        child: const Text(
                          '           ',
                          style: TextStyle(
                              fontFamily: 'HSI',
                              fontSize: 30,
                              color: Color(0xFFAE0E03)),
                        ),
                      )
                    : GestureDetector(
                        onTap: () {
                          _controller.previousPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeIn,
                          );
                        },
                        child: const Text(
                          'السابق',
                          style: TextStyle(
                              fontFamily: 'HSI',
                              fontSize: 30,
                              color: Color(0xFFAE0E03)),
                        ),
                      ),
                SmoothPageIndicator(
                  controller: _controller,
                  count: 2,
                  effect: const WormEffect(
                      dotColor: Color(0xFFE0E0E0),
                      activeDotColor: Color(0xFFAE0E03)),
                ),
                onlastpage
                    ? GestureDetector(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return const RegisterScreen();
                          }));
                          _controller.nextPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeIn,
                          );
                        },
                        child: const Text(
                          '   تم  ',
                          style: TextStyle(
                              fontFamily: 'HSI',
                              fontSize: 30,
                              color: Color(0xFFAE0E03)),
                        ),
                      )
                    : GestureDetector(
                        onTap: () {
                          _controller.nextPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeIn,
                          );
                        },
                        child: const Text(
                          'التالي',
                          style: TextStyle(
                              fontFamily: 'HSI',
                              fontSize: 30,
                              color: Color(0xFFAE0E03)),
                        ),
                      )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

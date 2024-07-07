import 'package:flutter/material.dart';
import 'package:iithar/screens/intro1_screen.dart';
import 'package:iithar/screens/intro2_screen.dart';
import 'package:iithar/screens/register_screen.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';



class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _Onboardingscreenstate();
}

class _Onboardingscreenstate extends State<Onboarding>{

  // controller to keep track of which page we are on
  PageController _controller = PageController();

  //track of it is the last page or not
  bool onlastpage= false;
  bool onpreviouspage= false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (index ){
              setState(() {
                onlastpage = (index == 1);
                onpreviouspage = (index == 0);
              });
            },
            children: [
              Intro1Screen(),
              Intro2Screen()
            ],
          ),
          Container(
            alignment: Alignment(0,0.93) ,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                //previous
                onpreviouspage
                    ? GestureDetector(
                  onTap:(){
                    _controller.nextPage(
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeIn,);
                  },
                  child: Text('           ',
                    style: TextStyle(
                        fontFamily: 'HSI',
                        fontSize: 30,
                        color: Color(0xFFAE0E03)
                    ),
                  ),

                )
                    :GestureDetector(
                  onTap:(){
                    _controller.previousPage(
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeIn,);
                  },
                  child: Text('السابق',
                    style: TextStyle(
                        fontFamily: 'HSI',
                        fontSize: 30,
                        color: Color(0xFFAE0E03)
                    ),
                  ),
                ),

                SmoothPageIndicator(controller: _controller,
                  count: 2,
                  effect:
                  WormEffect(dotColor: Color(0xFFE0E0E0) ,
                      activeDotColor: Color(0xFFAE0E03)
                  ),
                ),
                //next or done
                onlastpage
                    ? GestureDetector(
                  onTap: (){
                    Navigator.push(context,MaterialPageRoute(builder: (context){
                      return registerscreen();
                    }));
                    _controller.nextPage(
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeIn,);
                  },
                  child: Text('   تم  ',
                    style: TextStyle(
                        fontFamily: 'HSI',
                        fontSize: 30,
                        color: Color(0xFFAE0E03)
                    ),
                  ),
                )
                    :GestureDetector(
                  onTap: (){
                    _controller.nextPage(
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeIn,);
                  },
                  child: Text('التالي',
                    style: TextStyle(
                        fontFamily: 'HSI',
                        fontSize: 30,
                        color: Color(0xFFAE0E03)
                    ),
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
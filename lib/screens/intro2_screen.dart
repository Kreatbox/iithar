import 'package:flutter/material.dart';




class Intro2Screen extends StatelessWidget{
  @override
  Widget build(BuildContext){
    return Container(
      child:   Column(mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(height: 150,),
          Image.asset('assets/Images/search.png',
            alignment: Alignment.center,
            width:350,
            height:350,
          ),Text('العثور على متبرع بسهولة',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: 'HSI',
                fontSize: 40,
                color: Color(0xFFAE0E03)
            ),
          ),
        ],
      ),
    );
  }
}

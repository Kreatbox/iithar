import 'package:flutter/material.dart';

import '../components/donation_request_listview.dart';

class DonationRequestScreen extends StatelessWidget {
  const DonationRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
        appBar:AppBar(
          backgroundColor: Colors.white,
          title: const Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                'طلبات التبرع',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontFamily: 'HSI',
                  fontSize: 30,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
       body: ListView(
    padding: const EdgeInsets.all(15.0),
    children: [
      DonationRequestsListView(),

    ]),

      );
  }
} 


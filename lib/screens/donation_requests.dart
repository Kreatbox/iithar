import 'package:flutter/material.dart';

class DonationRequestScreen extends StatelessWidget {
  const DonationRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
      title: const Text('طلبات التبرع',style: TextStyle(
              fontFamily: 'HSI',
              fontSize: 30,
              color: Colors.black,
            ),),
        ),
      );
  }
} 


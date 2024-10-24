import 'package:flutter/material.dart';
import 'package:iithar/screens/admin/donation_request_listview1.dart';

class BankDonationRequests extends StatefulWidget {
  const BankDonationRequests({super.key});

  @override
  State<BankDonationRequests> createState() => _BankDonationRequestsState();
}

class _BankDonationRequestsState extends State<BankDonationRequests> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Align(
          alignment: Alignment.centerRight,
          child: Text(
            'طلبات الطوارئ',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontFamily: 'HSI', 
              fontSize: 30, 
              color: Colors.black,
            ),
          ),
        ),
      ),
     
     body: ListView(padding: const EdgeInsets.all(15.0), children: const [
        DonationRequestsListView1(),
      ]),
      
    );
  }
}

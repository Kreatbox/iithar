import 'package:flutter/material.dart';
import 'package:iithar/models/donation_request.dart';


class DonateNowScreen extends StatelessWidget {
  final DonationRequest donationRequest;
   DonateNowScreen({super.key, required this.donationRequest});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("تبرع الآن"),
        ),
        body: Center(
          child: Column(
            children: [
              Text(donationRequest.name),
              Text(donationRequest.bloodType),
              Text(donationRequest.location),
            ],
          ),
        ));
  }
}

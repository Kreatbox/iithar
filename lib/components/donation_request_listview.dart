import 'package:flutter/material.dart';
import 'package:iithar/firebase/get_data.dart';
import 'package:iithar/screens/donate_now_screen.dart';

class DonationRequestsListView extends StatefulWidget {
   const DonationRequestsListView({super.key});

  @override
  State<DonationRequestsListView> createState() =>
      _DonationRequestsListViewState();
}

class _DonationRequestsListViewState extends State<DonationRequestsListView> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getDonationRequests(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else {
          final donationRequests = snapshot.data;
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: donationRequests!.length,
            itemBuilder: (context, index) {
              final donationRequest = donationRequests[index];
              return Card(
                child: ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return DonateNowScreen(
                              donationRequest: donationRequest,
                            );
                          }));
                        },
                        child: const Text(
                          'تبرع الآن',
                          style: TextStyle(
                            color: Color(0xFFAE0E03),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(donationRequest.name),
                              Text('الزمرة: ${donationRequest.bloodType}'),
                              Text('الموقع: ${donationRequest.location}'),
                            ],
                          ),
                          const SizedBox(
                              width:
                                  8.0), // Add some spacing between the text and the icon
                          const Icon(
                            Icons.bloodtype,
                            color: Color(0xFFAE0E03),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }
}

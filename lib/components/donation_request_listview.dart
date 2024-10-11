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
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white,
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(112, 112, 112, 1),
                      blurRadius: 5,
                    ),
                  ],
                ),
                margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                child: ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shadowColor: const Color.fromRGBO(112, 112, 112, 0.4),
                          elevation: 5,
                          // Text color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
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
                            fontFamily: 'BAHIJ',
                            color: Color(0xFFAE0E03),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                donationRequest.name,
                                style: const TextStyle(fontFamily: 'BAHIJ'),
                              ),
                              Text(
                                'الزمرة: ${donationRequest.bloodType}',
                                style: const TextStyle(fontFamily: 'BAHIJ'),
                              ),
                              Text(
                                'الموقع: ${donationRequest.location}',
                                style: const TextStyle(fontFamily: 'BAHIJ'),
                              ),
                            ],
                          ),
                          const SizedBox(
                              width:
                                  10.0), // Add some spacing between the text and the icon
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

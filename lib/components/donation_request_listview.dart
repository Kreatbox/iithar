import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iithar/screens/appointment_booking.dart';
import '../models/blood_bank.dart';
import '../models/donation_request.dart';
import '../screens/donate_now_screen.dart';
import '../services/data_service.dart';

class DonationRequestsListView extends StatefulWidget {
  const DonationRequestsListView({super.key});

  @override
  State<DonationRequestsListView> createState() =>
      _DonationRequestsListViewState();
}

class _DonationRequestsListViewState extends State<DonationRequestsListView> {
  final DataService dataService = DataService();
  late Future<List<BloodBank>> _banksFuture;
  late List<Map<String?, dynamic>> bankRequest;
  int counter = 0;

  @override
  void initState() {
    super.initState();
    _banksFuture = dataService.loadBankData();
    loadBloodBankRequests();
  }

  Future<void> loadBloodBankRequests() async {
    final User? user = FirebaseAuth.instance.currentUser;
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .get();
    final bloodType = userDoc.data()!['bloodType'];
    final favourite = userDoc.data()!['favouriteBank'];
    var requestQuery = await FirebaseFirestore.instance
        .collection('requests')
        .where('userId', isEqualTo: null)
        .where('bankId', isEqualTo: favourite)
        .where('bloodType', isEqualTo: bloodType)
        .get();
    var filteredRequests = requestQuery.docs.where((doc) {
      return !doc.data().containsKey('userId') || doc['userId'] == null;
    }).toList();
    bankRequest = filteredRequests.map((doc) => doc.data()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<BloodBank>>(
      future: _banksFuture,
      builder: (context, bankSnapshot) {
        if (bankSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (bankSnapshot.hasError) {
          return const Center(
            child: Text('حدث خطأ أثناء تحميل بيانات البنوك'),
          );
        } else if (!bankSnapshot.hasData || bankSnapshot.data!.isEmpty) {
          return const Center(
            child: Text('لا توجد بنوك دم متاحة حالياً'),
          );
        } else {
          // Banks data loaded successfully
          final List<BloodBank> banks = bankSnapshot.data!;
          return FutureBuilder<List<DonationRequest?>>(
            future:
                getDonationRequests(), // Fetch donation requests from Firestore
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return const Center(
                  child: Text('حدث خطأ أثناء تحميل البيانات'),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text('لا توجد طلبات تبرع متاحة حالياً'),
                );
              } else {
                final donationRequests = snapshot.data!;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: donationRequests.length + bankRequest.length,
                  itemBuilder: (context, index) {
                    if (index <= bankRequest.length) {
                      counter = 0;
                    } else {
                      counter += 1;
                    }
                    final donationRequest = donationRequests[counter];

                    // Check if donationRequest is null
                    if (donationRequest == null) {
                      return const SizedBox(); // Skip rendering if null
                    }

                    // Map the bankId to the bank name (with null safety)
                    final BloodBank bloodBank = banks.firstWhere(
                      (bank) => bank.bankId == donationRequest.bankId,
                    );
                    final String bankName =
                        bloodBank.name; // Fallback for safety

                    if (bankRequest.isNotEmpty && index < bankRequest.length) {
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
                        margin: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        child: ListTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  shadowColor:
                                      const Color.fromRGBO(112, 112, 112, 0.4),
                                  elevation: 5,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                    return const AppointmentBookingScreen();
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
                                        bankName, // Display the blood bank name instead of location
                                        style: const TextStyle(
                                            fontFamily: 'BAHIJ', fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 10.0),
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
                    } else {
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
                        margin: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        child: ListTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  shadowColor:
                                      const Color.fromRGBO(112, 112, 112, 0.4),
                                  elevation: 5,
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
                                        'الزمرة: ${donationRequest.bloodType}',
                                        style: const TextStyle(
                                            fontFamily: 'BAHIJ', fontSize: 14),
                                      ),
                                      Text(
                                        bankName, // Display the blood bank name instead of location
                                        style: const TextStyle(
                                            fontFamily: 'BAHIJ', fontSize: 12),
                                      ),
                                      Text(
                                        'الهاتف: ${donationRequest.phone}',
                                        style: const TextStyle(
                                            fontFamily: 'BAHIJ', fontSize: 14),
                                      ),
                                      Text(
                                        'التاريخ: ${(donationRequest.dateTime).substring(0, 16)}', // Display remaining time
                                        style: const TextStyle(
                                            fontFamily: 'BAHIJ', fontSize: 14),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 10.0),
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
                    }
                  },
                );
              }
            },
          );
        }
      },
    );
  }
}

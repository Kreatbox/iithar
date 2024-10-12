import 'package:iithar/models/donation_request.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<DonationRequest>> getDonationRequests() async {
  // Fetch data from Firestore
  QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection('requests').get();

  // Map Firestore documents to DonationRequest model
  List<DonationRequest> requests = snapshot.docs.map((doc) {
    return DonationRequest(
      name: doc['name'] as String, // From Firestore field
      bloodType: doc['bloodType'] as String, // From Firestore field
      location: doc['bloodBank'] as String, // Display bloodBank as location
      phone: doc['phone'] as String, // Display phone as well
    );
  }).toList();

  return requests;
}

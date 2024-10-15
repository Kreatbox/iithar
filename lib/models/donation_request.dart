import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // To access the current user

class DonationRequest {
  final String id; // Add this field
  final String name;
  final String bloodType;
  final String bankId;
  final String phone;
  final String dateTime;
  final String medicalCondition;
  final String note;
  final String otherCondition;
  final String state;
  final String userId;
  final String?
      acceptedUserId; // Optional because it will only exist if accepted

  DonationRequest({
    required this.id, // Include id in constructor
    required this.name,
    required this.bloodType,
    required this.bankId,
    required this.phone,
    required this.dateTime,
    required this.medicalCondition,
    required this.note,
    required this.otherCondition,
    required this.state,
    required this.userId,
    this.acceptedUserId,
  });
}

Future<List<DonationRequest?>> getDonationRequests() async {
  final User? user = FirebaseAuth.instance.currentUser; // Get the current user
  if (user == null) {
    return []; // If no user is logged in, return an empty list
  }

  String currentUserId = user.uid;

  // Retrieve the user's blood type from Firestore (assuming it's stored in a collection)
  DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(currentUserId)
      .get();

  if (!userSnapshot.exists) {
    return []; // If user data doesn't exist, return an empty list
  }

  Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
  String userBloodType = userData['bloodType']; // Get the user's blood type

  QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection('requests').get();

  DateTime now = DateTime.now(); // Get the current time

  List<DonationRequest?> requests = snapshot.docs
      .map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        DateTime requestDateTime = DateTime.parse(data['dateTime']);
        if (requestDateTime.isAfter(now)) {
          if (data['userId'] != currentUserId &&
              _isCompatibleBloodType(userBloodType, data['bloodType']) &&
              data['state'] != 1) {
            return DonationRequest(
              id: doc.id,
              name: data['name'] as String,
              bloodType: data['bloodType'] as String,
              bankId: data['bankId'] as String,
              phone: data['phone'] as String,
              dateTime: data['dateTime'] as String,
              medicalCondition: data['medicalCondition'] as String,
              note: data['note'] as String,
              otherCondition: data['otherCondition'] as String,
              state: data['state'] as String,
              userId: data['userId'] as String,
              acceptedUserId: data.containsKey('acceptedUserId')
                  ? data['acceptedUserId'] as String?
                  : null,
            );
          }
        }
        return null;
      })
      .where((request) => request != null)
      .toList()
      .cast<DonationRequest>();

  return requests;
}

bool _isCompatibleBloodType(String userBloodType, String requestBloodType) {
  switch (userBloodType) {
    case 'O-':
      return requestBloodType == 'O-';
    case 'O+':
      return requestBloodType == 'O+' || requestBloodType == 'O-';
    case 'A-':
      return requestBloodType == 'A-' || requestBloodType == 'O-';
    case 'A+':
      return requestBloodType == 'A+' ||
          requestBloodType == 'A-' ||
          requestBloodType == 'O+' ||
          requestBloodType == 'O-';
    case 'B-':
      return requestBloodType == 'B-' || requestBloodType == 'O-';
    case 'B+':
      return requestBloodType == 'B+' ||
          requestBloodType == 'B-' ||
          requestBloodType == 'O+' ||
          requestBloodType == 'O-';
    case 'AB-':
      return requestBloodType == 'AB-' ||
          requestBloodType == 'A-' ||
          requestBloodType == 'B-' ||
          requestBloodType == 'O-';
    case 'AB+':
      return true; // AB+ can receive from all blood types
    default:
      return false;
  }
}

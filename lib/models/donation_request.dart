import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DonationRequest {
  final String id;
  final String name;
  final String bloodType;
  final String bankId;
  final String phone;
  final String dateTime;
  final String medicalCondition;
  final String? note;
  final String? otherCondition;
  final String state;
  final String userId;
  final String? acceptedDonation;

  DonationRequest({
    required this.id,
    required this.name,
    required this.bloodType,
    required this.bankId,
    required this.phone,
    required this.dateTime,
    required this.medicalCondition,
    this.note,
    this.otherCondition,
    required this.state,
    required this.userId,
    this.acceptedDonation,
  });
}

Future<List<DonationRequest?>> getDonationRequests() async {
  final User? user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    return [];
  }

  String currentUserId = user.uid;
  DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(currentUserId)
      .get();

  if (!userSnapshot.exists) {
    return [];
  }

  Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
  String userBloodType = userData['bloodType'];

  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('requests')
      .orderBy('dateTime')
      .get();

  DateTime now = DateTime.now();

  List<DonationRequest?> requests = snapshot.docs
      .map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        DateTime requestDateTime = DateTime.parse(data['dateTime']);
        if (requestDateTime.isAfter(now)) {
          if (data['userId'] != currentUserId &&
              _isCompatibleBloodType(userBloodType, data['bloodType']) &&
              data['state'] != "1") {
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
              acceptedDonation: data.containsKey('acceptedDonation')
                  ? data['acceptedDonation'] as String?
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
    case 'AB+':
      return requestBloodType == 'AB+';
    case 'AB-':
      return requestBloodType == 'AB+' || requestBloodType == 'AB-';
    case 'A+':
      return requestBloodType == 'A+' || requestBloodType == 'O+';
    case 'A-':
      return requestBloodType == 'A+' ||
          requestBloodType == 'A-' ||
          requestBloodType == 'AB+' ||
          requestBloodType == 'AB-';
    case 'B+':
      return requestBloodType == 'B+' || requestBloodType == 'AB+';
    case 'B-':
      return requestBloodType == 'B+' ||
          requestBloodType == 'B-' ||
          requestBloodType == 'AB+' ||
          requestBloodType == 'AB-';
    case 'O+':
      return requestBloodType == 'AB+' ||
          requestBloodType == 'A+' ||
          requestBloodType == 'B+' ||
          requestBloodType == 'O+';
    case 'O-':
      return true;
    default:
      return false;
  }
}

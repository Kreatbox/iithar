
import 'package:iithar/models/donation_request.dart';

Future<List<DonationRequest>> getDonationRequests() async {
  await Future.delayed(const Duration(milliseconds: 500));
  return [
    DonationRequest(
      name: 'مستشفى الأسد',
      bloodType: 'A+',
      location: 'دمشق',
    ),
    DonationRequest(
      name: 'مستشفى الباسل',
      bloodType: 'B-',
      location: 'حلب',
    ),
    DonationRequest(
      name: 'مستشفى الفارابي',
      bloodType: 'O+',
      location: 'حمص',
    ),
    DonationRequest(
      name: 'مستشفى الأسد',
      bloodType: 'AB-',
      location: 'دمشق',
    ),
    DonationRequest(
      name: 'مستشفى الباسل',
      bloodType: 'A-',
      location: 'حلب',
    ),
    DonationRequest(
      name: 'مستشفى الفارابي',
      bloodType: 'B+',
      location: 'حمص',
    ),
  ];
}

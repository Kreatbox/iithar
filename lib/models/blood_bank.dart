import 'package:latlong2/latlong.dart';

class BloodBank {
  final String bankId;
  final String name;
  final String hours;
  final String phoneNumber;
  final LatLng location;
  final String place;

  BloodBank({
    required this.bankId,
    required this.name,
    required this.hours,
    required this.phoneNumber,
    required this.location,
    required this.place,
  });

  Map<String, dynamic> toJson() {
    return {
      'bankId': bankId,
      'name': name,
      'hours': hours,
      'phoneNumber': phoneNumber,
      'location': '${location.latitude},${location.longitude}',
      'place': place,
    };
  }

  factory BloodBank.fromJson(Map<String, dynamic> json) {
    List<String> coordinates = json['location'].split(',');
    double latitude = double.parse(coordinates[0]);
    double longitude = double.parse(coordinates[1]);

    return BloodBank(
      bankId: json['bankId'],
      name: json['name'],
      hours: json['hours'],
      phoneNumber: json['phoneNumber'],
      location: LatLng(latitude, longitude),
      place: json['place'],
    );
  }
}

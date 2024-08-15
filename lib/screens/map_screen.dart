import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  MapScreenState createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  LatLng? _currentLocation;
  List<BloodBank> _bloodBanks = [];

  @override
  void initState() {
    super.initState();
    _getUserLocation();
    _fetchBloodBankLocations();
  }

  Future<void> _getUserLocation() async {
    Location location = Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    LocationData locationData = await location.getLocation();
    setState(() {
      _currentLocation =
          LatLng(locationData.latitude!, locationData.longitude!);
    });
  }

  Future<void> _fetchBloodBankLocations() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot querySnapshot = await firestore.collection('banks').get();

    final List<BloodBank> fetchedBanks = [];
    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      String bankId = doc.id;
      String name = data['name'];
      String place = data['place'];
      String hours = data['hours'];
      String phoneNumber = data['phoneNumber'];
      String location = data['location'];
      List<String> coordinates = location.split(',');
      double latitude = double.parse(coordinates[0]);
      double longitude = double.parse(coordinates[1]);
      fetchedBanks.add(BloodBank(
        bankId: bankId,
        name: name,
        place: place,
        hours: hours,
        phoneNumber: phoneNumber,
        location: LatLng(latitude, longitude),
      ));
    }

    setState(() {
      _bloodBanks = fetchedBanks;
    });
  }

  LatLng _findNearestBloodBank() {
    if (_currentLocation == null) {
      return _bloodBanks.isEmpty ? const LatLng(0, 0) : _bloodBanks[0].location;
    }

    double minDistance = double.infinity;
    LatLng nearestLocation = const LatLng(33.4986997, 36.245859);

    for (BloodBank bank in _bloodBanks) {
      double distance = _calculateDistance(_currentLocation!, bank.location);
      if (distance < minDistance) {
        minDistance = distance;
        nearestLocation = bank.location;
      }
    }

    return nearestLocation;
  }

  double _calculateDistance(LatLng start, LatLng end) {
    final double lat1 = start.latitude;
    final double lon1 = start.longitude;
    final double lat2 = end.latitude;
    final double lon2 = end.longitude;

    const double p = 0.017453292519943295; // Pi/180
    final double a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;

    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }

  @override
  Widget build(BuildContext context) {
    LatLng nearestBloodBank = _findNearestBloodBank();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              'خريطة البنوك الدموية',
              textAlign: TextAlign.right,
              style: TextStyle(
                  fontFamily: 'HSI', fontSize: 30, color: Colors.black),
            ),
          ),
        ),
      ),
      body: FlutterMap(
        options: MapOptions(
          // Initialize the map center and zoom level
          initialCenter:
              _currentLocation ?? const LatLng(33.4986997, 36.245859), // Syria
          initialZoom: 16.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: [
              if (_currentLocation != null)
                Marker(
                  width: 80.0,
                  height: 80.0,
                  point: _currentLocation!,
                  // Using a custom child widget for the marker
                  child: Container(
                    child: IconButton(
                      icon: const Icon(Icons.my_location),
                      color: Colors.blue,
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (builder) {
                            return Container(
                              color: Colors.white,
                              child: const Text("bottom sheet"),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ..._bloodBanks.map(
                (bank) => Marker(
                  width: 80.0,
                  height: 80.0,
                  point: bank.location,
                  // Using a custom child widget for the marker
                  child: Container(
                    height: 50,
                    width: 100,
                    child: IconButton(
                      icon: const Icon(Icons.location_on),
                      color: Colors.red,
                      iconSize: 45.0,
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (builder) {
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              height: 300,
                              width: 400,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 400,
                                    padding: const EdgeInsets.only(
                                        left: 0.0,
                                        right: 0.0,
                                        top: 10.0,
                                        bottom: 10.0),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFAE0E03),
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    child: Text(
                                      bank.name,
                                      style: const TextStyle(
                                        fontFamily: 'HSI',
                                        color: Colors.white,
                                        fontSize: 30,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                        bank.place,
                                        style: const TextStyle(
                                          fontFamily: 'HSI',
                                          color: Colors.black,
                                          fontSize: 20,
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                      const Icon(
                                        Icons.location_on,
                                        color: Color(0xFFAE0E03),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 15),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                        bank.phoneNumber,
                                        style: const TextStyle(
                                          fontFamily: 'HSI',
                                          color: Colors.black,
                                          fontSize: 20,
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                      const Icon(
                                        Icons.phone,
                                        color: Color(0xFFAE0E03),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 15),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                        bank.hours,
                                        style: const TextStyle(
                                          fontFamily: 'HSI',
                                          color: Colors.black,
                                          fontSize: 20,
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                      const Icon(
                                        Icons.lock_clock,
                                        color: Color(0xFFAE0E03),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 30),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      fixedSize: const Size(180, 45),
                                      backgroundColor: const Color(0xFFAE0E03),
                                      padding: const EdgeInsets.only(
                                          right: 25.0,
                                          left: 25.0,
                                          top: 5.0,
                                          bottom: 1.0),
                                      alignment: Alignment.center,
                                    ),
                                    onPressed: () {
                                      Navigator.pushNamed(
                                        context,
                                        '/appointment',
                                        arguments: {'bankId': bank.bankId},
                                      );
                                    },
                                    child: const Text(
                                      'احجز موعداً الآن',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'HSI',
                                        fontSize: 20,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
              if (_currentLocation != null)
                Marker(
                  width: 80.0,
                  height: 80.0,
                  point: nearestBloodBank,
                  // Using a custom child widget for the marker
                  child: const Icon(
                    Icons.star,
                    color: Colors.green,
                    size: 45.0,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class BloodBank {
  final String bankId;
  final String name;
  final String place;
  final String hours;
  final String phoneNumber;
  final LatLng location;

  BloodBank({
    required this.bankId,
    required this.name,
    required this.place,
    required this.hours,
    required this.phoneNumber,
    required this.location,
  });
}

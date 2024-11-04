import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:iithar/models/blood_bank.dart';
import 'package:iithar/services/data_service.dart';

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
    final dataService = DataService();
    List<BloodBank> fetchedBanks = await dataService.loadBankData();
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
        title: const Align(
          alignment: Alignment.centerRight,
          child: Text(
            'خريطة البنوك الدموية',
            textAlign: TextAlign.right,
            style:
                TextStyle(fontFamily: 'HSI', fontSize: 30, color: Colors.black),
          ),
        ),
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter:
              _currentLocation ?? const LatLng(33.4986997, 36.245859),
          initialZoom: 12.0,
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
              ..._bloodBanks.map(
                (bank) => Marker(
                  width: 80.0,
                  height: 80.0,
                  point: bank.location,
                  child: SizedBox(
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
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(25),
                                    topRight: Radius.circular(25),
                                    bottomLeft: Radius.zero,
                                    bottomRight: Radius.zero),
                              ),
                              height: 300,
                              width: 400,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 400,
                                    padding: const EdgeInsets.all(8),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFAE0E03),
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(25),
                                          topRight: Radius.circular(25),
                                          bottomLeft: Radius.zero,
                                          bottomRight: Radius.zero),
                                    ),
                                    child: Text(
                                      bank.name,
                                      style: const TextStyle(
                                        fontFamily: 'HSI',
                                        color: Colors.white,
                                        fontSize: 35,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        bank.place,
                                        style: const TextStyle(
                                          fontFamily: 'HSI',
                                          color: Colors.black,
                                          fontSize: 23,
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                      const SizedBox(width: 20),
                                      const Icon(
                                        Icons.location_on,
                                        color: Color(0xFFAE0E03),
                                        size: 28,
                                      ),
                                      const SizedBox(width: 15),
                                    ],
                                  ),
                                  const SizedBox(height: 15),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        bank.phoneNumber,
                                        style: const TextStyle(
                                          fontFamily: 'HSI',
                                          color: Colors.black,
                                          fontSize: 23,
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                      const SizedBox(width: 20),
                                      const Icon(
                                        Icons.phone,
                                        color: Color(0xFFAE0E03),
                                        size: 28,
                                      ),
                                      const SizedBox(width: 15),
                                    ],
                                  ),
                                  const SizedBox(height: 15),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        bank.hours,
                                        style: const TextStyle(
                                          fontFamily: 'HSI',
                                          color: Colors.black,
                                          fontSize: 23,
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                      const SizedBox(width: 20),
                                      const Icon(
                                        Icons.lock_clock,
                                        color: Color(0xFFAE0E03),
                                        size: 28,
                                      ),
                                      const SizedBox(width: 15),
                                    ],
                                  ),
                                  const SizedBox(height: 15),
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

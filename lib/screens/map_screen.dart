import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? _currentLocation;
  final List<LatLng> _bloodBankLocations = [
    const LatLng(33.5138, 36.2765), // Damascus
    const LatLng(34.8021, 38.9968), // Palmyra
    const LatLng(36.2021, 37.1343), // Aleppo
    const LatLng(35.3328, 40.1372), // Deir ez-Zor
    const LatLng(35.9297, 36.6342), // Hama
    const LatLng(35.2509, 33.5369), // Latakia
    const LatLng(34.5641, 36.0789), // Homs
    const LatLng(32.5329, 36.6342), // Daraa
    const LatLng(36.5006, 37.5244), // Idlib
  ];

  @override
  void initState() {
    super.initState();
    _getUserLocation();
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

  LatLng _findNearestBloodBank() {
    if (_currentLocation == null) {
      return _bloodBankLocations[
          0]; // Default to first location if user location is not available
    }

    double minDistance = double.infinity;
    LatLng nearestLocation = _bloodBankLocations[0];

    for (LatLng location in _bloodBankLocations) {
      double distance = _calculateDistance(_currentLocation!, location);
      if (distance < minDistance) {
        minDistance = distance;
        nearestLocation = location;
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
        title: const Text('خريطة البنوك الدموية'),
      ),
      body: FlutterMap(
        options: MapOptions(
          // Initialize the map center and zoom level
          initialCenter:
              _currentLocation ?? const LatLng(34.8021, 38.9968), // Syria
          initialZoom: 8.0,
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
                  child: const Icon(
                    Icons.my_location,
                    color: Colors.blue,
                    size: 40.0,
                  ),
                ),
              ..._bloodBankLocations.map(
                (location) => Marker(
                  width: 80.0,
                  height: 80.0,
                  point: location,
                  // Using a custom child widget for the marker
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 40.0,
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
                    size: 40.0,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

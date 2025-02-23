import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
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
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition();

    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
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
      double distance = Geolocator.distanceBetween(
        _currentLocation!.latitude,
        _currentLocation!.longitude,
        bank.location.latitude,
        bank.location.longitude,
      );
      if (distance < minDistance) {
        minDistance = distance;
        nearestLocation = bank.location;
      }
    }
    return nearestLocation;
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
                  child: const Icon(Icons.my_location,
                      color: Colors.blue, size: 45.0),
                ),
              ..._bloodBanks.map(
                (bank) => Marker(
                  width: 80.0,
                  height: 80.0,
                  point: bank.location,
                  child: const Icon(Icons.location_on,
                      color: Colors.red, size: 45.0),
                ),
              ),
              if (_currentLocation != null)
                Marker(
                  width: 80.0,
                  height: 80.0,
                  point: nearestBloodBank,
                  child:
                      const Icon(Icons.star, color: Colors.green, size: 45.0),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

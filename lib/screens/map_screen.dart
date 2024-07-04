import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('خريطة البنوك الدموية'),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(30.0444, 31.2357), // Cairo coordinates (example)
          zoom: 12,
        ),
        markers: {
          Marker(
            markerId: MarkerId('1'),
            position: LatLng(30.0444, 31.2357), // Example blood bank location
            infoWindow: InfoWindow(title: 'Blood Bank 1'),
          ),
          Marker(
            markerId: MarkerId('2'),
            position: LatLng(30.0555, 31.2457), // Example blood bank location
            infoWindow: InfoWindow(title: 'Blood Bank 2'),
          ),
        },
      ),
    );
  }
}
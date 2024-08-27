import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:iithar/models/blood_bank.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataService {
  static const String _cacheKey = 'cached_bank_data';
  Future<void> fetchAndCacheBankData() async {
    try {
      final QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('banks').get();
      final List<BloodBank> bankList = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String bankId = doc.id;
        String name = data['name'];
        String hours = data['hours'];
        String phoneNumber = data['phoneNumber'];
        String location = data['location'];
        String place = data['place'];
        List<String> coordinates = location.split(',');
        double latitude = double.parse(coordinates[0]);
        double longitude = double.parse(coordinates[1]);

        return BloodBank(
          bankId: bankId,
          name: name,
          hours: hours,
          phoneNumber: phoneNumber,
          location: LatLng(latitude, longitude),
          place: place,
        );
      }).toList();

      final String jsonString =
          jsonEncode(bankList.map((bank) => bank.toJson()).toList());
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, jsonString);

      if (kDebugMode) {
        print("Bank data cached successfully!");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching and caching bank data: $e");
      }
    }
  }

  Future<List<BloodBank>> getBankDataFromCache() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_cacheKey);
    if (jsonString != null) {
      final List<dynamic> decodedList = jsonDecode(jsonString);
      return decodedList.map((json) => BloodBank.fromJson(json)).toList();
    } else {
      return [];
    }
  }

  Future<List<BloodBank>> loadBankData() async {
    List<BloodBank> bankData = await getBankDataFromCache();
    if (bankData.isEmpty) {
      await fetchAndCacheBankData();
      bankData = await getBankDataFromCache();
    }
    return bankData;
  }
}

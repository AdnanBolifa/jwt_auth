import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:jwt_auth/data/location_config.dart';

class LocationService {
  Future<LocationData?> getUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      double? latitude = position.latitude;
      double? longitude = position.longitude;

      return LocationData(latitude: latitude, longitude: longitude);
    } catch (e) {
      debugPrint('Error getting location: $e');
    }

    return null; // Return null if location is not available or denied
  }
}

import 'package:geolocator/geolocator.dart';

import '../models/location_model.dart';

class LocationService {
  Future<void> checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw Exception('Please enable location services.');
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw Exception('Location permission denied.');
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permission permanently denied. '
            'Enable it from app settings.',
      );
    }
  }

  Future<LocationModel> getCurrentLocation() async {
    await checkLocationPermission();

    Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.best),
    );

    return convertPositionToLocationModel(position);
  }

  Stream<LocationModel> getLocationStream() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 2,
    );

    return Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).map(convertPositionToLocationModel);
  }

  LocationModel convertPositionToLocationModel(Position position) {
    return LocationModel(
      latitude: position.latitude,
      longitude: position.longitude,
      speed: position.speed,
      accuracy: position.accuracy,
      heading: position.heading,
      timestamp: position.timestamp,
    );
  }

  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }
}
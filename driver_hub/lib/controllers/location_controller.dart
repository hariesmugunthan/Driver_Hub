import 'dart:async';

import 'package:flutter/material.dart';

import '../models/location_model.dart';
import '../services/location_service.dart';

class LocationController extends ChangeNotifier {
  final LocationService locationService = LocationService();

  StreamSubscription<LocationModel>? locationSubscription;

  LocationModel? currentLocation;

  bool isTracking = false;
  bool isLoading = false;

  String? errorMessage;

  Future<void> startTracking() async {
    if (isTracking || isLoading) {
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      LocationModel initialLocation = await locationService.getCurrentLocation();

      currentLocation = initialLocation;

      locationSubscription = locationService.getLocationStream().listen(
        (LocationModel location) {
          currentLocation = location;
          notifyListeners();
        },
        onError: (error) {
          errorMessage = error.toString();
          stopTracking();
        },
      );

      isTracking = true;
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> stopTracking() async {
    await locationSubscription?.cancel();

    locationSubscription = null;
    isTracking = false;

    notifyListeners();
  }

  @override
  void dispose() {
    locationSubscription?.cancel();
    super.dispose();
  }
}
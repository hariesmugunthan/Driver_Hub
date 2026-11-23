import 'dart:async';

import 'package:flutter/material.dart';

import '../models/admin_location_model.dart';
import '../services/admin_tracking_service.dart';

class AdminTrackingController extends ChangeNotifier {
  final AdminTrackingService trackingService = AdminTrackingService();

  AdminLocationModel? currentLocation;

  Map<String, dynamic>? routeData;

  bool isLoading = false;
  bool isRouteLoading = false;
  bool isLocationLoading = false;

  String? errorMessage;

  Timer? locationPollingTimer;

  bool isDisposed = false;

  Future<void> initializeTracking(String tripId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      routeData = await trackingService.getTrackingRoute(tripId: tripId);

      await fetchLatestLocation(tripId);

      startLocationPolling(tripId);
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchLatestLocation(String tripId) async {
    debugPrint('ADMIN: Fetching latest vehicle location...');
    try {
      isLocationLoading = true;

      AdminLocationModel location = await trackingService.getLatestLocation(tripId: tripId);
      debugPrint(
        'ADMIN CONTROLLER: Received '
            '${location.latitude}, ${location.longitude}',
      );
      currentLocation = location;
      debugPrint(
        'CONTROLLER LOCATION UPDATED: '
            '${location.latitude}, ${location.longitude}',
      );
      errorMessage = null;
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
    } finally {
      isLocationLoading = false;

      if (!isDisposed) {
        notifyListeners();
      }
    }
  }

  void startLocationPolling(String tripId) {
    locationPollingTimer?.cancel();

    locationPollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      fetchLatestLocation(tripId);
    });
  }

  void stopLocationPolling() {
    locationPollingTimer?.cancel();
    locationPollingTimer = null;
  }

  @override
  void dispose() {
    isDisposed = true;
    stopLocationPolling();
    super.dispose();
  }
}

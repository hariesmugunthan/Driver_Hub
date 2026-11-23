import 'package:flutter/material.dart';

import '../models/driver_performance_model.dart';
import '../services/driver_performance_service.dart';

class DriverPerformanceController extends ChangeNotifier {
  final DriverPerformanceService performanceService = DriverPerformanceService();

  DriverPerformanceModel? performance;
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadPerformance(String driverId) async {
    isLoading = true;
    errorMessage = null;
    performance = null;
    notifyListeners();

    try {
      performance = await performanceService.getDriverPerformance(driverId: driverId);
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
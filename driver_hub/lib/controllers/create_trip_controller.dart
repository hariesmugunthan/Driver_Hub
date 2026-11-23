import 'package:flutter/foundation.dart';

import '../models/driver_id_model.dart';
import '../models/driver_model.dart';
import '../models/vehicle_id_model.dart';
import '../models/vehicle_model.dart';
import '../services/create_trip_service.dart';
import 'driver_controller.dart';
import 'vehicle_controller.dart';

class CreateTripController extends ChangeNotifier {
  final CreateTripService createTripService = CreateTripService();

  final DriverController driverController = DriverController();
  final VehicleController vehicleController = VehicleController();

  DriverModel? selectedDriver;
  VehicleModel? selectedVehicle;

  List<DriverModel> availableDrivers = [];
  List<VehicleModel> availableVehicles = [];

  bool isSavingTrip = false;
  bool isLoadingAvailability = false;

  int availabilityRequestId = 0;

  // FETCH AVAILABLE DRIVERS

  Future<List<DriverModel>> getAvailableDrivers() async {
    return await driverController.getAvailableDrivers();
  }

  // FETCH AVAILABLE VEHICLES

  Future<List<VehicleModel>> getAvailableVehicles() async {
    return await vehicleController.getAvailableVehicles();
  }

  // FETCH EXISTING DRIVER

  Future<DriverModel> getDriver(String userId) async {
    return await driverController.getDriver(DriverIdModel(userId: userId));
  }

  // FETCH EXISTING VEHICLE

  Future<VehicleModel> getVehicle(String vehicleId) async {
    return await vehicleController.getVehicle(VehicleIdModel(vehicleId: vehicleId));
  }

  // FETCH AVAILABLE DRIVERS AND VEHICLES

  Future<void> loadAvailableResources() async {
    final requestId = ++availabilityRequestId;

    isLoadingAvailability = true;
    notifyListeners();

    try {
      final drivers = await getAvailableDrivers();

      final vehicles = await getAvailableVehicles();

      if (requestId != availabilityRequestId) {
        return;
      }

      availableDrivers = drivers;
      availableVehicles = vehicles;
      isLoadingAvailability = false;

      notifyListeners();
    } catch (error) {
      if (requestId != availabilityRequestId) {
        return;
      }

      availableDrivers = [];
      availableVehicles = [];
      isLoadingAvailability = false;

      notifyListeners();

      rethrow;
    }
  }

  // INITIALIZE EXISTING DRIVER AND VEHICLE

  Future<void> initializeEditResources({
    required String driverId,
    required String vehicleId,
  }) async {
    await loadAvailableResources();

    final driver = await getDriver(driverId);
    final vehicle = await getVehicle(vehicleId);

    if (!availableDrivers.any((item) => item.userId == driver.userId)) {
      availableDrivers.add(driver);
    }

    if (!availableVehicles.any((item) => item.vehicleId == vehicle.vehicleId)) {
      availableVehicles.add(vehicle);
    }

    selectedDriver = driver;
    selectedVehicle = vehicle;

    notifyListeners();
  }

  // SELECT DRIVER

  void selectDriver(DriverModel driver) {
    selectedDriver = driver;
    notifyListeners();
  }

  // SELECT VEHICLE

  void selectVehicle(VehicleModel vehicle) {
    selectedVehicle = vehicle;
    notifyListeners();
  }

  // SAVING STATE

  void setSavingState(bool value) {
    isSavingTrip = value;
    notifyListeners();
  }

  // CREATE TRIP

  Future<Map<String, dynamic>> createTrip(Map<String, dynamic> requestData) async {
    return await createTripService.createTrip(requestData);
  }

  // UPDATE TRIP

  Future<Map<String, dynamic>> updateTrip(Map<String, dynamic> requestData) async {
    return await createTripService.updateTrip(requestData);
  }

  // CANCEL TRIP

  Future<Map<String, dynamic>> cancelTrip(String tripId) async {
    return await createTripService.cancelTrip(tripId);
  }

  // REQUIRED FIELD VALIDATION

  String? validateRequiredField(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }

    return null;
  }

  // COORDINATE VALIDATION

  String? validateCoordinate(String? value, double minimum, double maximum, String label) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }

    final coordinate = double.tryParse(value.trim());

    if (coordinate == null) {
      return 'Enter a valid number';
    }

    if (coordinate < minimum || coordinate > maximum) {
      return 'Range: $minimum to $maximum';
    }

    return null;
  }

  // INVALIDATE PENDING AVAILABILITY REQUESTS

  void invalidateAvailabilityRequests() {
    availabilityRequestId++;
  }
}
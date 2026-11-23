import 'package:dio/dio.dart';

import '../models/vehicle_id_model.dart';
import '../models/vehicle_model.dart';
import 'api_service.dart';

class VehicleService {
  ApiService apiService = ApiService();

  Future<VehicleModel> createVehicle(VehicleModel vehicleModel) async {
    Response<dynamic> response = await apiService.postRequest(
      '/vehicle/create',
      vehicleModel.toJson(),
    );

    Map<String, dynamic> responseData = response.data as Map<String, dynamic>;

    bool isSuccess = responseData['success'] as bool? ?? false;

    if (!isSuccess) {
      throw Exception(responseData['message'] ?? 'Vehicle creation failed');
    }

    Map<String, dynamic> vehicleData = responseData['data'] as Map<String, dynamic>;

    return VehicleModel.fromJson(vehicleData);
  }

  Future<List<VehicleModel>> getAllVehicles() async {
    Response<dynamic> response = await apiService.postRequest('/vehicle/get_all', {});

    Map<String, dynamic> responseData = response.data as Map<String, dynamic>;

    bool isSuccess = responseData['success'] as bool? ?? false;

    if (!isSuccess) {
      throw Exception(responseData['message'] ?? 'Vehicles retrieval failed');
    }

    List<dynamic> vehicleData = responseData['data'] as List<dynamic>;

    List<VehicleModel> vehicles = [];

    for (dynamic vehicle in vehicleData) {
      vehicles.add(VehicleModel.fromJson(vehicle as Map<String, dynamic>));
    }

    return vehicles;
  }

  // GET AVAILABLE VEHICLES

  Future<List<VehicleModel>> getAvailableVehicles() async {
    Response<dynamic> response = await apiService.postRequest('/vehicle/get_available', {});

    Map<String, dynamic> responseData = response.data as Map<String, dynamic>;

    bool isSuccess = responseData['success'] as bool? ?? false;

    if (!isSuccess) {
      throw Exception(responseData['message'] ?? 'Available vehicles retrieval failed');
    }

    List<dynamic> vehicleData = responseData['data'] as List<dynamic>;

    List<VehicleModel> vehicles = [];

    for (dynamic vehicle in vehicleData) {
      vehicles.add(VehicleModel.fromJson(vehicle as Map<String, dynamic>));
    }

    return vehicles;
  }

  Future<VehicleModel> getVehicle(VehicleIdModel vehicleIdModel) async {
    Response<dynamic> response = await apiService.postRequest(
      '/vehicle/get',
      vehicleIdModel.toJson(),
    );

    Map<String, dynamic> responseData = response.data as Map<String, dynamic>;

    bool isSuccess = responseData['success'] as bool? ?? false;

    if (!isSuccess) {
      throw Exception(responseData['message'] ?? 'Vehicle retrieval failed');
    }

    Map<String, dynamic> vehicleData = responseData['data'] as Map<String, dynamic>;

    return VehicleModel.fromJson(vehicleData);
  }

  Future<VehicleModel> updateVehicle(VehicleModel vehicleModel) async {
    Response<dynamic> response = await apiService.postRequest(
      '/vehicle/update',
      vehicleModel.toJson(),
    );

    Map<String, dynamic> responseData = response.data as Map<String, dynamic>;

    bool isSuccess = responseData['success'] as bool? ?? false;

    if (!isSuccess) {
      throw Exception(responseData['message'] ?? 'Vehicle update failed');
    }

    Map<String, dynamic> vehicleData = responseData['data'] as Map<String, dynamic>;

    return VehicleModel.fromJson(vehicleData);
  }

  Future<VehicleModel> deleteVehicle(VehicleIdModel vehicleIdModel) async {
    Response<dynamic> response = await apiService.postRequest(
      '/vehicle/delete',
      vehicleIdModel.toJson(),
    );

    Map<String, dynamic> responseData = response.data as Map<String, dynamic>;

    bool isSuccess = responseData['success'] as bool? ?? false;

    if (!isSuccess) {
      throw Exception(responseData['message'] ?? 'Vehicle deletion failed');
    }

    Map<String, dynamic> vehicleData = responseData['data'] as Map<String, dynamic>;

    return VehicleModel.fromJson(vehicleData);
  }
}
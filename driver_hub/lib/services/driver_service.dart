import 'package:dio/dio.dart';

import '../models/driver_id_model.dart';
import '../models/driver_model.dart';
import 'api_service.dart';

class DriverService {
  ApiService apiService = ApiService();

  Future<DriverModel> createDriver(DriverModel driverModel) async {
    Response<dynamic> response = await apiService.postRequest(
      '/driver/create',
      driverModel.toJson(),
    );

    Map<String, dynamic> responseData = response.data as Map<String, dynamic>;

    bool isSuccess = responseData['success'] as bool? ?? false;

    if (!isSuccess) {
      throw Exception(responseData['message'] ?? 'Driver creation failed');
    }

    Map<String, dynamic> driverData = responseData['data'] as Map<String, dynamic>;

    return DriverModel.fromJson(driverData);
  }

  Future<List<DriverModel>> getAllDrivers() async {
    try {
      print('[driver_service] Fetching all drivers');

      Response<dynamic> response = await apiService.postRequest('/driver/get_all', {});

      print('[driver_service] Response status: ${response.statusCode}');
      print('[driver_service] Response data: ${response.data}');

      Map<String, dynamic> responseData = response.data as Map<String, dynamic>;

      bool isSuccess = responseData['success'] as bool? ?? false;

      if (!isSuccess) {
        throw Exception(responseData['message'] ?? 'Drivers retrieval failed');
      }

      List<dynamic> driverData = responseData['data'] as List<dynamic>;

      List<DriverModel> drivers = [];

      for (dynamic driver in driverData) {
        drivers.add(DriverModel.fromJson(driver as Map<String, dynamic>));
      }

      print('[driver_service] Drivers parsed: ${drivers.length}');

      return drivers;
    } catch (error) {
      print('[driver_service] Error fetching drivers: $error');
      rethrow;
    }
  }

  // GET AVAILABLE DRIVERS

  Future<List<DriverModel>> getAvailableDrivers() async {
    Response<dynamic> response = await apiService.postRequest('/driver/get_available', {});

    Map<String, dynamic> responseData = response.data as Map<String, dynamic>;

    bool isSuccess = responseData['success'] as bool? ?? false;

    if (!isSuccess) {
      throw Exception(responseData['message'] ?? 'Available drivers retrieval failed');
    }

    List<dynamic> driverData = responseData['data'] as List<dynamic>;

    List<DriverModel> drivers = [];

    for (dynamic driver in driverData) {
      drivers.add(DriverModel.fromJson(driver as Map<String, dynamic>));
    }

    return drivers;
  }

  Future<DriverModel> getDriver(DriverIdModel driverIdModel) async {
    Response<dynamic> response = await apiService.postRequest(
      '/driver/get',
      driverIdModel.toJson(),
    );

    Map<String, dynamic> responseData = response.data as Map<String, dynamic>;

    bool isSuccess = responseData['success'] as bool? ?? false;

    if (!isSuccess) {
      throw Exception(responseData['message'] ?? 'Driver retrieval failed');
    }

    Map<String, dynamic> driverData = responseData['data'] as Map<String, dynamic>;

    return DriverModel.fromJson(driverData);
  }

  Future<DriverModel> updateDriver(DriverModel driverModel) async {
    Response<dynamic> response = await apiService.postRequest(
      '/driver/update',
      driverModel.toJson(),
    );

    Map<String, dynamic> responseData = response.data as Map<String, dynamic>;

    bool isSuccess = responseData['success'] as bool? ?? false;

    if (!isSuccess) {
      throw Exception(responseData['message'] ?? 'Driver update failed');
    }

    Map<String, dynamic> driverData = responseData['data'] as Map<String, dynamic>;

    return DriverModel.fromJson(driverData);
  }

  Future<DriverModel> deleteDriver(DriverIdModel driverIdModel) async {
    Response<dynamic> response = await apiService.postRequest(
      '/driver/delete',
      driverIdModel.toJson(),
    );

    Map<String, dynamic> responseData = response.data as Map<String, dynamic>;

    bool isSuccess = responseData['success'] as bool? ?? false;

    if (!isSuccess) {
      throw Exception(responseData['message'] ?? 'Driver deletion failed');
    }

    Map<String, dynamic> driverData = responseData['data'] as Map<String, dynamic>;

    return DriverModel.fromJson(driverData);
  }
}
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/admin_location_model.dart';
import 'api_service.dart';

class AdminTrackingService {
  final ApiService apiService = ApiService();

  Future<Map<String, dynamic>> getTrackingRoute({required String tripId}) async {
    try {
      Response<dynamic> response = await apiService.postRequest(
        '/simulation/get_route',
        {'tripId': tripId},
      );

      Map<String, dynamic> responseData = response.data as Map<String, dynamic>;

      bool isSuccess = responseData['success'] as bool? ?? false;

      if (!isSuccess) {
        throw Exception(responseData['message'] ?? 'Unable to retrieve trip route.');
      }

      return responseData['data'] as Map<String, dynamic>;
    } on DioException catch (error) {
      dynamic responseData = error.response?.data;

      if (responseData is Map<String, dynamic> && responseData['message'] is String) {
        throw Exception(responseData['message']);
      }

      throw Exception('Unable to retrieve trip route.');
    }
  }

  Future<AdminLocationModel> getLatestLocation({required String tripId}) async {
    try {
      Response<dynamic> response = await apiService.postRequest(
        '/simulation/get_location',
        {'tripId': tripId},
      );

      Map<String, dynamic> responseData = response.data as Map<String, dynamic>;

      bool isSuccess = responseData['success'] as bool? ?? false;

      if (!isSuccess) {
        throw Exception(responseData['message'] ?? 'Unable to retrieve vehicle location.');
      }

      Map<String, dynamic> locationData = responseData['data'] as Map<String, dynamic>;

      AdminLocationModel location = AdminLocationModel.fromJson(locationData);

      debugPrint(
        'API LOCATION: '
            'Lat=${location.latitude}, '
            'Lng=${location.longitude}, '
            'UpdatedAt=${location.updatedAt}',
      );

      return location;

    } on DioException catch (error) {
      dynamic responseData = error.response?.data;

      if (responseData is Map<String, dynamic> && responseData['message'] is String) {
        throw Exception(responseData['message']);
      }

      throw Exception('Unable to retrieve vehicle location.');

    }

  }
}

import 'package:dio/dio.dart';

import 'api_service.dart';

class RouteService {
  ApiService apiService = ApiService();

  Future<Map<String, dynamic>> computeRoute({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) async {

    Response<dynamic> response = await apiService.postRequest('/route/compute', {
      'startLatitude': startLatitude,
      'startLongitude': startLongitude,
      'endLatitude': endLatitude,
      'endLongitude': endLongitude,
    });

    Map<String, dynamic> responseData = response.data as Map<String, dynamic>;

    bool isSuccess = responseData['success'] as bool? ?? false;

    if (!isSuccess) {
      throw Exception(responseData['message'] ?? 'Driving route calculation failed');
    }

    Map<String, dynamic> routeData = responseData['data'] as Map<String, dynamic>;

    return routeData;
  }
}
import '../services/api_service.dart';
import '../models/driver_performance_model.dart';

class DriverPerformanceService {
  final ApiService apiService = ApiService();

  Future<DriverPerformanceModel> getDriverPerformance({required String driverId}) async {
    final response = await apiService.postRequest(
      '/trip/get_driver_performance',
      {'driverId': driverId},
    );

    final responseData = response.data as Map<String, dynamic>;

    if (responseData['success'] != true) {
      throw Exception(responseData['message'] ?? 'Failed to retrieve driver performance');
    }

    final performanceData = responseData['data'] as Map<String, dynamic>;

    return DriverPerformanceModel.fromJson(performanceData);
  }
}
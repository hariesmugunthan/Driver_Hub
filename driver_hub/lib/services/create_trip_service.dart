import '../services/api_service.dart';

class CreateTripService {
  final ApiService apiService = ApiService();

  // CREATE TRIP

  Future<Map<String, dynamic>> createTrip(Map<String, dynamic> requestData) async {
    final response = await apiService.postRequest('/trip/create', requestData);

    final data = response.data as Map<String, dynamic>;

    if (data['success'] != true) {
      throw Exception(data['message'] ?? 'Trip creation failed');
    }

    return data;
  }

  // UPDATE TRIP

  Future<Map<String, dynamic>> updateTrip(Map<String, dynamic> requestData) async {
    final response = await apiService.postRequest('/trip/update', requestData);

    final data = response.data as Map<String, dynamic>;

    if (data['success'] != true) {
      throw Exception(data['message'] ?? 'Trip update failed');
    }

    return data;
  }

  // CANCEL TRIP

  Future<Map<String, dynamic>> cancelTrip(String tripId) async {
    final response = await apiService.postRequest('/trip/cancel', {'tripId': tripId});

    final data = response.data as Map<String, dynamic>;

    if (data['success'] != true) {
      throw Exception(data['message'] ?? 'Trip cancellation failed');
    }

    return data;
  }
}
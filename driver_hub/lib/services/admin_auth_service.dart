import 'package:dio/dio.dart';

import 'api_service.dart';

class AdminAuthService {
  ApiService apiService = ApiService();

  Future<Map<String, dynamic>> authenticateUser(String firebaseIdToken, String role) async {
    Response<dynamic> response = await apiService.postRequest(
      '/admin/login',
      {'firebaseToken': firebaseIdToken, 'role': role},
    );

    Map<String, dynamic> responseData = response.data as Map<String, dynamic>;

    bool isSuccess = responseData['success'] as bool? ?? false;

    if (!isSuccess) {
      throw Exception(responseData['message'] ?? 'User authentication failed');
    }

    return responseData['data'] as Map<String, dynamic>;
  }
}
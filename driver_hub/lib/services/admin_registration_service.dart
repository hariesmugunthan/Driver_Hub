import 'package:dio/dio.dart';

import '../models/admin_registration_model.dart';
import 'api_service.dart';

class AdminRegistrationService {
  ApiService apiService = ApiService();

  Future<void> registerAdmin(AdminRegistrationModel adminRegistrationModel) async {
    Response<dynamic> response = await apiService.postRequest(
      '/admin/register',
      adminRegistrationModel.toJson(),
    );

    Map<String, dynamic> responseData = response.data as Map<String, dynamic>;

    bool isSuccess = responseData['success'] as bool? ?? false;

    if (!isSuccess) {
      throw Exception(responseData['message'] ?? 'Admin registration failed');
    }
  }
}
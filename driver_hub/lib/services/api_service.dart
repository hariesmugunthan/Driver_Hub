import 'package:dio/dio.dart';

import '../configs/api_config.dart';

class ApiService {
  Dio dio;

  ApiService() : dio = Dio(
BaseOptions(
  baseUrl: ApiConfig.baseUrl,
  contentType: 'application/json',
  responseType: ResponseType.json,
),
  );

  Future<Response<dynamic>> postRequest(String endpoint, Map<String, dynamic> requestData) async {
    return dio.post(endpoint, data: requestData);
  }
}
import 'package:dio/dio.dart';

import '../models/trip_model.dart';
import 'api_service.dart';

class TripService {
  ApiService apiService = ApiService();

  Future<List<TripModel>> getTripsByDriverId(String driverId) async {
    print('REQUESTED DRIVER ID: $driverId');
    Response<dynamic> response = await apiService.postRequest(
      '/trip/get_by_driver',
      {'driverId': driverId},
    );
    print('TRIP API RESPONSE: ${response.data}');

    Map<String, dynamic> responseData = response.data as Map<String, dynamic>;

    bool isSuccess = responseData['success'] as bool? ?? false;

    if (!isSuccess) {
      throw Exception(responseData['message'] ?? 'Driver trips retrieval failed');
    }

    List<dynamic> tripData = responseData['data'] as List<dynamic>;

    List<TripModel> trips = [];

    for (dynamic trip in tripData) {
      trips.add(TripModel.fromJson(trip as Map<String, dynamic>));
    }

    return trips;
  }
  Future<List<TripModel>> getAllTrips() async {
    print('REQUESTING ALL TRIPS');

    Response<dynamic> response = await apiService.postRequest('/trip/get_all', {});

    print('ALL TRIPS API RESPONSE: ${response.data}');

    Map<String, dynamic> responseData = response.data as Map<String, dynamic>;

    bool isSuccess = responseData['success'] as bool? ?? false;

    if (!isSuccess) {
      throw Exception(responseData['message'] ?? 'All trips retrieval failed');
    }

    List<dynamic> tripData = responseData['data'] as List<dynamic>;

    List<TripModel> trips = [];

    for (dynamic trip in tripData) {
      trips.add(TripModel.fromJson(trip as Map<String, dynamic>));
    }

    return trips;
  }
  Future<void> deleteTrip(String tripId) async {
    try {
      Response<dynamic> response = await apiService.postRequest('/trip/delete', {'tripId': tripId});

      Map<String, dynamic> responseData = response.data as Map<String, dynamic>;

      bool isSuccess = responseData['success'] as bool? ?? false;

      if (!isSuccess) {
        throw Exception(responseData['message'] ?? 'Trip deletion failed');
      }
    } on DioException catch (error) {
      dynamic responseData = error.response?.data;

      if (responseData is Map<String, dynamic> && responseData['message'] is String) {
        throw Exception(responseData['message']);
      }

      throw Exception('Unable to delete trip. Please try again.');
    }
  }
  Future<void> startTrip({required String tripId, required String driverId}) async {
    await updateTripStatus(
      endpoint: '/trip/start',
      tripId: tripId,
      driverId: driverId,
      failureMessage: 'Unable to start trip. Please try again.',
    );
  }

  Future<void> endTrip({
    required String tripId,
    required String driverId,
    required double totalDistanceMeters,
  }) async {
    try {
      Response<dynamic> response = await apiService.postRequest(
        '/trip/end',
        {'tripId': tripId, 'driverId': driverId, 'totalDistanceMeters': totalDistanceMeters},
      );

      Map<String, dynamic> responseData = response.data as Map<String, dynamic>;

      bool isSuccess = responseData['success'] as bool? ?? false;

      if (!isSuccess) {
        throw Exception(responseData['message'] ?? 'Unable to complete trip. Please try again.');
      }
    } on DioException catch (error) {
      dynamic responseData = error.response?.data;

      if (responseData is Map<String, dynamic> && responseData['message'] is String) {
        throw Exception(responseData['message']);
      }

      throw Exception('Unable to complete trip. Please try again.');
    }
  }
  Future<void> updateTripStatus({
    required String endpoint,
    required String tripId,
    required String driverId,
    required String failureMessage,
  }) async {
    try {
      Response<dynamic> response = await apiService.postRequest(
        endpoint,
        {'tripId': tripId, 'driverId': driverId},
      );

      Map<String, dynamic> responseData = response.data as Map<String, dynamic>;

      bool isSuccess = responseData['success'] as bool? ?? false;

      if (!isSuccess) {
        throw Exception(responseData['message'] ?? failureMessage);
      }
    } on DioException catch (error) {
      dynamic responseData = error.response?.data;

      if (responseData is Map<String, dynamic> && responseData['message'] is String) {
        throw Exception(responseData['message']);
      }

      throw Exception(failureMessage);
    }
  }
  Future<TripModel> getTripById(String tripId) async {
    try {
      Response<dynamic> response = await apiService.postRequest('/trip/get', {'tripId': tripId});

      Map<String, dynamic> responseData = response.data as Map<String, dynamic>;

      bool isSuccess = responseData['success'] as bool? ?? false;

      if (!isSuccess) {
        throw Exception(responseData['message'] ?? 'Trip retrieval failed');
      }

      Map<String, dynamic> tripData = responseData['data'] as Map<String, dynamic>;

      return TripModel.fromJson(tripData);

    } on DioException catch (error) {
      dynamic responseData = error.response?.data;

      if (responseData is Map<String, dynamic> && responseData['message'] is String) {
        throw Exception(responseData['message']);
      }

      throw Exception('Unable to retrieve trip details.');
    }
  }
}
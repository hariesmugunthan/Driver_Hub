import '../models/trip_model.dart';
import '../services/trip_service.dart';

class TripController {
  TripService tripService = TripService();

  Future<List<TripModel>> getTripsByDriverId(String driverId) async {
    List<TripModel> tripList = await tripService.getTripsByDriverId(driverId);

    return tripList;
  }
  Future<List<TripModel>> getAllTrips() async {
    List<TripModel> tripList = await tripService.getAllTrips();

    return tripList;
  }
  Future<void> deleteTrip(String tripId) async {
    await tripService.deleteTrip(tripId);
  }
}
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RouteProgressModel {
  final double travelledDistanceMeters;
  final double remainingDistanceMeters;
  final double totalDistanceMeters;
  final double distanceFromRouteMeters;

  final LatLng snappedLocation;

  final List<LatLng> completedRoutePoints;
  final List<LatLng> remainingRoutePoints;

  const RouteProgressModel({
    required this.travelledDistanceMeters,
    required this.remainingDistanceMeters,
    required this.totalDistanceMeters,
    required this.distanceFromRouteMeters,
    required this.snappedLocation,
    required this.completedRoutePoints,
    required this.remainingRoutePoints,
  });
}
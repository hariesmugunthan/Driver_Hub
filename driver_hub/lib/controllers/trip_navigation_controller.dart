import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/location_model.dart';
import '../models/route_progress_model.dart';

class TripNavigationController extends ChangeNotifier {
  static const double maximumGpsAccuracy = 40;
  static const double maximumDistanceFromRoute = 100;

  List<LatLng> routePoints = [];
  List<double> cumulativeDistances = [];

  double totalRouteGeometryDistance = 0;
  double totalDistanceMeters = 0;
  double maximumProgressMeters = 0;
  static const double destinationRadiusMeters = 100;
  static const double arrivalGpsAccuracyMeters = 25;
  static const int requiredArrivalReadings = 5;

  int consecutiveDestinationReadings = 0;
  bool hasReachedDestination = false;

  // Stores the furthest confirmed progress along the route.
  int maximumProgressSegmentIndex = 0;
  double maximumProgressFraction = 0;
  LatLng? maximumProgressPoint;

  RouteProgressModel? routeProgress;

  // Initialize route and calculate cumulative distances.
  void initializeRoute({required List<LatLng> points, required double totalDistance}) {
    routePoints = points;
    totalDistanceMeters = totalDistance;

    cumulativeDistances = [0];
    consecutiveDestinationReadings = 0;
    hasReachedDestination = false;
    totalRouteGeometryDistance = 0;
    maximumProgressMeters = 0;

    maximumProgressSegmentIndex = 0;
    maximumProgressFraction = 0;
    maximumProgressPoint = null;

    routeProgress = null;

    for (int index = 0; index < routePoints.length - 1; index++) {
      double segmentDistance = calculateDistance(routePoints[index], routePoints[index + 1]);

      totalRouteGeometryDistance += segmentDistance;

      cumulativeDistances.add(totalRouteGeometryDistance);
    }

    notifyListeners();
  }

  // Update route progress using the driver's current GPS location.
  void updateLocation(LocationModel location) {
    if (routePoints.length < 2 || location.accuracy > maximumGpsAccuracy ||
        totalRouteGeometryDistance <= 0) {
      return;
    }

    LatLng currentPosition = LatLng(location.latitude, location.longitude);

    int nearestSegmentIndex = -1;
    double nearestDistance = double.infinity;
    double nearestProgress = 0;
    double nearestFraction = 0;

    LatLng? nearestProjectedPoint;

    for (int index = 0; index < routePoints.length - 1; index++) {
      LatLng start = routePoints[index];
      LatLng end = routePoints[index + 1];

      Map<String, dynamic> projection = projectPointOntoSegment(currentPosition, start, end);

      double distanceFromRoute = projection['distance'] as double;

      double progressOnSegment = projection['fraction'] as double;

      double segmentLength = cumulativeDistances[index + 1] - cumulativeDistances[index];

      double progressAlongRoute = cumulativeDistances[index] + (segmentLength * progressOnSegment);

      // Ignore GPS projections significantly behind previous progress.
      if (progressAlongRoute < maximumProgressMeters - 15) {
        continue;
      }

      if (distanceFromRoute < nearestDistance) {
        nearestDistance = distanceFromRoute;
        nearestSegmentIndex = index;
        nearestProgress = progressAlongRoute;
        nearestFraction = progressOnSegment;

        nearestProjectedPoint = projection['point'] as LatLng;
      }
    }

    if (nearestSegmentIndex == -1 || nearestProjectedPoint == null ||
        nearestDistance > maximumDistanceFromRoute) {
      return;
    }

    // Update stored progress only when the driver moves forward.
    if (nearestProgress > maximumProgressMeters || maximumProgressPoint == null) {
      maximumProgressMeters = nearestProgress;
      maximumProgressSegmentIndex = nearestSegmentIndex;
      maximumProgressFraction = nearestFraction;
      maximumProgressPoint = nearestProjectedPoint;
    }

    double progressRatio = (maximumProgressMeters / totalRouteGeometryDistance)
        .clamp(0.0, 1.0);

    double travelledDistance = totalDistanceMeters * progressRatio;

    double remainingDistance = math.max(0, totalDistanceMeters - travelledDistance);

    // Use maximum recorded progress to split the route.
    LatLng progressPoint = maximumProgressPoint!;

    List<LatLng> completedPoints = [routePoints.first];

    for (int index = 1; index <= maximumProgressSegmentIndex; index++) {
      completedPoints.add(routePoints[index]);
    }

    if (completedPoints.last != progressPoint) {
      completedPoints.add(progressPoint);
    }

    List<LatLng> remainingPoints = [progressPoint];

    for (
      int index = maximumProgressSegmentIndex + 1;
      index < routePoints.length;
      index++ ) {
      remainingPoints.add(routePoints[index]);
    }

    routeProgress = RouteProgressModel(
      travelledDistanceMeters: travelledDistance,
      remainingDistanceMeters: remainingDistance,
      totalDistanceMeters: totalDistanceMeters,
      distanceFromRouteMeters: nearestDistance,
      snappedLocation: progressPoint,
      completedRoutePoints: completedPoints,
      remainingRoutePoints: remainingPoints,
    );

    notifyListeners();
  }

  // Project GPS location onto a route segment.
  Map<String, dynamic> projectPointOntoSegment(LatLng position, LatLng start, LatLng end) {
    const double earthRadius = 6371000;

    double referenceLatitude = position.latitude * math.pi / 180;

    double startX = (start.longitude - position.longitude) *
        math.pi /
        180 *
        earthRadius *
        math.cos(referenceLatitude);

    double startY = (start.latitude - position.latitude) * math.pi / 180 * earthRadius;

    double endX = (end.longitude - position.longitude) *
        math.pi /
        180 *
        earthRadius *
        math.cos(referenceLatitude);

    double endY = (end.latitude - position.latitude) * math.pi / 180 * earthRadius;

    double segmentX = endX - startX;
    double segmentY = endY - startY;

    double segmentLengthSquared = segmentX * segmentX + segmentY * segmentY;

    double fraction = 0;

    if (segmentLengthSquared > 0) {
      fraction = (-(startX * segmentX + startY * segmentY) / segmentLengthSquared)
              .clamp(0.0, 1.0);
    }

    double projectedX = startX + fraction * segmentX;
    double projectedY = startY + fraction * segmentY;

    double distance = math.sqrt(projectedX * projectedX + projectedY * projectedY);

    LatLng projectedPoint = LatLng(
      start.latitude + (end.latitude - start.latitude) * fraction,
      start.longitude + (end.longitude - start.longitude) * fraction,
    );

    return {
      'point': projectedPoint,
      'fraction': fraction,
      'distance': distance,
    };
  }

  // Calculate distance between two geographical coordinates.
  double calculateDistance(LatLng first, LatLng second) {
    const double earthRadius = 6371000;

    double latitudeDifference = (second.latitude - first.latitude) * math.pi / 180;

    double longitudeDifference = (second.longitude - first.longitude) * math.pi / 180;

    double firstLatitude = first.latitude * math.pi / 180;

    double secondLatitude = second.latitude * math.pi / 180;

    double value = math.sin(latitudeDifference / 2) * math.sin(latitudeDifference / 2) +
        math.cos(firstLatitude) *
            math.cos(secondLatitude) *
            math.sin(longitudeDifference / 2) *
            math.sin(longitudeDifference / 2);

    double angularDistance = 2 * math.atan2(math.sqrt(value), math.sqrt(1 - value));

    return earthRadius * angularDistance;
  }

  bool checkDestinationArrival({required LocationModel location, required LatLng destination}) {
    if (hasReachedDestination) {
      return true;
    }

    if (!location.accuracy.isFinite || location.accuracy <= 0 ||
        location.accuracy > arrivalGpsAccuracyMeters) {
      consecutiveDestinationReadings = 0;
      return false;
    }

    LatLng currentPosition = LatLng(location.latitude, location.longitude);

    double distanceFromDestination = calculateDistance(currentPosition, destination);

    if (distanceFromDestination <= destinationRadiusMeters) {
      consecutiveDestinationReadings++;
    } else {
      consecutiveDestinationReadings = 0;
    }

    if (consecutiveDestinationReadings >= requiredArrivalReadings) {
      hasReachedDestination = true;
    }

    return hasReachedDestination;
  }
}

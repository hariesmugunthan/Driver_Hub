import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../controllers/location_controller.dart';
import '../controllers/trip_navigation_controller.dart';
import '../models/location_model.dart';
import '../models/route_progress_model.dart';
import '../models/trip_model.dart';
import '../services/route_service.dart';
import '../services/trip_service.dart';
import '../services/vehicle_marker_service.dart';
import '../widgets/trip_route/trip_route_map.dart';
import '../widgets/trip_route/trip_start_button.dart';

class TripRouteScreen extends StatefulWidget {
  final TripModel trip;

  const TripRouteScreen({super.key, required this.trip});

  @override
  State<TripRouteScreen> createState() => _TripRouteScreenState();
}

class _TripRouteScreenState extends State<TripRouteScreen> {
  final RouteService routeService = RouteService();
  final TripService tripService = TripService();

  final LocationController locationController = LocationController();

  final TripNavigationController navigationController = TripNavigationController();

  final VehicleMarkerService vehicleMarkerService = VehicleMarkerService();

  GoogleMapController? mapController;

  bool isLoading = true;
  String? errorMessage;

  bool isStartingTrip = false;
  bool isTripStarted = false;
  bool isCompletingTrip = false;
  bool isTripCompleted = false;
  bool hasCompletionRequestFailed = false;

  Set<Marker> markers = {};
  Set<Polyline> polylines = {};

  List<LatLng> routePoints = [];

  BitmapDescriptor vehicleMarker = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);

  String distance = '';
  String duration = '';

  DateTime? lastFollowedLocationTimestamp;

  @override
  void initState() {
    super.initState();

    // Restore the existing backend trip state.
    String tripStatus = widget.trip.status;

    isTripStarted = tripStatus == 'inProgress';
    isTripCompleted = tripStatus == 'completed';

    locationController.addListener(handleLocationUpdate);

    initializeVehicleMarker();
    calculateRoute();
  }

  @override
  void dispose() {
    locationController.removeListener(handleLocationUpdate);

    locationController.dispose();
    navigationController.dispose();

    mapController?.dispose();

    super.dispose();
  }

  // Generate the custom vehicle marker.
  Future<void> initializeVehicleMarker() async {
    try {
      BitmapDescriptor generatedMarker = await vehicleMarkerService
          .createVehicleMarker();

      if (!mounted) return;

      setState(() {
        vehicleMarker = generatedMarker;
      });

      LocationModel? location = locationController.currentLocation;

      if (location != null) {
        handleLocationUpdate();
      }
    } catch (error) {
      debugPrint('Vehicle marker generation failed: $error');
    }
  }

  // Fetch and initialize the planned route.
  Future<void> calculateRoute() async {
    try {
      Map<String, dynamic> routeData = await routeService.computeRoute(
        startLatitude: widget.trip.startLatitude,
        startLongitude: widget.trip.startLongitude,
        endLatitude: widget.trip.endLatitude,
        endLongitude: widget.trip.endLongitude,
      );

      String encodedPolyline = routeData['encodedPolyline'] as String;

      int distanceMeters = (routeData['distanceMeters'] as num).toInt();

      String durationValue = routeData['duration'] as String;

      List<LatLng> decodedPoints = decodePolyline(encodedPolyline);

      if (decodedPoints.isEmpty) {
        throw Exception('No route points received.');
      }

      if (!mounted) return;

      navigationController.initializeRoute(
        points: decodedPoints,
        totalDistance: distanceMeters.toDouble(),
      );

      setState(() {
        routePoints = decodedPoints;

        markers = {
          Marker(
            markerId: const MarkerId('start'),
            position: LatLng(widget.trip.startLatitude, widget.trip.startLongitude),
            infoWindow: InfoWindow(title: 'Starting Point', snippet: widget.trip.startLocation),
          ),
          Marker(
            markerId: const MarkerId('destination'),
            position: LatLng(widget.trip.endLatitude, widget.trip.endLongitude),
            infoWindow: InfoWindow(title: 'Destination', snippet: widget.trip.endLocation),
          ),
        };

        polylines = {
          Polyline(
            polylineId: const PolylineId('planned_route'),
            points: routePoints,
            color: Colors.blue,
            width: 5,
          ),
        };

        distance = formatDistance(distanceMeters);
        duration = formatDuration(durationValue);

        isLoading = false;
      });

      await fitRouteOnMap();

      // Automatically resume GPS for an already-started trip.
      if (isTripStarted && mounted) {
        await startTripTracking();
      }
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = error.toString();
      });

      debugPrint('Route calculation failed: $error');
    }
  }

  // Start a scheduled trip or resume GPS for an existing trip.
  Future<void> startTripTracking() async {
    if (isStartingTrip || isTripCompleted || locationController.isTracking) {
      return;
    }

    setState(() {
      isStartingTrip = true;
    });

    try {
      // Only scheduled trips need the backend start request.
      if (!isTripStarted) {
        await tripService.startTrip(tripId: widget.trip.tripId, driverId: widget.trip.driverId);

        if (!mounted) return;

        // Preserve the started state if GPS initialization fails.
        // Retrying GPS must not call /trip/start again.
        isTripStarted = true;
      }

      // Start or resume foreground GPS tracking.
      await locationController.startTracking();

      if (!mounted) return;

      if (locationController.errorMessage != null) {
        throw Exception(locationController.errorMessage);
      }

      LocationModel? location = locationController.currentLocation;

      if (location != null) {
        handleLocationUpdate();
        moveCameraToLocation(location);
      }
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() {
          isStartingTrip = false;
        });
      }
    }
  }

  // Handle every new GPS location.
  void handleLocationUpdate() {
    if (!mounted) return;

    LocationModel? location = locationController.currentLocation;

    if (location == null) return;

    if (lastFollowedLocationTimestamp == location.timestamp) {
      return;
    }

    lastFollowedLocationTimestamp = location.timestamp;

    LatLng currentPosition = LatLng(location.latitude, location.longitude);

    // Update navigation progress.
    navigationController.updateLocation(location);

    // Check destination arrival only after the backend trip starts.
    if (isTripStarted &&
        !isTripCompleted &&
        !isCompletingTrip &&
        !hasCompletionRequestFailed) {
      bool hasArrived = navigationController.checkDestinationArrival(
        location: location,
        destination: LatLng(widget.trip.endLatitude, widget.trip.endLongitude),
      );

      if (hasArrived) {
        unawaited(completeTrip());
      }
    }

    RouteProgressModel? progress = navigationController.routeProgress;

    Set<Polyline> updatedPolylines = {};

    if (progress != null) {
      // Completed route.
      if (progress.completedRoutePoints.length >= 2) {
        updatedPolylines.add(
          Polyline(
            polylineId: const PolylineId('completed_route'),
            points: progress.completedRoutePoints,
            color: Colors.grey,
            width: 6,
          ),
        );
      }

      // Remaining route.
      if (progress.remainingRoutePoints.length >= 2) {
        updatedPolylines.add(
          Polyline(
            polylineId: const PolylineId('remaining_route'),
            points: progress.remainingRoutePoints,
            color: Colors.blue,
            width: 6,
          ),
        );
      }
    } else {
      // Preserve the original route until progress is available.
      updatedPolylines.add(
        Polyline(
          polylineId: const PolylineId('planned_route'),
          points: routePoints,
          color: Colors.blue,
          width: 5,
        ),
      );
    }

    setState(() {
      polylines = updatedPolylines;

      markers = {
        ...markers.where((marker) => marker.markerId.value != 'current_location'),
        Marker(
          markerId: const MarkerId('current_location'),
          position: currentPosition,
          icon: vehicleMarker,
          rotation: location.heading,
          anchor: const Offset(0.5, 0.5),
          flat: true,
          infoWindow: const InfoWindow(title: 'Current Vehicle Location'),
        ),
      };
    });

    moveCameraToLocation(location);
  }

  // Complete the backend trip after destination arrival is confirmed.
  Future<void> completeTrip() async {
    if (isCompletingTrip || isTripCompleted || !isTripStarted) {
      return;
    }

    setState(() {
      isCompletingTrip = true;
      hasCompletionRequestFailed = false;
    });

    try {
      await tripService.endTrip(
        tripId: widget.trip.tripId,
        driverId: widget.trip.driverId,
        totalDistanceMeters: navigationController.totalDistanceMeters,
      );

      await locationController.stopTracking();

      if (!mounted) return;

      setState(() {
        isTripCompleted = true;
        isTripStarted = false;
        hasCompletionRequestFailed = false;
      });

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
            title: const Text('Trip Completed'),
            content: const Text('You have successfully reached your destination.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        hasCompletionRequestFailed = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to complete trip: '
            '${error.toString().replaceFirst('Exception: ', '')}',
          ),
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isCompletingTrip = false;
        });
      }
    }
  }

  // Retry trip completion if the backend request failed.
  Future<void> retryTripCompletion() async {
    if (!navigationController.hasReachedDestination) {
      return;
    }

    await completeTrip();
  }

  // Follow vehicle position and heading.
  Future<void> moveCameraToLocation(LocationModel location) async {
    if (mapController == null) return;

    try {
      await mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(location.latitude, location.longitude),
            zoom: 18,
            tilt: 45,
            bearing: location.heading,
          ),
        ),
      );
    } catch (error) {
      debugPrint('Camera movement failed: $error');
    }
  }

  // Decode Google encoded polyline.
  List<LatLng> decodePolyline(String encoded) {
    List<LatLng> points = [];

    int index = 0;
    int latitude = 0;
    int longitude = 0;

    while (index < encoded.length) {
      int shift = 0;
      int result = 0;
      int byte;

      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1f) << shift;
        shift += 5;
      } while (byte >= 0x20);

      int latitudeChange = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

      latitude += latitudeChange;

      shift = 0;
      result = 0;

      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1f) << shift;
        shift += 5;
      } while (byte >= 0x20);

      int longitudeChange = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

      longitude += longitudeChange;

      points.add(LatLng(latitude / 1e5, longitude / 1e5));
    }

    return points;
  }

  String formatDistance(int distanceMeters) {
    double distanceKm = distanceMeters / 1000;

    return '${distanceKm.toStringAsFixed(1)} km';
  }

  String formatMetricDistance(double distanceMeters) {
    if (distanceMeters >= 1000) {
      return '${(distanceMeters / 1000).toStringAsFixed(1)} km';
    }

    return '${distanceMeters.toStringAsFixed(0)} m';
  }

  String formatDuration(String durationValue) {
    int seconds = int.parse(durationValue.replaceAll('s', ''));

    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;

    if (hours > 0) {
      return '$hours hr $minutes min';
    }

    return '$minutes min';
  }

  // Fit complete route inside the map.
  Future<void> fitRouteOnMap() async {
    if (mapController == null || routePoints.isEmpty) {
      return;
    }

    if (routePoints.length == 1) {
      await mapController!.animateCamera(CameraUpdate.newLatLngZoom(routePoints.first, 15));

      return;
    }

    double minLatitude = routePoints.first.latitude;
    double maxLatitude = routePoints.first.latitude;

    double minLongitude = routePoints.first.longitude;
    double maxLongitude = routePoints.first.longitude;

    for (LatLng point in routePoints) {
      if (point.latitude < minLatitude) {
        minLatitude = point.latitude;
      }

      if (point.latitude > maxLatitude) {
        maxLatitude = point.latitude;
      }

      if (point.longitude < minLongitude) {
        minLongitude = point.longitude;
      }

      if (point.longitude > maxLongitude) {
        maxLongitude = point.longitude;
      }
    }

    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(minLatitude, minLongitude),
      northeast: LatLng(maxLatitude, maxLongitude),
    );

    await mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 60));
  }

  void handleMapCreated(GoogleMapController controller) {
    mapController = controller;

    LocationModel? location = locationController.currentLocation;

    if (locationController.isTracking && location != null) {
      moveCameraToLocation(location);
    } else if (routePoints.isNotEmpty) {
      fitRouteOnMap();
    }
  }

  Widget buildMap() {
    return TripRouteMap(
      initialPosition: LatLng(widget.trip.startLatitude, widget.trip.startLongitude),
      markers: markers,
      polylines: polylines,
      onMapCreated: handleMapCreated,
    );
  }

  Widget buildLoadingOverlay() {
    return Container(
      color: Colors.white70,
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trip Navigation')),
      body: Stack(
        children: [
          buildMap(),
          if (isLoading) buildLoadingOverlay(),
          if (errorMessage != null) buildErrorView(),
          if (!isLoading && errorMessage == null) buildTripInformation(),
        ],
      ),
    );
  }

  Widget buildErrorView() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 40),
            const SizedBox(height: 12),
            const Text(
              'Unable to calculate route',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isLoading = true;
                  errorMessage = null;
                });

                calculateRoute();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // Navigation information panel.
  Widget buildTripInformation() {
    LocationModel? location = locationController.currentLocation;

    RouteProgressModel? progress = navigationController.routeProgress;

    bool isTracking = locationController.isTracking;

    double speed = location?.speedInKmh ?? 0;

    if (speed < 0 || !speed.isFinite) {
      speed = 0;
    }

    return Positioned(
      left: 12,
      right: 12,
      bottom: 12,
      child: Card(
        color: const Color(0xFF000080),
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isTripCompleted) ...[
                const Center(
                  child: Column(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 36),
                      SizedBox(height: 8),
                      Text(
                        'TRIP COMPLETED',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 24),
              ] else if (isTracking) ...[
                Text(
                  isCompletingTrip ? 'COMPLETING TRIP...' : 'LIVE NAVIGATION',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isCompletingTrip ? Colors.orange : Colors.green,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: buildNavigationValue(
                        icon: Icons.speed,
                        label: 'Speed',
                        value: '${speed.toStringAsFixed(1)} km/h',
                      ),
                    ),
                    Expanded(
                      child: buildNavigationValue(
                        icon: Icons.route,
                        label: 'Travelled',
                        value: progress == null
                            ? '--'
                            : formatMetricDistance(progress.travelledDistanceMeters),
                      ),
                    ),
                    Expanded(
                      child: buildNavigationValue(
                        icon: Icons.flag,
                        label: 'Remaining',
                        value: progress == null
                            ? '--'
                            : formatMetricDistance(progress.remainingDistanceMeters),
                      ),
                    ),
                  ],
                ),
                if (hasCompletionRequestFailed) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'Destination reached, but trip completion '
                    'could not be saved.',
                    style: TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isCompletingTrip ? null : retryTripCompletion,
                      child: const Text('Retry Completion'),
                    ),
                  ),
                ],
                const Divider(height: 24),
              ] else ...[
                const Text(
                  'PLANNED TRIP ROUTE',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.route, color: Colors.blue),
                    const SizedBox(width: 10),
                    Text('Distance: $distance'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.access_time, color: Colors.orange),
                    const SizedBox(width: 10),
                    Text('Estimated Duration: $duration'),
                  ],
                ),
                const Divider(height: 24),
              ],
              Text(
                'From: ${widget.trip.startLocation}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text('To: ${widget.trip.endLocation}', maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 14),
              if (!isTripCompleted) ...[
                if (isTripStarted && !locationController.isTracking) ...[
                  const Text(
                    'This trip is already in progress. Start GPS tracking '
                    'to continue navigation.',
                    style: TextStyle(color: Colors.orange),
                  ),
                  const SizedBox(height: 8),
                ],
                TripStartButton(
                  onPressed: startTripTracking,
                  isLoading: isStartingTrip || locationController.isLoading,
                  isTracking: locationController.isTracking,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget buildNavigationValue({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue, size: 24),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        FittedBox(
          child: Text(
            value,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

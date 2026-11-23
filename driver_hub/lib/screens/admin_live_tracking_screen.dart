import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../configs/app_theme.dart';
import '../controllers/admin_tracking_controller.dart';
import '../controllers/trip_navigation_controller.dart';
import '../models/admin_location_model.dart';
import '../models/location_model.dart';
import '../models/route_progress_model.dart';
import '../models/trip_model.dart';
import '../services/trip_service.dart';
import '../services/vehicle_marker_service.dart';
import '../widgets/trip_route/trip_route_map.dart';

class AdminLiveTrackingScreen extends StatefulWidget {
  final TripModel trip;

  const AdminLiveTrackingScreen({super.key, required this.trip});

  @override
  State<AdminLiveTrackingScreen> createState() => _AdminLiveTrackingScreenState();
}

class _AdminLiveTrackingScreenState extends State<AdminLiveTrackingScreen> {
  final TripService tripService = TripService();

  bool isTripCompleted = false;
  bool isCompletingTrip = false;
  bool hasCompletionRequestFailed = false;
  bool isCheckingTripStatus = false;

  final AdminTrackingController trackingController = AdminTrackingController();

  final TripNavigationController navigationController = TripNavigationController();

  Timer? elapsedTimeTimer;
  Timer? tripStatusPollingTimer;

  DateTime? actualEndTime;

  final VehicleMarkerService vehicleMarkerService = VehicleMarkerService();

  GoogleMapController? mapController;

  BitmapDescriptor vehicleMarker = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);

  List<LatLng> routePoints = [];

  Set<Marker> markers = {};
  Set<Polyline> polylines = {};

  bool isRouteReady = false;

  String? lastLocationKey;

  @override
  void initState() {
    super.initState();

    trackingController.addListener(handleTrackingUpdate);

    isTripCompleted = widget.trip.status.toLowerCase() == 'completed';

    actualEndTime = widget.trip.actualEndTime;

    if (isTripCompleted) {
      actualEndTime ??= DateTime.now();
    } else {
      startElapsedTimeTimer();
      startTripStatusPolling();
    }

    initializeTrackingScreen();
  }

  // Start the travelled-time timer.
  void startElapsedTimeTimer() {
    elapsedTimeTimer?.cancel();

    if (isTripCompleted) {
      return;
    }

    elapsedTimeTimer = Timer.periodic(
      const Duration(seconds: 1),
          (timer) {
        if (mounted && !isTripCompleted) {
          setState(() {});
        }
      },
    );
  }

  // Check the latest trip status every 5 seconds.
  void startTripStatusPolling() {
    tripStatusPollingTimer?.cancel();

    // Check immediately when tracking screen opens.
    refreshTripStatus();

    tripStatusPollingTimer = Timer.periodic(
      const Duration(seconds: 5),
          (timer) {
        refreshTripStatus();
      },
    );
  }

  // Fetch the latest trip details from the backend.
  Future<void> refreshTripStatus() async {
    if (isTripCompleted || isCheckingTripStatus) {
      return;
    }

    isCheckingTripStatus = true;

    try {
      TripModel latestTrip = await tripService.getTripById(widget.trip.tripId);

      if (!mounted) return;

      if (latestTrip.status.toLowerCase() == 'completed') {
        completeTrackingFromBackend(latestTrip);
      }
    } catch (error) {
      debugPrint('Trip status refresh failed: $error');
    } finally {
      isCheckingTripStatus = false;
    }
  }

  // Stop all timers and location polling after completion.
  void stopTrackingTimers() {
    elapsedTimeTimer?.cancel();
    elapsedTimeTimer = null;

    tripStatusPollingTimer?.cancel();
    tripStatusPollingTimer = null;

    trackingController.stopLocationPolling();
  }

  // Handle completion initiated from the Driver app.
  void completeTrackingFromBackend(TripModel completedTrip) {
    if (isTripCompleted || !mounted) {
      return;
    }

    setState(() {
      isTripCompleted = true;

      actualEndTime = completedTrip.actualEndTime ?? DateTime.now();

      isCompletingTrip = false;
      hasCompletionRequestFailed = false;
    });

    stopTrackingTimers();

    debugPrint('Driver completed the trip.');
  }

  String getTravelledTime() {
    DateTime? startTime = widget.trip.actualStartTime;

    if (startTime == null) {
      return '--';
    }

    DateTime endTime = isTripCompleted
        ? actualEndTime ?? DateTime.now()
        : DateTime.now();

    Duration elapsedTime = endTime.difference(startTime);

    if (elapsedTime.isNegative) {
      elapsedTime = Duration.zero;
    }

    return formatDuration(elapsedTime);
  }

  String getRemainingTime() {
    Map<String, dynamic>? routeData = trackingController.routeData;

    if (routeData == null) {
      return '--';
    }

    // Google Routes API duration, for example: "380s".
    String durationString = routeData['duration']?.toString() ?? '';

    RegExpMatch? match = RegExp(r'[\d.]+').firstMatch(durationString);

    if (match == null) {
      return '--';
    }

    double totalDurationSeconds = double.tryParse(match.group(0)!) ?? 0;

    if (totalDurationSeconds <= 0) {
      return '--';
    }

    RouteProgressModel? progress = navigationController.routeProgress;

    double remainingRatio = 1.0;

    if (progress != null && progress.totalDistanceMeters > 0) {
      remainingRatio =
          progress.remainingDistanceMeters / progress.totalDistanceMeters;
    }

    int remainingSeconds = (totalDurationSeconds * remainingRatio).round();

    return formatDuration(Duration(seconds: remainingSeconds));
  }

  String formatDuration(Duration duration) {
    int hours = duration.inHours;
    int minutes = duration.inMinutes.remainder(60);
    int seconds = duration.inSeconds.remainder(60);

    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> initializeTrackingScreen() async {
    try {
      BitmapDescriptor generatedMarker = await vehicleMarkerService.createVehicleMarker();

      if (!mounted) return;

      vehicleMarker = generatedMarker;

      await trackingController.initializeTracking(widget.trip.tripId);

      if (!mounted) return;

      Map<String, dynamic>? routeData = trackingController.routeData;

      if (routeData == null) {
        setState(() {
          isRouteReady = false;
        });
        return;
      }

      String encodedPolyline = routeData['encodedPolyline'] as String;

      List<LatLng> decodedPoints = decodePolyline(encodedPolyline);

      if (decodedPoints.isEmpty) {
        throw Exception('No route points received.');
      }

      double totalDistance = (routeData['distanceMeters'] as num).toDouble();

      // Reuse the same route-progress algorithm as driver navigation.
      navigationController.initializeRoute(points: decodedPoints, totalDistance: totalDistance);

      setState(() {
        routePoints = decodedPoints;
        isRouteReady = true;

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

        // Initially display the entire route in blue.
        polylines = {
          Polyline(
            polylineId: const PolylineId('planned_route'),
            points: routePoints,
            color: Colors.blue,
            width: 5,
          ),
        };
      });

      // Process the latest location after route initialization.
      AdminLocationModel? location = trackingController.currentLocation;

      if (location != null) {
        updateVehicleMarker(location);
      }

      await fitRouteOnMap();
    } catch (error) {
      debugPrint('Admin tracking initialization failed: $error');
    }
  }

  void handleTrackingUpdate() {
    debugPrint(
      'ADMIN SCREEN LISTENER TRIGGERED: '
          '${trackingController.currentLocation?.latitude}, '
          '${trackingController.currentLocation?.longitude}',
    );
    if (!mounted) return;

    AdminLocationModel? location = trackingController.currentLocation;

    if (location != null) {
      updateVehicleMarker(location);
    }

    setState(() {});
  }

  void updateVehicleMarker(AdminLocationModel location) {
    LatLng currentPosition = LatLng(location.latitude, location.longitude);

    String locationKey = '${location.latitude}_${location.longitude}_${location.updatedAt}';

    if (lastLocationKey == locationKey) {
      return;
    }

    lastLocationKey = locationKey;

    // Convert the admin API location into the driver's existing location model.
    LocationModel navigationLocation = LocationModel(
      latitude: location.latitude,
      longitude: location.longitude,
      speed: location.speed,
      accuracy: location.accuracy,
      heading: location.heading,
      timestamp: location.updatedAt ?? DateTime.now(),
    );

    navigationController.updateLocation(navigationLocation);

    // Update completed and remaining route sections.
    updateRoutePolylines();

    // Check whether the simulated vehicle has reached its destination.
    if (!isTripCompleted &&
        !isCompletingTrip &&
        !hasCompletionRequestFailed) {
      bool hasArrived = navigationController.checkDestinationArrival(
        location: navigationLocation,
        destination: LatLng(widget.trip.endLatitude, widget.trip.endLongitude),
      );

      if (hasArrived) {
        unawaited(completeAdminTrip());
      }
    }

    setState(() {
      markers = {
        ...markers.where((marker) => marker.markerId.value != 'current_vehicle'),
        Marker(
          markerId: const MarkerId('current_vehicle'),
          position: currentPosition,
          icon: vehicleMarker,
          rotation: location.heading,
          anchor: const Offset(0.5, 0.5),
          flat: true,
          infoWindow: InfoWindow(
            title: 'Live Vehicle Location',
            snippet: widget.trip.vehicle?.registrationNumber ?? '',
          ),
        ),
      };
    });

    moveCameraToLocation(currentPosition, location.heading);
  }

  // Admin-side trip completion.
  Future<void> completeAdminTrip() async {
    if (isTripCompleted || isCompletingTrip) {
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

      // Retrieve the final completion time from the backend.
      DateTime? finalEndTime;

      try {
        TripModel completedTrip = await tripService.getTripById(widget.trip.tripId);

        finalEndTime = completedTrip.actualEndTime;
      } catch (error) {
        debugPrint('Unable to retrieve final trip details: $error');
      }

      if (!mounted) return;

      setState(() {
        isTripCompleted = true;

        actualEndTime = finalEndTime ?? DateTime.now();

        isCompletingTrip = false;
        hasCompletionRequestFailed = false;
      });

      stopTrackingTimers();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trip completed successfully.')),
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isCompletingTrip = false;
        hasCompletionRequestFailed = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to complete trip: '
                '${error.toString().replaceFirst('Exception: ', '')}',
          ),
        ),
      );
    }
  }

  Future<void> retryAdminTripCompletion() async {
    if (!navigationController.hasReachedDestination) {
      return;
    }

    await completeAdminTrip();
  }

  void updateRoutePolylines() {
    RouteProgressModel? progress = navigationController.routeProgress;

    // If the latest GPS reading is invalid or off-route,
    // retain the existing route visualization.
    if (progress == null) {
      return;
    }

    Set<Polyline> updatedPolylines = {};

    // Completed route: dull grey.
    if (progress.completedRoutePoints.length >= 2) {
      updatedPolylines.add(
        Polyline(
          polylineId: const PolylineId('completed_route'),
          points: progress.completedRoutePoints,
          color: Colors.grey.shade500,
          width: 5,
        ),
      );
    }

    // Remaining route: bright blue.
    if (progress.remainingRoutePoints.length >= 2) {
      updatedPolylines.add(
        Polyline(
          polylineId: const PolylineId('remaining_route'),
          points: progress.remainingRoutePoints,
          color: Colors.blue,
          width: 5,
        ),
      );
    }

    if (updatedPolylines.isNotEmpty && mounted) {
      setState(() {
        polylines = updatedPolylines;
      });
    }
  }

  Future<void> moveCameraToLocation(LatLng position, double heading) async {
    if (mapController == null) return;

    try {
      await mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: position, zoom: 17, tilt: 40, bearing: heading),
        ),
      );
    } catch (error) {
      debugPrint('Admin tracking camera movement failed: $error');
    }
  }

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

      int latitudeChange = (result & 1) != 0
          ? ~(result >> 1)
          : (result >> 1);

      latitude += latitudeChange;

      shift = 0;
      result = 0;

      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1f) << shift;
        shift += 5;
      } while (byte >= 0x20);

      int longitudeChange = (result & 1) != 0
          ? ~(result >> 1)
          : (result >> 1);

      longitude += longitudeChange;

      points.add(LatLng(latitude / 1e5, longitude / 1e5));
    }

    return points;
  }

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

    if (routePoints.isNotEmpty) {
      fitRouteOnMap();
    }

    AdminLocationModel? location = trackingController.currentLocation;

    if (location != null) {
      moveCameraToLocation(LatLng(location.latitude, location.longitude), location.heading);
    }
  }

  String formatSpeed(double speed) {
    if (!speed.isFinite || speed < 0) {
      return '0.0 km/h';
    }

    return '${speed.toStringAsFixed(1)} km/h';
  }

  @override
  void dispose() {
    // Stop all timers.
    elapsedTimeTimer?.cancel();
    tripStatusPollingTimer?.cancel();

    trackingController.removeListener(handleTrackingUpdate);
    trackingController.dispose();

    navigationController.dispose();

    mapController?.dispose();

    super.dispose();
  }

  Widget buildMap() {
    return TripRouteMap(
      initialPosition: LatLng(widget.trip.startLatitude, widget.trip.startLongitude),
      markers: markers,
      polylines: polylines,
      onMapCreated: handleMapCreated,
    );
  }

  Widget buildLoadingView() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget buildErrorMessage() {
    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Card(
        color: AppColors.surface,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            trackingController.errorMessage!,
            style: const TextStyle(color: AppColors.error),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Tracking'),
      ),
      body: Stack(
        children: [
          if (isRouteReady) buildMap(),
          if (!isRouteReady) buildLoadingView(),
          if (trackingController.errorMessage != null)
            buildErrorMessage(),
          if (isRouteReady) buildTrackingInformation(),
        ],
      ),
    );
  }

  Widget buildTrackingInformation() {
    AdminLocationModel? location = trackingController.currentLocation;

    String vehicleNumber = widget.trip.vehicle?.registrationNumber ?? 'Not available';

    RouteProgressModel? progress = navigationController.routeProgress;

    return Positioned(
      left: 12,
      right: 12,
      bottom: 12,
      child: Card(
        color: AppColors.surface,
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tracking status.
              Row(
                children: [
                  Icon(Icons.circle, color: Colors.green, size: 12),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isTripCompleted
                          ? 'TRIP COMPLETED'
                          : isCompletingTrip
                          ? 'COMPLETING TRIP...'
                          : 'LIVE VEHICLE TRACKING',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                        color: isTripCompleted
                            ? Colors.green
                            : null,
                      ),
                    ),
                  ),
                  if (trackingController.isLocationLoading &&
                      !isTripCompleted)
                    const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                ],
              ),
              // Completion request failed.
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
                    onPressed: isCompletingTrip
                        ? null
                        : retryAdminTripCompletion,
                    child: const Text('Retry Completion'),
                  ),
                ),
              ],
              // Completion in progress.
              if (isCompletingTrip) ...[
                const SizedBox(height: 12),
                const LinearProgressIndicator(),
              ],
              // Successful completion.
              if (isTripCompleted) ...[
                const SizedBox(height: 12),
                const Center(
                  child: Text(
                    'DESTINATION REACHED',
                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
              const Divider(height: 24),
              // Driver and vehicle information.
              Row(
                children: [
                  Expanded(
                    child: buildInformationItem(
                      Icons.person_outline,
                      'Driver',
                      widget.trip.driverName,
                    ),
                  ),
                  Expanded(
                    child: buildInformationItem(
                      Icons.directions_car_outlined,
                      'Vehicle',
                      vehicleNumber,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Current speed and GPS accuracy.
              Row(
                children: [
                  Expanded(
                    child: buildInformationItem(
                      Icons.speed,
                      'Current Speed',
                      location == null
                          ? '--'
                          : formatSpeed(location.speedInKmh),
                    ),
                  ),
                  Expanded(
                    child: buildInformationItem(
                      Icons.gps_fixed,
                      'GPS Accuracy',
                      location == null
                          ? '--'
                          : '${location.accuracy.toStringAsFixed(1)} m',
                    ),
                  ),
                ],
              ),
              // Route progress.
              if (progress != null) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: buildInformationItem(
                        Icons.route,
                        'Travelled',
                        '${(progress.travelledDistanceMeters / 1000).toStringAsFixed(2)} km',
                      ),
                    ),
                    Expanded(
                      child: buildInformationItem(
                        Icons.flag_outlined,
                        'Remaining',
                        '${(progress.remainingDistanceMeters / 1000).toStringAsFixed(2)} km',
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              // Trip duration information.
              Row(
                children: [
                  Expanded(
                    child: buildInformationItem(
                      Icons.timer_outlined,
                      'Travelled Time',
                      getTravelledTime(),
                    ),
                  ),
                  Expanded(
                    child: buildInformationItem(
                      Icons.hourglass_bottom,
                      'Remaining Time',
                      getRemainingTime(),
                    ),
                  ),
                ],
              ),
              // Waiting for the first location.
              if (location == null && !isTripCompleted) ...[
                const SizedBox(height: 12),
                const Text(
                  'Waiting for vehicle location...',
                  style: TextStyle(color: AppColors.secondaryText),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget buildInformationItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 22),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: AppColors.secondaryText)),
              const SizedBox(height: 4),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';

import '../configs/app_theme.dart';
import '../controllers/trip_controller.dart';
import '../models/trip_model.dart';

class DriverTripHistoryScreen extends StatefulWidget {
  final String driverId;
  final String driverName;

  const DriverTripHistoryScreen({super.key, required this.driverId, required this.driverName});

  @override
  State<DriverTripHistoryScreen> createState() => _DriverTripHistoryScreenState();
}

class _DriverTripHistoryScreenState extends State<DriverTripHistoryScreen> {
  final TripController tripController = TripController();

  List<TripModel> completedTrips = [];

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadTripHistory();
  }

  Future<void> loadTripHistory() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      List<TripModel> trips = await tripController.getTripsByDriverId(widget.driverId);

      if (!mounted) {
        return;
      }

      setState(() {
        completedTrips = trips.where((trip) => trip.status.toLowerCase() == 'completed').toList();

        isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        errorMessage = error.toString().replaceFirst('Exception: ', '');
        isLoading = false;
      });
    }
  }

  String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) {
      return 'Not available';
    }

    final DateTime localTime = dateTime.toLocal();

    String day = localTime.day.toString().padLeft(2, '0');
    String month = localTime.month.toString().padLeft(2, '0');
    String year = localTime.year.toString();

    String hour = localTime.hour.toString().padLeft(2, '0');
    String minute = localTime.minute.toString().padLeft(2, '0');

    return '$day/$month/$year  $hour:$minute';
  }

  String formatDuration(TripModel trip) {
    if (trip.actualStartTime == null || trip.actualEndTime == null) {
      return 'Not available';
    }

    Duration duration = trip.actualEndTime!.difference(trip.actualStartTime!);

    if (duration.isNegative) {
      return 'Not available';
    }

    int hours = duration.inHours;
    int minutes = duration.inMinutes % 60;

    if (hours == 0) {
      return '$minutes min';
    }

    if (minutes == 0) {
      return '$hours hr';
    }

    return '$hours hr $minutes min';
  }

  Widget buildDetailRow({required IconData icon, required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 19, color: AppColors.secondaryText),
          const SizedBox(width: 12),
          SizedBox(
            width: 105,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: AppColors.secondaryText),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.primaryText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTripCard(TripModel trip, int index) {
    return Card(
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Trip ${index + 1}',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryText,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Completed',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF34D399),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(trip.tripId, style: const TextStyle(fontSize: 12, color: AppColors.secondaryText)),
            const Divider(height: 24),
            buildDetailRow(
              icon: Icons.location_on_outlined,
              label: 'Start',
              value: trip.startLocation,
            ),
            buildDetailRow(
              icon: Icons.flag_outlined,
              label: 'Destination',
              value: trip.endLocation,
            ),
            buildDetailRow(
              icon: Icons.directions_car_outlined,
              label: 'Vehicle',
              value: trip.vehicle?.registrationNumber.isNotEmpty == true
                  ? trip.vehicle!.registrationNumber
                  : trip.vehicleId,
            ),
            const Divider(height: 24),
            buildDetailRow(
              icon: Icons.play_circle_outline,
              label: 'Started',
              value: formatDateTime(trip.actualStartTime),
            ),
            buildDetailRow(
              icon: Icons.check_circle_outline,
              label: 'Completed',
              value: formatDateTime(trip.actualEndTime),
            ),
            buildDetailRow(icon: Icons.access_time, label: 'Duration', value: formatDuration(trip)),
          ],
        ),
      ),
    );
  }

  Widget buildLoading() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 48),
            const SizedBox(height: 16),
            Text(
              errorMessage ?? 'Unable to load trip history',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.primaryText),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: loadTripHistory,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildEmptyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.history, size: 55, color: AppColors.secondaryText),
            const SizedBox(height: 16),
            const Text(
              'No Completed Trips',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'This driver has no completed trips yet.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.secondaryText),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildContent() {
    if (isLoading) {
      return buildLoading();
    }

    if (errorMessage != null) {
      return buildError();
    }

    if (completedTrips.isEmpty) {
      return buildEmptyView();
    }

    return RefreshIndicator(
      onRefresh: loadTripHistory,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '${completedTrips.length} completed trips',
            style: const TextStyle(fontSize: 15, color: AppColors.secondaryText),
          ),
          const SizedBox(height: 16),
          ...completedTrips.asMap().entries.map((entry) => buildTripCard(entry.value, entry.key)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip History'),
      ),
      body: buildContent(),
    );
  }
}
import 'package:flutter/material.dart';

import '../configs/app_theme.dart';
import '../models/trip_model.dart';

class TripStatsScreen extends StatelessWidget {
  final TripModel trip;

  const TripStatsScreen({super.key, required this.trip});

  String get formattedDistance {
    if (trip.totalDistanceMeters == null) {
      return 'Not available';
    }

    double distance = trip.totalDistanceMeters!;

    if (distance >= 1000) {
      return '${(distance / 1000).toStringAsFixed(2)} km';
    }

    return '${distance.toStringAsFixed(0)} m';
  }

  String get formattedDuration {
    if (trip.actualStartTime == null || trip.actualEndTime == null) {
      return 'Not available';
    }

    Duration duration = trip.actualEndTime!.difference(trip.actualStartTime!);

    if (duration.isNegative) {
      return 'Not available';
    }

    int hours = duration.inHours;
    int minutes = duration.inMinutes.remainder(60);
    int seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours hr $minutes min';
    }

    if (minutes > 0) {
      return '$minutes min $seconds sec';
    }

    return '$seconds sec';
  }

  String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) {
      return 'Not available';
    }

    DateTime localDateTime = dateTime.toLocal();

    String day = localDateTime.day.toString().padLeft(2, '0');
    String month = localDateTime.month.toString().padLeft(2, '0');
    String year = localDateTime.year.toString();

    int hour = localDateTime.hour;
    String period = hour >= 12 ? 'PM' : 'AM';

    hour = hour % 12;
    hour = hour == 0 ? 12 : hour;

    String minute = localDateTime.minute.toString().padLeft(2, '0');

    return '$day/$month/$year • $hour:$minute $period';
  }

  Color get statusColor {
    switch (trip.status.toLowerCase()) {
      case 'completed':
        return AppColors.success;
      case 'cancelled':
        return AppColors.secondaryText;
      default:
        return AppColors.warning;
    }
  }

  Widget buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryText,
        ),
      ),
    );
  }

  Widget buildInfoRow({required IconData icon, required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: AppColors.secondary),
          const SizedBox(width: 14),
          SizedBox(
            width: 105,
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, color: AppColors.secondaryText),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.primaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInfoCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget buildDistanceAndDuration() {
    return Row(
      children: [
        Expanded(
          child: buildInfoCard([
            const Icon(Icons.route, color: AppColors.accent, size: 28),
            const SizedBox(height: 12),
            Text(
              formattedDistance,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 4),
            const Text('Distance', style: TextStyle(fontSize: 13, color: AppColors.secondaryText)),
          ]),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: buildInfoCard([
            const Icon(Icons.timer_outlined, color: AppColors.accent, size: 28),
            const SizedBox(height: 12),
            Text(
              formattedDuration,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 4),
            const Text('Duration', style: TextStyle(fontSize: 13, color: AppColors.secondaryText)),
          ]),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isCompleted = trip.status.toLowerCase() == 'completed';

    String vehicleDetails = trip.vehicle != null
        ? '${trip.vehicle!.brand} ${trip.vehicle!.model}'
        : 'Not available';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Stats'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildInfoCard([
              Row(
                children: [
                  const Icon(Icons.analytics_outlined, color: AppColors.secondary, size: 28),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Trip Overview',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryText,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      trip.status.replaceAll('_', ' ').toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              buildInfoRow(icon: Icons.tag, label: 'Trip ID', value: trip.tripId),
            ]),
            const SizedBox(height: 24),
            if (isCompleted) ...[
              buildSectionTitle('Trip Performance'),
              buildDistanceAndDuration(),
              const SizedBox(height: 24),
            ],
            buildSectionTitle('Route Details'),
            buildInfoCard([
              buildInfoRow(icon: Icons.trip_origin, label: 'Start', value: trip.startLocation),
              const Divider(),
              buildInfoRow(icon: Icons.location_on, label: 'Destination', value: trip.endLocation),
            ]),
            const SizedBox(height: 24),
            buildSectionTitle('Driver Details'),
            buildInfoCard([
              buildInfoRow(icon: Icons.person_outline, label: 'Driver', value: trip.driverName),
              const Divider(),
              buildInfoRow(icon: Icons.badge_outlined, label: 'Driver ID', value: trip.driverId),
            ]),
            const SizedBox(height: 24),
            buildSectionTitle('Vehicle Details'),
            buildInfoCard([
              buildInfoRow(
                icon: Icons.directions_car_outlined,
                label: 'Vehicle',
                value: vehicleDetails,
              ),
              const Divider(),
              buildInfoRow(
                icon: Icons.confirmation_number_outlined,
                label: 'Registration',
                value: trip.vehicle?.registrationNumber ??
                    'Not available',
              ),
              const Divider(),
              buildInfoRow(icon: Icons.badge_outlined, label: 'Vehicle ID', value: trip.vehicleId),
            ]),
            const SizedBox(height: 24),
            buildSectionTitle('Trip Timing'),
            buildInfoCard([
              buildInfoRow(
                icon: Icons.play_circle_outline,
                label: 'Started',
                value: formatDateTime(trip.actualStartTime),
              ),
              const Divider(),
              buildInfoRow(
                icon: Icons.stop_circle_outlined,
                label: 'Ended',
                value: formatDateTime(trip.actualEndTime),
              ),
              if (isCompleted) ...[
                const Divider(),
                buildInfoRow(
                  icon: Icons.timer_outlined,
                  label: 'Duration',
                  value: formattedDuration,
                ),
              ],
            ]),
            if (trip.description != null && trip.description!.trim().isNotEmpty) ...[
              const SizedBox(height: 24),
              buildSectionTitle('Description'),
              buildInfoCard([
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    trip.description!,
                    style: const TextStyle(color: AppColors.primaryText, fontSize: 14),
                  ),
                ),
              ]),
            ],
          ],
        ),
      ),
    );
  }
}
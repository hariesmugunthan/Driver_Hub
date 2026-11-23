import 'package:flutter/material.dart';

import '../../configs/app_theme.dart';
import '../../models/trip_model.dart';

const Color _plateColor = Color(0xFFF1F5F9);
const Color _plateTextColor = Color(0xFF0F172A);

class AdminTripCard extends StatelessWidget {
  final TripModel trip;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onLiveTracking;
  final VoidCallback onViewStats;

  const AdminTripCard({
    super.key,
    required this.trip,
    required this.onEdit,
    required this.onDelete,
    required this.onLiveTracking,
    required this.onViewStats,
  });

  bool get canDelete {
    String status = trip.status;

    return status == 'scheduled' || status == 'completed' || status == 'cancelled';
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'scheduled':
        return Colors.blue;
      case 'inProgress':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.grey;
      default:
        return AppColors.secondaryText;
    }
  }

  void showTripNotStartedMessage(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Trip Not Started'),
          content: const Text(
            'The trip has not started yet. Live tracking will be '
            'available once the driver starts the trip.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Status badge
  Widget buildStatusBadge() {
    Color statusColor = getStatusColor(trip.status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        trip.status.replaceAll('_', ' ').toUpperCase(),
        style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }

  // Label and value row
  Widget buildDetailRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    Widget? valueWidget,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 32, child: Icon(icon, size: 23, color: iconColor)),
          SizedBox(
            width: 76,
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, color: AppColors.secondaryText),
            ),
          ),
          Expanded(
            child: valueWidget ??
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing],
        ],
      ),
    );
  }
  // Registration number plate
  Widget buildRegistrationPlate(String registrationNumber) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: _plateColor, borderRadius: BorderRadius.circular(6)),
        child: Text(
          registrationNumber,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            color: _plateTextColor,
          ),
        ),
      ),
    );
  }

  // Location information
  Widget buildLocationDetails() {
    return Column(
      children: [
        buildDetailRow(
          icon: Icons.location_on,
          iconColor: Colors.green,
          label: 'From',
          value: trip.startLocation,
          trailing: buildStatusBadge(),
        ),
        buildDetailRow(
          icon: Icons.flag,
          iconColor: Colors.red,
          label: 'To',
          value: trip.endLocation,
        ),
      ],
    );
  }

  // Driver and vehicle information
  Widget buildVehicleDetails() {
    String vehicleDetails = trip.vehicle != null
        ? '${trip.vehicle!.brand} ${trip.vehicle!.model}'
        : 'Vehicle details unavailable';

    String vehicleRegistration = trip.vehicle?.registrationNumber ?? 'Not available';

    return Column(
      children: [
        buildDetailRow(
          icon: Icons.person_outline,
          iconColor: Colors.blue,
          label: 'Driver',
          value: trip.driverName,
        ),
        buildDetailRow(
          icon: Icons.directions_car_outlined,
          iconColor: Colors.blue,
          label: 'Vehicle',
          value: vehicleRegistration,
          valueWidget: trip.vehicle != null ? buildRegistrationPlate(vehicleRegistration) : null,
        ),
        buildDetailRow(
          icon: Icons.car_repair,
          iconColor: Colors.blue,
          label: 'Model',
          value: vehicleDetails,
        ),
      ],
    );
  }

  // Trip action button
  Widget buildTripActionButton(BuildContext context) {
    String buttonText;
    IconData buttonIcon;
    bool isScheduled = false;
    bool canTrack = false;

    switch (trip.status) {
      case 'scheduled':
        buttonText = 'Live Tracking';
        buttonIcon = Icons.location_searching;
        isScheduled = true;
        break;

      case 'inProgress':
        buttonText = 'Live Tracking';
        buttonIcon = Icons.map_outlined;
        canTrack = true;
        break;

      case 'completed':
      case 'cancelled':
        buttonText = 'Stats';
        buttonIcon = Icons.analytics_outlined;
        break;

      default:
        return const SizedBox.shrink();
    }

    return SizedBox(
      height: 56,
      child: OutlinedButton.icon(
        onPressed: isScheduled
            ? () => showTripNotStartedMessage(context)
            : canTrack
            ? onLiveTracking
            : onViewStats,
        icon: Icon(buttonIcon, size: 20),
        label: Text(buttonText, style: const TextStyle(fontSize: 15)),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.secondary,
          side: const BorderSide(color: AppColors.secondary, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  // Edit button
  Widget buildEditButton() {
    return SizedBox(
      width: 56,
      height: 56,
      child: OutlinedButton(
        onPressed: onEdit,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          side: const BorderSide(color: AppColors.border, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: const Icon(Icons.edit_outlined, size: 22, color: AppColors.primaryText),
      ),
    );
  }

  // Delete button
  Widget buildDeleteButton() {
    return SizedBox(
      width: 56,
      height: 56,
      child: OutlinedButton(
        onPressed: onDelete,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          side: const BorderSide(color: AppColors.error, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: const Icon(Icons.delete_outline, size: 22, color: AppColors.error),
      ),
    );
  }

  // Action buttons
  Widget buildActions(BuildContext context) {
    return Row(
      children: [
        Expanded(child: buildTripActionButton(context)),
        const SizedBox(width: 12),
        buildEditButton(),
        if (canDelete) ...[const SizedBox(width: 12), buildDeleteButton()],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildLocationDetails(),
            const Divider(),
            buildVehicleDetails(),
            if (trip.description != null && trip.description!.isNotEmpty) ...[
              const Divider(),
              Text(
                'Description: ${trip.description}',
                style: const TextStyle(color: AppColors.secondaryText, fontSize: 14),
              ),
            ],
            const SizedBox(height: 12),
            buildActions(context),
          ],
        ),
      ),
    );
  }
}

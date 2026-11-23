import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../models/trip_model.dart';
import '../../screens/vehicle_qr_scanner_screen.dart';

const Color _cardColor = Color(0xFF1E293B);
const Color _backgroundColor = Color(0xFF0F172A);
const Color _borderColor = Color(0x1AFFFFFF);
const Color _primaryTextColor = Color(0xFFF1F5F9);
const Color _mutedTextColor = Color(0xFF94A3B8);
const Color _dotColor = Color(0xFF475569);

class DriverTripCard extends StatelessWidget {
  final TripModel trip;
  final Future<void> Function() onTripActionCompleted;

  const DriverTripCard({super.key, required this.trip, required this.onTripActionCompleted});

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
        return Colors.black;
    }
  }

  String getLocalizedStatus(AppLocalizations l10n, String status) {
    switch (status) {
      case 'scheduled':
        return l10n.scheduled;
      case 'inProgress':
        return l10n.inProgress;
      case 'completed':
        return l10n.completed;

      case 'cancelled':
        return l10n.cancelled;
      default:
        return status.replaceAll('_', ' ').toUpperCase();
    }
  }

  Future<void> openTrip(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VehicleQrScannerScreen(trip: trip),
      ),
    );

    if (!context.mounted) return;

    await onTripActionCompleted();
  }

  Widget buildActionButton(BuildContext context, bool canContinueTrip) {
    final l10n = AppLocalizations.of(context);

    return ElevatedButton.icon(
      onPressed: () => openTrip(context),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(100, 44),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: Icon(canContinueTrip ? Icons.play_circle_outline : Icons.play_arrow),
      label: Text(canContinueTrip ? l10n.continueTrip : l10n.start),
    );
  }

  Widget buildStatusChip(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final color = getStatusColor(trip.status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        getLocalizedStatus(l10n, trip.status),
        style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget buildHeader(BuildContext context, bool canStartTrip, bool canContinueTrip) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (canStartTrip || canContinueTrip)
          buildActionButton(context, canContinueTrip)
        else
          const Spacer(),
        buildStatusChip(context),
      ],
    );
  }

  Widget buildDetailRow(String label, Widget value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 13, color: _mutedTextColor)),
          ),
          const SizedBox(width: 12),
          value,
        ],
      ),
    );
  }

  Widget buildDetailValue(String value) {
    return Text(
      value,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _primaryTextColor),
    );
  }

  Widget buildRegistrationPlate(String registrationNumber) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: _primaryTextColor, borderRadius: BorderRadius.circular(6)),
      child: Text(
        registrationNumber,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: _backgroundColor,
        ),
      ),
    );
  }

  Widget buildVehicleDetails(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.directions_car, color: Colors.blue),
            const SizedBox(width: 8),
            Text(
              l10n.vehicleDetails,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _primaryTextColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (trip.vehicle != null) ...[
          buildDetailRow(
            l10n.registrationNumber,
            buildRegistrationPlate(trip.vehicle!.registrationNumber),
          ),
          buildDetailRow(l10n.brand, buildDetailValue(trip.vehicle!.brand)),
          buildDetailRow(l10n.model, buildDetailValue(trip.vehicle!.model)),
        ] else
          Text(l10n.vehicleDetailsUnavailable, style: const TextStyle(color: _mutedTextColor)),
      ],
    );
  }

  Widget buildRouteDots() {
    return Column(
      children: List.generate(
        3,
            (index) => Container(
          width: 3,
          height: 3,
          margin: const EdgeInsets.symmetric(vertical: 2),
          decoration: const BoxDecoration(color: _dotColor, shape: BoxShape.circle),
        ),
      ),
    );
  }

  Widget buildLocationText(String label, String location) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: _mutedTextColor)),
        Text(location, style: const TextStyle(fontSize: 15, color: _primaryTextColor)),
      ],
    );
  }

  Widget buildLocationDetails(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.location_on, color: Colors.green),
              buildRouteDots(),
              const Icon(Icons.flag, color: Colors.red),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildLocationText(l10n.from, trip.startLocation),
                const SizedBox(height: 12),
                buildLocationText(l10n.to, trip.endLocation),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDescription(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Text(
      '${l10n.description}: ${trip.description}',
      style: const TextStyle(fontSize: 13, color: _mutedTextColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String tripStatus = trip.status;

    final bool canStartTrip = tripStatus == 'scheduled';
    final bool canContinueTrip = tripStatus == 'inProgress';

    return Card(
      color: _cardColor,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: _borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildHeader(context, canStartTrip, canContinueTrip),
            const Divider(color: _borderColor, height: 24),
            buildVehicleDetails(context),
            const Divider(color: _borderColor, height: 16),
            buildLocationDetails(context),
            if (trip.description != null && trip.description!.isNotEmpty) ...[
              const SizedBox(height: 12),
              buildDescription(context),
            ],
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../configs/app_theme.dart';
import '../../controllers/vehicle_controller.dart';
import '../../models/vehicle_model.dart';

class VehicleCard extends StatelessWidget {
  final VehicleModel vehicle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const VehicleCard({
    super.key,
    required this.vehicle,
    required this.onEdit,
    required this.onDelete,
  });

  // Vehicle QR dialog.
  Future<void> showVehicleQrDialog(
      BuildContext context,
      ) async {
    VehicleController vehicleController = VehicleController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: AppColors.border, width: 1),
          ),
          title: const Text(
            'Vehicle QR Code',
            style: TextStyle(
              color: AppColors.primaryText,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Vehicle ID',
                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryText),
              ),

              const SizedBox(height: 6),

              SelectableText(
                vehicle.vehicleId,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.primaryText),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: 180,
                height: 180,
                child: QrImageView(
                  data: vehicle.vehicleId,
                  version: QrVersions.auto,
                  size: 180,
                  gapless: true,
                  backgroundColor: Colors.white,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Scan this QR code to identify the vehicle.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.primaryText),
              ),
            ],
          ),

          actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),

          actions: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Print and Share buttons horizontally.
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () async {
                        await vehicleController.saveVehicleQr(vehicle.vehicleId);
                      },
                      icon: const Icon(Icons.print, color: AppColors.primary),
                      label: const Text('Print', style: TextStyle(color: AppColors.primary)),
                    ),

                    const SizedBox(width: 12),

                    TextButton.icon(
                      onPressed: () async {
                        await vehicleController.shareVehicleQr(vehicle.vehicleId);
                      },
                      icon: const Icon(Icons.share, color: AppColors.primary),
                      label: const Text('Share', style: TextStyle(color: AppColors.primary)),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Full-width Done button.
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.primaryText,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Done'),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // Availability badge.
  Widget buildAvailabilityBadge() {
    bool isAvailable = vehicle.isAvailable;

    Color backgroundColor = isAvailable
        ? const Color(0xFF064E3B)
        : const Color(0xFF7F1D1D);

    Color indicatorColor = isAvailable
        ? const Color(0xFF34D399)
        : const Color(0xFFF87171);

    Color textColor = indicatorColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(24)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: indicatorColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            isAvailable ? 'Available' : 'Unavailable',
            style: TextStyle(fontSize: 14, color: textColor),
          ),
        ],
      ),
    );
  }

  // Vehicle header.
  Widget buildVehicleHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                vehicle.registrationNumber,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryText,
                ),
              ),
            ),
            const SizedBox(width: 8),
            buildAvailabilityBadge(),
          ],
        ),

        const SizedBox(height: 8),

        Text(
          '${vehicle.brand} ${vehicle.model}',
          style: const TextStyle(fontSize: 16, color: AppColors.secondaryText),
        ),
      ],
    );
  }

  // Individual vehicle specification.
  Widget buildSpecification(
      String label,
      String value,
      ) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: AppColors.secondaryText)),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (label == 'Fuel' && value.toLowerCase() == 'ev') ...[
                const Icon(Icons.electric_bolt, color: Color(0xFF34D399), size: 19),
                const SizedBox(width: 4),
              ],
              Flexible(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Vehicle specifications.
  Widget buildSpecifications() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSpecification('Type', vehicle.vehicleType),
        buildSpecification('Fuel', vehicle.fuelType),
        buildSpecification('Seats', vehicle.seatingCapacity.toString()),
      ],
    );
  }

  // Square action button.
  Widget buildIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color iconColor,
    required Color borderColor,
    required String tooltip,
  }) {
    return SizedBox(
      width: 54,
      height: 54,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          side: BorderSide(color: borderColor, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Icon(icon, size: 22, color: iconColor),
      ),
    );
  }

  // Vehicle actions.
  Widget buildActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined, size: 19),
              label: const Text('Edit', style: TextStyle(fontSize: 15)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryText,
                side: const BorderSide(color: AppColors.border, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ),

        const SizedBox(width: 10),

        buildIconButton(
          icon: Icons.qr_code,
          onPressed: () {
            showVehicleQrDialog(context);
          },
          iconColor: AppColors.primaryText,
          borderColor: AppColors.border,
          tooltip: 'View Vehicle QR Code',
        ),

        const SizedBox(width: 10),

        buildIconButton(
          icon: Icons.delete_outline,
          onPressed: onDelete,
          iconColor: AppColors.error,
          borderColor: AppColors.error,
          tooltip: 'Delete Vehicle',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildVehicleHeader(),

            const SizedBox(height: 8),

            const Divider(color: AppColors.border),

            const SizedBox(height: 6),

            buildSpecifications(),

            const SizedBox(height: 8),

            const Divider(color: AppColors.border),

            const SizedBox(height: 8),

            buildActions(context),
          ],
        ),
      ),
    );
  }
}

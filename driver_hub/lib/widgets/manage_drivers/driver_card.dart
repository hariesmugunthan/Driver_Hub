import 'package:flutter/material.dart';

import '../../configs/app_theme.dart';
import '../../models/driver_model.dart';
import '../../controllers/driver_controller.dart';
import '../create_new_driver/driver_qr_dialog.dart';

class DriverCard extends StatefulWidget {
  final DriverModel driver;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onViewPerformance;

  const DriverCard({
    super.key,
    required this.driver,
    required this.onEdit,
    required this.onDelete,
    required this.onViewPerformance,
  });

  @override
  State<DriverCard> createState() => _DriverCardState();
}

class _DriverCardState extends State<DriverCard> {
  DriverController driverController = DriverController();

  bool isExpanded = false;

  // Generate initials from driver name.
  String getDriverInitials() {
    List<String> nameParts = widget.driver.name.trim().split(RegExp(r'\s+'));

    if (nameParts.isEmpty || nameParts.first.isEmpty) {
      return 'D';
    }

    if (nameParts.length == 1) {
      return nameParts.first[0].toUpperCase();
    }

    return '${nameParts.first[0]}${nameParts.last[0]}'.toUpperCase();
  }

  // Driver avatar.
  Widget buildDriverAvatar() {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: isExpanded ? AppColors.primary : AppColors.background,
        shape: BoxShape.circle,
        border: isExpanded
            ? null
            : Border.all(color: AppColors.border, width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text(
        getDriverInitials(),
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w500,
          color: AppColors.primaryText,
        ),
      ),
    );
  }

  // Driver name header.
  Widget buildDriverHeader() {
    return InkWell(
      onTap: () {
        setState(() {
          isExpanded = !isExpanded;
        });
      },
      borderRadius: BorderRadius.circular(14),
      child: Row(
        children: [
          buildDriverAvatar(),

          const SizedBox(width: 20),

          Expanded(
            child: Text(
              widget.driver.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.primaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Label and value row.
  Widget buildDetailRow({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(fontSize: 15, color: AppColors.secondaryText),
            ),
          ),

          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 15, color: AppColors.primaryText)),
          ),
        ],
      ),
    );
  }

  // Availability badge.
  Widget buildAvailabilityBadge() {
    bool isAvailable = widget.driver.isAvailable;

    Color badgeColor = isAvailable
        ? const Color(0xFF064E3B)
        : const Color(0xFF7F1D1D);

    Color indicatorColor = isAvailable
        ? const Color(0xFF34D399)
        : const Color(0xFFF87171);

    Color textColor = isAvailable
        ? const Color(0xFF34D399)
        : const Color(0xFFF87171);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          const SizedBox(
            width: 110,
            child: Text('Status', style: TextStyle(fontSize: 15, color: AppColors.secondaryText)),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(20)),
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
          ),
        ],
      ),
    );
  }

  // Driver information.
  Widget buildDriverInformation() {
    return Column(
      children: [
        buildDetailRow(label: 'Driver ID', value: widget.driver.userId),

        buildDetailRow(label: 'Mobile', value: widget.driver.mobileNumber),

        buildDetailRow(label: 'Email', value: widget.driver.email),

        buildDetailRow(label: 'License', value: widget.driver.licenseNumber),

        buildAvailabilityBadge(),
      ],
    );
  }

  // Square action button.
  Widget buildIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color iconColor,
    required String tooltip,
    Color? borderColor,
  }) {
    return SizedBox(
      width: 54,
      height: 54,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          side: BorderSide(color: borderColor ?? AppColors.border, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Icon(icon, size: 22, color: iconColor),
      ),
    );
  }

  // Driver QR dialog.
  Future<void> showDriverQrDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return DriverQrDialog(
          driver: widget.driver,
          shareDriverQr: driverController.shareDriverQr,
          saveDriverQr: driverController.saveDriverQr,
          title: 'Driver QR Code',
        );
      },
    );
  }

  // Action buttons.
  Widget buildActions() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 54,
            child: OutlinedButton.icon(
              onPressed: widget.onViewPerformance,
              icon: const Icon(Icons.analytics_outlined, size: 20),
              label: const Text('Performance', style: TextStyle(fontSize: 15)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.secondary,
                side: const BorderSide(color: AppColors.secondary, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        buildIconButton(
          icon: Icons.qr_code,
          onPressed: showDriverQrDialog,
          iconColor: AppColors.primaryText,
          tooltip: 'View Driver QR Code',
        ),

        const SizedBox(width: 12),

        buildIconButton(
          icon: Icons.edit_outlined,
          onPressed: widget.onEdit,
          iconColor: AppColors.primaryText,
          tooltip: 'Edit Driver',
        ),

        const SizedBox(width: 12),

        buildIconButton(
          icon: Icons.delete_outline,
          onPressed: widget.onDelete,
          iconColor: AppColors.error,
          borderColor: AppColors.error,
          tooltip: 'Delete Driver',
        ),
      ],
    );
  }

  // Expanded driver details.
  Widget buildExpandedContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(color: AppColors.border, height: 24),

        buildDriverInformation(),

        const SizedBox(height: 12),

        buildActions(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: isExpanded ? AppColors.primary : AppColors.border,
          width: isExpanded ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildDriverHeader(),

            if (isExpanded) ...[buildExpandedContent()],
          ],
        ),
      ),
    );
  }
}

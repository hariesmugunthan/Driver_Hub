
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../models/driver_model.dart';
import '../../configs/app_theme.dart';

class DriverQrDialog extends StatelessWidget {
  final DriverModel driver;
  final String title;
  final Future<void> Function(String) shareDriverQr;
  final Future<void> Function(String) saveDriverQr;

  const DriverQrDialog({
    super.key,
    required this.driver,
    required this.shareDriverQr,
    required this.saveDriverQr,
    this.title = 'Driver Created Successfully',
  });

  Widget buildDriverId() {
    return Column(
      children: [
        const Text(
          'Driver ID',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryText),
        ),
        const SizedBox(height: 8),
        SelectableText(
          driver.userId,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.secondaryText, fontSize: 14),
        ),
      ],
    );
  }

  Widget buildQrCode() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
      child: SizedBox(
        width: 180,
        height: 180,
        child: QrImageView(
          data: driver.userId,
          version: QrVersions.auto,
          size: 180,
          gapless: true,
          backgroundColor: Colors.white,
        ),
      ),
    );
  }

  Widget buildDialogContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildDriverId(),
        const SizedBox(height: 20),
        buildQrCode(),
        const SizedBox(height: 16),
        const Text(
          'Scan this QR code to identify the driver.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.secondaryText, fontSize: 14),
        ),
      ],
    );
  }

  Widget buildDialogActions(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Print followed by Share - horizontal layout
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton.icon(
              onPressed: () async {
                await saveDriverQr(driver.userId);
              },
              icon: const Icon(Icons.print),
              label: const Text('Print'),
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
            const SizedBox(width: 8),
            TextButton.icon(
              onPressed: () async {
                await shareDriverQr(driver.userId);
              },
              icon: const Icon(Icons.share),
              label: const Text('Share'),
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Full-width Done button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.primaryText,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text('Done', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.border, width: 1),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.primaryText,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
      ),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
      content: buildDialogContent(),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      actions: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: buildDialogActions(context),
        ),
      ],
      actionsPadding: EdgeInsets.zero,
    );
  }
}

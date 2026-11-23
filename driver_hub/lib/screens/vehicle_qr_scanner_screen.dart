import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../models/trip_model.dart';
import 'trip_route_screen.dart';

class VehicleQrScannerScreen extends StatefulWidget {
  final TripModel trip;

  const VehicleQrScannerScreen({super.key, required this.trip});

  @override
  State<VehicleQrScannerScreen> createState() => _VehicleQrScannerScreenState();
}

class _VehicleQrScannerScreenState extends State<VehicleQrScannerScreen> {
  bool _isProcessing = false;

  Future<void> _handleBarcode(BarcodeCapture capture) async {
    if (_isProcessing) {
      return;
    }

    if (capture.barcodes.isEmpty) {
      return;
    }

    final String? scannedVehicleId = capture.barcodes.first.rawValue?.trim();

    if (scannedVehicleId == null || scannedVehicleId.isEmpty) {
      return;
    }

    _isProcessing = true;

    final String assignedVehicleId = widget.trip.vehicleId.trim();

    if (assignedVehicleId.isEmpty) {
      _showErrorMessage('Assigned vehicle ID is unavailable.');

      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }

      return;
    }

    if (scannedVehicleId == assignedVehicleId) {
      if (!mounted) {
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TripRouteScreen(
            trip: widget.trip,
          ),
        ),
      );

      return;
    }

    _showErrorMessage('Incorrect vehicle! Please scan the QR code of your assigned vehicle.');

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context)..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  Widget buildHeaderInstruction() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Text(
        'Scan the QR code displayed on your assigned vehicle '
        'to continue.',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  Widget buildScanTargetFrame() {
    return Container(
      width: 250,
      height: 250,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green, width: 3),
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  Widget buildScanGuideBanner() {
    return Positioned(
      bottom: 24,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
        child: const Text(
          'Align the vehicle QR code inside the frame',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget buildScannerArea() {
    return Expanded(
      child: Stack(
        alignment: Alignment.center,
        children: [
          MobileScanner(onDetect: _handleBarcode),
          buildScanTargetFrame(),
          buildScanGuideBanner(),
        ],
      ),
    );
  }

  Widget buildScannerContent() {
    return Column(
      children: [
        buildHeaderInstruction(),
        buildScannerArea(),
      ],
    );
  }

  Widget buildUnavailableNotice() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Assigned vehicle ID is unavailable for this trip.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasAssignedVehicle = widget.trip.vehicleId.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Vehicle QR'),
      ),
      body: hasAssignedVehicle
          ? buildScannerContent()
          : buildUnavailableNotice(),
    );
  }
}
import 'package:flutter/material.dart';

class TripStartButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isTracking;
  final String buttonLabel;

  const TripStartButton({
    super.key,
    required this.onPressed,
    required this.isLoading,
    required this.isTracking,
    this.buttonLabel = 'Start Trip',
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isLoading || isTracking ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        )
            : Icon(isTracking ? Icons.gps_fixed : Icons.play_arrow),
        label: Text(
          isLoading ? 'Starting GPS...' : isTracking ? 'GPS Tracking Active' : buttonLabel,
        ),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}
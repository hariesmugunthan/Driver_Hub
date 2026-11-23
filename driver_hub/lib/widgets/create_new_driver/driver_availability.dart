import 'package:flutter/material.dart';

class DriverAvailability extends StatelessWidget {
  final bool isAvailable;
  final ValueChanged<bool> onChanged;

  DriverAvailability({super.key, required this.isAvailable, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text('Driver Available'),
      value: isAvailable,
      onChanged: onChanged,
    );
  }
}
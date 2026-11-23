import 'package:flutter/material.dart';

class VehicleAvailability extends StatelessWidget {
  final bool isAvailable;
  final ValueChanged<bool> onChanged;

  const VehicleAvailability({super.key, required this.isAvailable, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text('Vehicle Availability'),
      subtitle: Text(isAvailable ? 'Available' : 'Unavailable'),
      value: isAvailable,
      onChanged: onChanged,
    );
  }
}
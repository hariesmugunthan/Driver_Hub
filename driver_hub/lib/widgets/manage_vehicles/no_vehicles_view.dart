import 'package:flutter/material.dart';

class NoVehiclesView extends StatelessWidget {
  final VoidCallback onAddVehicle;

  const NoVehiclesView({
    super.key,
    required this.onAddVehicle,
  });

  Widget buildIcon() {
    return const Icon(Icons.directions_car_outlined, size: 72, color: Colors.grey);
  }

  Widget buildEmptyMessage() {
    return const Column(
      children: [
        Text('No Vehicles Found', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text('Add your first vehicle to get started.', textAlign: TextAlign.center),
      ],
    );
  }

  Widget buildAddButton() {
    return ElevatedButton.icon(
      onPressed: onAddVehicle,
      icon: const Icon(Icons.add),
      label: const Text('Add Vehicle'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildIcon(),
            const SizedBox(height: 16),
            buildEmptyMessage(),
            const SizedBox(height: 20),
            buildAddButton(),
          ],
        ),
      ),
    );
  }
}
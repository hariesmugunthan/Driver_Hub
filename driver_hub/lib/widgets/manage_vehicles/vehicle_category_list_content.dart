import 'package:flutter/material.dart';

import '../../models/vehicle_model.dart';
import 'vehicle_card.dart';

class VehicleCategoryListContent extends StatelessWidget {
  final String categoryName;
  final List<VehicleModel> categoryVehicles;
  final Future<void> Function() onRefresh;
  final VoidCallback onAddVehicle;
  final void Function(VehicleModel) onEditVehicle;
  final void Function(VehicleModel) onDeleteVehicle;

  const VehicleCategoryListContent({
    super.key,
    required this.categoryName,
    required this.categoryVehicles,
    required this.onRefresh,
    required this.onAddVehicle,
    required this.onEditVehicle,
    required this.onDeleteVehicle,
  });

  Widget buildAddVehicleButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onAddVehicle,
        icon: const Icon(Icons.add),
        label: const Text('Add New Vehicle'),
      ),
    );
  }

  Widget buildEmptyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.directions_car_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No $categoryName vehicles found',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add a vehicle to this category to see it here.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildVehicleList() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        buildAddVehicleButton(),
        const SizedBox(height: 16),
        if (categoryVehicles.isEmpty)
          SizedBox(
            height: 300,
            child: buildEmptyView(),
          )
        else
          ...categoryVehicles.map(
            (vehicle) => VehicleCard(
              vehicle: vehicle,
              onEdit: () {
                onEditVehicle(vehicle);
              },
              onDelete: () {
                onDeleteVehicle(vehicle);
              },
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: buildVehicleList(),
    );
  }
}

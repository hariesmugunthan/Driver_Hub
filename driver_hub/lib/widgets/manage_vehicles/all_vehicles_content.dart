import 'package:flutter/material.dart';

import '../../models/vehicle_model.dart';
import 'vehicle_card.dart';

class AllVehiclesContent extends StatelessWidget {
  final List<VehicleModel> vehicleList;
  final Future<void> Function() onRefresh;
  final void Function(VehicleModel) onEditVehicle;
  final void Function(VehicleModel) onDeleteVehicle;

  const AllVehiclesContent({
    super.key,
    required this.vehicleList,
    required this.onRefresh,
    required this.onEditVehicle,
    required this.onDeleteVehicle,
  });

  Map<String, List<VehicleModel>> groupVehicles() {
    Map<String, List<VehicleModel>> groupedVehicles = {};

    for (VehicleModel vehicle in vehicleList) {
      groupedVehicles.putIfAbsent(vehicle.vehicleType, () => []);

      groupedVehicles[vehicle.vehicleType]!.add(vehicle);
    }

    return groupedVehicles;
  }

  Widget buildEmptyView() {
    return ListView(
      children: const [
        SizedBox(
          height: 300,
          child: Center(
            child: Text('No vehicles found'),
          ),
        ),
      ],
    );
  }

  Widget buildCategorySection(MapEntry<String, List<VehicleModel>> entry) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            '${entry.key} (${entry.value.length})',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
        ...entry.value.map(
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

  Widget buildVehicleGroups() {
    Map<String, List<VehicleModel>> groupedVehicles = groupVehicles();

    if (groupedVehicles.isEmpty) {
      return buildEmptyView();
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: groupedVehicles.entries.map((entry) {
        return buildCategorySection(entry);
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: buildVehicleGroups(),
    );
  }
}

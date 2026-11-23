import 'package:flutter/material.dart';

import '../../models/vehicle_model.dart';
import '../../configs/vehicle_categories.dart';
import 'trip_selection_field.dart';

class TripVehicleSelection extends StatelessWidget {
  final VehicleModel? selectedVehicle;
  final List<VehicleModel> availableVehicles;
  final bool isEnabled;
  final ValueChanged<VehicleModel> onVehicleSelected;

  const TripVehicleSelection({
    super.key,
    required this.selectedVehicle,
    required this.availableVehicles,
    required this.onVehicleSelected,
    this.isEnabled = true,
  });

  // SHOW VEHICLE CATEGORY DIALOG

  void showVehicleCategoryDialog(BuildContext context) {
    if (availableVehicles.isEmpty) {
      showErrorMessage(context, 'No available vehicles found for this schedule');
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Select Vehicle Category'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: VehicleCategories.categories.length,
            itemBuilder: (context, index) {
              final category = VehicleCategories.categories[index];

              final categoryName = category['name'] as String;

              final count = availableVehicles
                  .where((vehicle) => vehicle.vehicleType == categoryName)
                  .length;

              return ListTile(
                leading: Icon(category['icon'] as IconData),
                title: Text(categoryName),
                subtitle: Text('$count available vehicles'),
                enabled: count > 0,
                onTap: count == 0
                    ? null
                    : () {
                        Navigator.pop(dialogContext);

                        showVehiclesByCategory(context, categoryName);
                      },
              );
            },
          ),
        ),
      ),
    );
  }

  // SHOW VEHICLES BY CATEGORY

  void showVehiclesByCategory(BuildContext context, String categoryName) {
    final categoryVehicles = availableVehicles
        .where((vehicle) => vehicle.vehicleType == categoryName)
        .toList();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Select $categoryName'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: categoryVehicles.length,
            itemBuilder: (context, index) {
              final vehicle = categoryVehicles[index];

              return ListTile(
                leading: const Icon(Icons.directions_car_outlined),
                title: Text(vehicle.registrationNumber),
                subtitle: Text('${vehicle.brand} ${vehicle.model}'),
                onTap: () {
                  onVehicleSelected(vehicle);
                  Navigator.pop(dialogContext);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  // ERROR MESSAGE

  void showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // UI

  @override
  Widget build(BuildContext context) {
    return TripSelectionField(
      label: 'Vehicle Selection',
      placeholder: 'Select Vehicle',
      selectedValue: selectedVehicle?.registrationNumber,
      subtitle: selectedVehicle == null
          ? null
          : '${selectedVehicle!.vehicleType} • '
                '${selectedVehicle!.brand} '
                '${selectedVehicle!.model}',
      icon: Icons.directions_car_outlined,
      onTap: () => showVehicleCategoryDialog(context),
      isLoading: false,
      isEnabled: isEnabled,
    );
  }
}

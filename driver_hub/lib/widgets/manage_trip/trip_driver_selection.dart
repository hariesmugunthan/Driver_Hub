import 'package:flutter/material.dart';

import '../../models/driver_model.dart';
import 'trip_selection_field.dart';

class TripDriverSelection extends StatelessWidget {
  final DriverModel? selectedDriver;
  final List<DriverModel> availableDrivers;
  final bool isEnabled;
  final ValueChanged<DriverModel> onDriverSelected;

  const TripDriverSelection({
    super.key,
    required this.selectedDriver,
    required this.availableDrivers,
    required this.onDriverSelected,
    this.isEnabled = true,
  });

  void showDriverSelectionDialog(BuildContext context) {
    if (availableDrivers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No available drivers found for this schedule')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Select Driver'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: availableDrivers.length,
            itemBuilder: (context, index) {
              final driver = availableDrivers[index];

              return ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text(driver.name),
                subtitle: Text(driver.mobileNumber),
                onTap: () {
                  onDriverSelected(driver);
                  Navigator.pop(dialogContext);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TripSelectionField(
      label: 'Driver Selection',
      placeholder: 'Select Driver',
      selectedValue: selectedDriver?.name,
      icon: Icons.person_outline,
      onTap: () => showDriverSelectionDialog(context),
      isLoading: false,
      isEnabled: isEnabled,
    );
  }
}

import 'package:flutter/material.dart';

import 'vehicle_availability.dart';
import 'vehicle_basic_detail.dart';
import 'vehicle_register_button.dart';

class CreateNewVehicleContent extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController registrationNumberController;
  final TextEditingController vehicleTypeController;
  final TextEditingController brandController;
  final TextEditingController modelController;
  final TextEditingController fuelTypeController;
  final TextEditingController seatingCapacityController;
  final bool isAvailable;
  final bool isRegistering;
  final ValueChanged<bool> onAvailabilityChanged;
  final VoidCallback onRegister;

  const CreateNewVehicleContent({
    super.key,
    required this.formKey,
    required this.registrationNumberController,
    required this.vehicleTypeController,
    required this.brandController,
    required this.modelController,
    required this.fuelTypeController,
    required this.seatingCapacityController,
    required this.isAvailable,
    required this.isRegistering,
    required this.onAvailabilityChanged,
    required this.onRegister,
  });

  Widget buildVehicleDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Vehicle Details', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        VehicleBasicDetail(
          registrationNumberController: registrationNumberController,
          vehicleTypeController: vehicleTypeController,
          brandController: brandController,
          modelController: modelController,
          fuelTypeController: fuelTypeController,
          seatingCapacityController: seatingCapacityController,
        ),
      ],
    );
  }

  Widget buildAvailability() {
    return VehicleAvailability(isAvailable: isAvailable, onChanged: onAvailabilityChanged);
  }

  Widget buildRegisterButton() {
    return VehicleRegisterButton(isRegistering: isRegistering, onPressed: onRegister);
  }

  Widget buildForm() {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildVehicleDetails(),
          const SizedBox(height: 16),
          buildAvailability(),
          const SizedBox(height: 32),
          buildRegisterButton(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildForm();
  }
}

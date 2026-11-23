import 'package:flutter/material.dart';

import 'vehicle_dropdown_field.dart';

class VehicleBasicDetail extends StatelessWidget {
  final TextEditingController registrationNumberController;
  final TextEditingController vehicleTypeController;
  final TextEditingController brandController;
  final TextEditingController modelController;
  final TextEditingController fuelTypeController;
  final TextEditingController seatingCapacityController;

  const VehicleBasicDetail({
    super.key,
    required this.registrationNumberController,
    required this.vehicleTypeController,
    required this.brandController,
    required this.modelController,
    required this.fuelTypeController,
    required this.seatingCapacityController,
  });

  static const List<String> vehicleTypes = [
    'Hatchback',
    'Sedan',
    'SUV',
    'MUV',
    'MPV',
    'Van',
    'Tempo Traveller',
    'Minibus',
    'Bus',
    'Pickup Truck',
    'Light Commercial Vehicle',
    'Heavy Truck',
  ];

  static const List<String> fuelTypes = ['Petrol', 'Diesel', 'CNG', 'EV'];

  String? validateField(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }

    return null;
  }

  Widget buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      validator: validateField,
    );
  }

  Widget buildRegistrationNumberField() {
    return buildTextField(label: 'Registration Number', controller: registrationNumberController);
  }

  Widget buildVehicleTypeField() {
    return VehicleDropdownField(
      label: 'Vehicle Type',
      selectedValue: vehicleTypes.contains(vehicleTypeController.text)
          ? vehicleTypeController.text
          : null,
      options: vehicleTypes,
      onChanged: (value) {
        vehicleTypeController.text = value ?? '';
      },
    );
  }

  Widget buildBrandField() {
    return buildTextField(label: 'Brand', controller: brandController);
  }

  Widget buildModelField() {
    return buildTextField(label: 'Model', controller: modelController);
  }

  Widget buildFuelTypeField() {
    return VehicleDropdownField(
      label: 'Fuel Type',
      selectedValue: fuelTypes.contains(fuelTypeController.text) ? fuelTypeController.text : null,
      options: fuelTypes,
      onChanged: (value) {
        fuelTypeController.text = value ?? '';
      },
    );
  }

  Widget buildSeatingCapacityField() {
    return buildTextField(
      label: 'Seating Capacity',
      controller: seatingCapacityController,
      keyboardType: TextInputType.number,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildRegistrationNumberField(),
        const SizedBox(height: 16),
        buildVehicleTypeField(),
        const SizedBox(height: 16),
        buildBrandField(),
        const SizedBox(height: 16),
        buildModelField(),
        const SizedBox(height: 16),
        buildFuelTypeField(),
        const SizedBox(height: 16),
        buildSeatingCapacityField(),
      ],
    );
  }
}
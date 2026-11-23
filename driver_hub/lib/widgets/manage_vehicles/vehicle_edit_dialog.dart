
import 'package:flutter/material.dart';

import '../../models/vehicle_model.dart';
import '../create_new_vehicle/vehicle_basic_detail.dart';

class VehicleEditDialog extends StatefulWidget {
  final VehicleModel vehicle;
  final Future<void> Function(VehicleModel) onUpdate;

  const VehicleEditDialog({
    super.key,
    required this.vehicle,
    required this.onUpdate,
  });

  @override
  State<VehicleEditDialog> createState() =>
      _VehicleEditDialogState();
}

class _VehicleEditDialogState extends State<VehicleEditDialog> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController registrationNumberController = TextEditingController();

  final TextEditingController vehicleTypeController = TextEditingController();

  final TextEditingController brandController = TextEditingController();

  final TextEditingController modelController = TextEditingController();

  final TextEditingController fuelTypeController = TextEditingController();

  final TextEditingController seatingCapacityController = TextEditingController();

  // Dialog colors matching Driver Edit Dialog.
  static const Color dialogColor = Color(0xFF1F2A3D);
  static const Color fieldColor = Color(0xFF0F172A);
  static const Color borderColor = Color(0xFF334155);
  static const Color labelColor = Color(0xFF38BDF8);
  static const Color blueColor = Color(0xFF2563EB);

  String? selectedVehicleType;
  String? selectedFuelType;

  bool isAvailable = true;
  bool isUpdating = false;

  @override
  void initState() {
    super.initState();

    registrationNumberController.text = widget.vehicle.registrationNumber;

    vehicleTypeController.text = widget.vehicle.vehicleType;
    selectedVehicleType = widget.vehicle.vehicleType;

    brandController.text = widget.vehicle.brand;
    modelController.text = widget.vehicle.model;

    fuelTypeController.text = widget.vehicle.fuelType;
    selectedFuelType = widget.vehicle.fuelType;

    seatingCapacityController.text = widget.vehicle.seatingCapacity.toString();

    isAvailable = widget.vehicle.isAvailable;
  }

  @override
  void dispose() {
    registrationNumberController.dispose();
    vehicleTypeController.dispose();
    brandController.dispose();
    modelController.dispose();
    fuelTypeController.dispose();
    seatingCapacityController.dispose();

    super.dispose();
  }

  String? validateField(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }

    return null;
  }

  // Common input decoration.
  InputDecoration buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      floatingLabelBehavior: FloatingLabelBehavior.auto,

      labelStyle: const TextStyle(color: labelColor, fontSize: 16),

      floatingLabelStyle: const TextStyle(color: labelColor, fontSize: 16),

      filled: true,
      fillColor: fieldColor,

      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: borderColor, width: 1.5),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: labelColor, width: 1.5),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }

  // Text field.
  Widget buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,

      style: const TextStyle(color: Colors.white, fontSize: 17),

      decoration: buildInputDecoration(label),

      validator: validateField,
    );
  }

  // Vehicle type dropdown.
  Widget buildVehicleTypeDropdown() {
    List<String> options = [
      ...VehicleBasicDetail.vehicleTypes,
      if (selectedVehicleType != null &&
          !VehicleBasicDetail.vehicleTypes.contains(selectedVehicleType))
        selectedVehicleType!,
    ];

    return DropdownButtonFormField<String>(
      initialValue: selectedVehicleType,

      dropdownColor: fieldColor,

      style: const TextStyle(color: Colors.white, fontSize: 17),

      icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),

      decoration: buildInputDecoration('Vehicle Type'),

      items: options.map((option) {
        return DropdownMenuItem<String>(
          value: option,
          child: Text(option, style: const TextStyle(color: Colors.white)),
        );
      }).toList(),

      onChanged: isUpdating
          ? null
          : (value) {
        setState(() {
          selectedVehicleType = value;
          vehicleTypeController.text = value ?? '';
        });
      },

      validator: (value) => validateField(value),
    );
  }

  // Fuel type dropdown.
  Widget buildFuelTypeDropdown() {
    List<String> options = [
      ...VehicleBasicDetail.fuelTypes,
      if (selectedFuelType != null &&
          !VehicleBasicDetail.fuelTypes.contains(selectedFuelType))
        selectedFuelType!,
    ];

    return DropdownButtonFormField<String>(
      initialValue: selectedFuelType,

      dropdownColor: fieldColor,

      style: const TextStyle(color: Colors.white, fontSize: 17),

      icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),

      decoration: buildInputDecoration('Fuel Type'),

      items: options.map((option) {
        return DropdownMenuItem<String>(
          value: option,
          child: Text(option, style: const TextStyle(color: Colors.white)),
        );
      }).toList(),

      onChanged: isUpdating
          ? null
          : (value) {
        setState(() {
          selectedFuelType = value;
          fuelTypeController.text = value ?? '';
        });
      },

      validator: (value) => validateField(value),
    );
  }

  // Update vehicle.
  Future<void> updateVehicle() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    int? seatingCapacity = int.tryParse(seatingCapacityController.text.trim());

    if (seatingCapacity == null || seatingCapacity < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid seating capacity')),
      );
      return;
    }

    setState(() {
      isUpdating = true;
    });

    VehicleModel updatedVehicle = VehicleModel(
      vehicleId: widget.vehicle.vehicleId,
      registrationNumber:
      registrationNumberController.text.trim(),
      vehicleType: vehicleTypeController.text.trim(),
      brand: brandController.text.trim(),
      model: modelController.text.trim(),
      fuelType: fuelTypeController.text.trim(),
      seatingCapacity: seatingCapacity,
      isAvailable: isAvailable,
    );

    try {
      await widget.onUpdate(updatedVehicle);

      if (!mounted) {
        return;
      }

      Navigator.pop(context);
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        isUpdating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  // All vehicle fields.
  Widget buildVehicleFields() {
    return Column(
      children: [
        buildTextField(label: 'Registration Number', controller: registrationNumberController),

        const SizedBox(height: 20),

        buildVehicleTypeDropdown(),

        const SizedBox(height: 20),

        buildTextField(label: 'Brand', controller: brandController),

        const SizedBox(height: 20),

        buildTextField(label: 'Model', controller: modelController),

        const SizedBox(height: 20),

        buildFuelTypeDropdown(),

        const SizedBox(height: 20),

        buildTextField(
          label: 'Seating Capacity',
          controller: seatingCapacityController,
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  // Availability switch.
  Widget buildAvailability() {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,

      title: const Text('Vehicle Available', style: TextStyle(color: Colors.white, fontSize: 17)),

      value: isAvailable,

      activeThumbColor: Colors.white,
      activeTrackColor: blueColor,

      onChanged: isUpdating
          ? null
          : (value) {
        setState(() {
          isAvailable = value;
        });
      },
    );
  }

  // Dialog actions.
  Widget buildActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: isUpdating
                ? null
                : () {
              Navigator.pop(context);
            },

            child: const Text(
              'Cancel',
              style: TextStyle(color: blueColor, fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ),

        const SizedBox(height: 12),

        SizedBox(
          height: 56,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: blueColor,
              foregroundColor: Colors.white,
              elevation: 0,

              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),

            onPressed: isUpdating ? null : updateVehicle,

            child: isUpdating
                ? const SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            )
                : const Text('Update', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),

      child: Container(
        width: 500,
        height: MediaQuery.of(context).size.height * 0.88,

        padding: const EdgeInsets.all(24),

        decoration: BoxDecoration(
          color: dialogColor,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: borderColor, width: 1.2),
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Edit Vehicle',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 28),

            const SizedBox(height: 20),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 16),
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      buildVehicleFields(),
                      const SizedBox(height: 20),
                      buildAvailability(),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            buildActions(),
          ],
        ),
      ),
    );
  }
}

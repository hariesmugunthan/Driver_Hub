import 'package:flutter/material.dart';

import '../controllers/vehicle_controller.dart';
import '../models/vehicle_model.dart';
import '../widgets/create_new_vehicle/create_new_vehicle_content.dart';

class CreateNewVehicleScreen extends StatefulWidget {
  const CreateNewVehicleScreen({super.key});

  @override
  State<CreateNewVehicleScreen> createState() => _CreateNewVehicleScreenState();
}

class _CreateNewVehicleScreenState extends State<CreateNewVehicleScreen> {
  VehicleController vehicleController = VehicleController();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController registrationNumberController = TextEditingController();

  TextEditingController vehicleTypeController = TextEditingController();

  TextEditingController brandController = TextEditingController();

  TextEditingController modelController = TextEditingController();

  TextEditingController fuelTypeController = TextEditingController();

  TextEditingController seatingCapacityController = TextEditingController();

  bool isAvailable = true;
  bool isRegistering = false;

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

  Future<void> registerVehicle() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    int? seatingCapacity = int.tryParse(seatingCapacityController.text.trim());

    if (seatingCapacity == null || seatingCapacity < 1) {
      showMessage('Please enter a valid seating capacity');
      return;
    }

    setState(() {
      isRegistering = true;
    });

    try {
      VehicleModel vehicleModel = VehicleModel(
        registrationNumber:
        registrationNumberController.text.trim(),
        vehicleType: vehicleTypeController.text.trim(),
        brand: brandController.text.trim(),
        model: modelController.text.trim(),
        fuelType: fuelTypeController.text.trim(),
        seatingCapacity: seatingCapacity,
        isAvailable: isAvailable,
      );

      await vehicleController.createVehicle(vehicleModel);

      if (!mounted) {
        return;
      }

      Navigator.pop(context);
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        isRegistering = false;
      });

      showMessage(error.toString().replaceFirst('Exception: ', ''));
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget buildForm() {
    return CreateNewVehicleContent(
      formKey: formKey,
      registrationNumberController: registrationNumberController,
      vehicleTypeController: vehicleTypeController,
      brandController: brandController,
      modelController: modelController,
      fuelTypeController: fuelTypeController,
      seatingCapacityController: seatingCapacityController,
      isAvailable: isAvailable,
      isRegistering: isRegistering,
      onAvailabilityChanged: (value) {
        setState(() {
          isAvailable = value;
        });
      },
      onRegister: registerVehicle,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Vehicle'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: buildForm(),
      ),
    );
  }
}
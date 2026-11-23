import 'package:flutter/material.dart';

import '../configs/app_theme.dart';
import '../controllers/vehicle_controller.dart';
import '../models/vehicle_id_model.dart';
import '../models/vehicle_model.dart';
import '../widgets/manage_vehicles/manage_vehicles_content.dart';
import '../widgets/manage_vehicles/vehicle_edit_dialog.dart';
import 'all_vehicles_screen.dart';
import 'create_new_vehicle_screen.dart';
import 'vehicle_category_list_screen.dart';

class ManageVehiclesScreen extends StatefulWidget {
  const ManageVehiclesScreen({super.key});

  @override
  State<ManageVehiclesScreen> createState() => _ManageVehiclesScreenState();
}

class _ManageVehiclesScreenState extends State<ManageVehiclesScreen> {
  final VehicleController vehicleController = VehicleController();

  List<VehicleModel> vehicleList = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadVehicles();
  }

  Future<void> loadVehicles() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      List<VehicleModel> loadedVehicleList = await vehicleController.getAllVehicles();

      if (!mounted) {
        return;
      }

      setState(() {
        vehicleList = loadedVehicleList;
        isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        isLoading = false;
      });

      showMessage(error.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<List<VehicleModel>> refreshAndGetVehicles() async {
    await loadVehicles();
    return vehicleList;
  }

  Future<void> openCreateVehicleScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateNewVehicleScreen(),
      ),
    );

    await loadVehicles();
  }

  Future<void> showEditVehicleDialog(VehicleModel vehicle) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return VehicleEditDialog(vehicle: vehicle, onUpdate: updateVehicle);
      },
    );
  }

  Future<void> updateVehicle(VehicleModel vehicle) async {
    await vehicleController.updateVehicle(vehicle);

    if (!mounted) {
      return;
    }

    showMessage('Vehicle updated successfully');

    await loadVehicles();
  }

  Future<void> showDeleteVehicleDialog(VehicleModel vehicle) async {
    bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Vehicle'),
          content: Text('Are you sure you want to delete ' '${vehicle.registrationNumber}?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size(0, 48)),
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    await deleteVehicle(vehicle);
  }

  Future<void> deleteVehicle(VehicleModel vehicle) async {
    try {
      await vehicleController.deleteVehicle(VehicleIdModel(vehicleId: vehicle.vehicleId));

      if (!mounted) {
        return;
      }

      showMessage('Vehicle deleted successfully');

      await loadVehicles();
    } catch (error) {
      if (!mounted) {
        return;
      }

      showMessage(error.toString().replaceFirst('Exception: ', ''));
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> openAllVehiclesScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AllVehiclesScreen(
          vehicles: vehicleList,
          onEditVehicle: showEditVehicleDialog,
          onDeleteVehicle: showDeleteVehicleDialog,
          onRefresh: refreshAndGetVehicles,
        ),
      ),
    );

    await loadVehicles();
  }

  Future<void> openVehicleCategory(String categoryName) async {
    List<VehicleModel> categoryVehicles = vehicleList
        .where((vehicle) => vehicle.vehicleType == categoryName).toList();

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VehicleCategoryListScreen(
          categoryName: categoryName,
          vehicles: categoryVehicles,
          onAddVehicle: openCreateVehicleScreen,
          onEditVehicle: showEditVehicleDialog,
          onDeleteVehicle: showDeleteVehicleDialog,
          onRefresh: refreshAndGetVehicles,
        ),
      ),
    );

    await loadVehicles();
  }

  Widget buildBody() {
    return ManageVehiclesContent(
      vehicleList: vehicleList,
      isLoading: isLoading,
      onRefresh: loadVehicles,
      onOpenAllVehicles: openAllVehiclesScreen,
      onOpenVehicleCategory: openVehicleCategory,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Vehicles'),
      ),
      body: buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: openCreateVehicleScreen,
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
import 'package:flutter/material.dart';

import '../models/vehicle_model.dart';
import '../widgets/manage_vehicles/all_vehicles_content.dart';

class AllVehiclesScreen extends StatefulWidget {
  final List<VehicleModel> vehicles;
  final Future<void> Function(VehicleModel) onEditVehicle;
  final Future<void> Function(VehicleModel) onDeleteVehicle;
  final Future<List<VehicleModel>> Function() onRefresh;

  const AllVehiclesScreen({
    super.key,
    required this.vehicles,
    required this.onEditVehicle,
    required this.onDeleteVehicle,
    required this.onRefresh,
  });

  @override
  State<AllVehiclesScreen> createState() => _AllVehiclesScreenState();
}

class _AllVehiclesScreenState extends State<AllVehiclesScreen> {
  late List<VehicleModel> vehicleList;

  @override
  void initState() {
    super.initState();
    vehicleList = List.from(widget.vehicles);
  }

  Future<void> refreshVehicles() async {
    List<VehicleModel> updatedVehicles = await widget.onRefresh();

    if (!mounted) {
      return;
    }

    setState(() {
      vehicleList = updatedVehicles;
    });
  }

  Future<void> editVehicle(VehicleModel vehicle) async {
    await widget.onEditVehicle(vehicle);

    if (mounted) {
      await refreshVehicles();
    }
  }

  Future<void> deleteVehicle(VehicleModel vehicle) async {
    await widget.onDeleteVehicle(vehicle);

    if (mounted) {
      await refreshVehicles();
    }
  }

  Map<String, List<VehicleModel>> groupVehicles() {
    Map<String, List<VehicleModel>> groupedVehicles = {};

    for (VehicleModel vehicle in vehicleList) {
      groupedVehicles.putIfAbsent(vehicle.vehicleType, () => []);

      groupedVehicles[vehicle.vehicleType]!.add(vehicle);
    }

    return groupedVehicles;
  }

  Widget buildVehicleGroups() {
    return AllVehiclesContent(
      vehicleList: vehicleList,
      onRefresh: refreshVehicles,
      onEditVehicle: editVehicle,
      onDeleteVehicle: deleteVehicle,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Vehicles'),
      ),
      body: buildVehicleGroups(),
    );
  }
}
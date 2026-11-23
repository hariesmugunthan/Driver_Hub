import 'package:flutter/material.dart';

import '../models/vehicle_model.dart';
import '../widgets/manage_vehicles/vehicle_category_list_content.dart';

class VehicleCategoryListScreen extends StatefulWidget {
  final String categoryName;
  final List<VehicleModel> vehicles;
  final Future<void> Function() onAddVehicle;
  final Future<void> Function(VehicleModel) onEditVehicle;
  final Future<void> Function(VehicleModel) onDeleteVehicle;
  final Future<List<VehicleModel>> Function() onRefresh;

  const VehicleCategoryListScreen({
    super.key,
    required this.categoryName,
    required this.vehicles,
    required this.onAddVehicle,
    required this.onEditVehicle,
    required this.onDeleteVehicle,
    required this.onRefresh,
  });

  @override
  State<VehicleCategoryListScreen> createState() => _VehicleCategoryListScreenState();
}

class _VehicleCategoryListScreenState extends State<VehicleCategoryListScreen> {
  late List<VehicleModel> categoryVehicles;

  @override
  void initState() {
    super.initState();
    categoryVehicles = List.from(widget.vehicles);
  }

  Future<void> refreshCategoryVehicles() async {
    List<VehicleModel> updatedVehicles = await widget.onRefresh();

    if (!mounted) {
      return;
    }

    setState(() {
      categoryVehicles = updatedVehicles
          .where((vehicle) => vehicle.vehicleType == widget.categoryName).toList();
    });
  }

  Future<void> addVehicle() async {
    await widget.onAddVehicle();

    if (!mounted) {
      return;
    }

    await refreshCategoryVehicles();
  }

  Future<void> editVehicle(VehicleModel vehicle) async {
    await widget.onEditVehicle(vehicle);

    if (!mounted) {
      return;
    }

    await refreshCategoryVehicles();
  }

  Future<void> deleteVehicle(VehicleModel vehicle) async {
    await widget.onDeleteVehicle(vehicle);

    if (!mounted) {
      return;
    }

    await refreshCategoryVehicles();
  }

  Widget buildBody() {
    return VehicleCategoryListContent(
      categoryName: widget.categoryName,
      categoryVehicles: categoryVehicles,
      onRefresh: refreshCategoryVehicles,
      onAddVehicle: addVehicle,
      onEditVehicle: editVehicle,
      onDeleteVehicle: deleteVehicle,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
      ),
      body: buildBody(),
    );
  }
}
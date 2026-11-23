import 'package:flutter/material.dart';

import '../../models/driver_model.dart';
import 'driver_card.dart';
import 'no_drivers_view.dart';

class ManageDriversContent extends StatelessWidget {
  final List<DriverModel> driverList;
  final bool isLoading;
  final VoidCallback onAddDriver;
  final void Function(DriverModel) onEditDriver;
  final void Function(DriverModel) onDeleteDriver;
  final Future<void> Function() onRefresh;
  final void Function(DriverModel) onViewPerformance;

  const ManageDriversContent({
    super.key,
    required this.driverList,
    required this.isLoading,
    required this.onAddDriver,
    required this.onEditDriver,
    required this.onDeleteDriver,
    required this.onRefresh,
    required this.onViewPerformance,
  });

  Widget buildLoading() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget buildEmptyView() {
    return NoDriversView(onAddDriver: onAddDriver);
  }

  Widget buildDriverList() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ...driverList.map(
          (driver) => DriverCard(
            driver: driver,
            onEdit: () {
              onEditDriver(driver);
            },
            onViewPerformance: () {
              onViewPerformance(driver);
            },
            onDelete: () {
              onDeleteDriver(driver);
            },
          ),
        ),
      ],
    );
  }

  Widget buildBody() {
    if (isLoading) {
      return buildLoading();
    }

    if (driverList.isEmpty) {
      return buildEmptyView();
    }

    return buildDriverList();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: buildBody(),
    );
  }
}

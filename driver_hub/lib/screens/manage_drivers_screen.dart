import 'package:flutter/material.dart';
import 'driver_performance_screen.dart';
import '../controllers/driver_controller.dart';
import '../models/driver_id_model.dart';
import '../models/driver_model.dart';
import '../widgets/manage_drivers/driver_edit_dialog.dart';
import '../widgets/manage_drivers/manage_drivers_content.dart';
import 'create_new_driver_screen.dart';
import '../../configs/app_theme.dart';
class ManageDriversScreen extends StatefulWidget {
  const ManageDriversScreen({super.key});

  @override
  State<ManageDriversScreen> createState() => _ManageDriversScreenState();
}

class _ManageDriversScreenState extends State<ManageDriversScreen> {
  DriverController driverController = DriverController();

  List<DriverModel> driverList = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    loadDrivers();
  }

  Future<void> loadDrivers() async {
    print('[manage_drivers] Loading started');

    setState(() {
      isLoading = true;
    });

    try {
      List<DriverModel> loadedDriverList = await driverController.getAllDrivers();

      print('[manage_drivers] Received drivers: ${loadedDriverList.length}');

      if (!mounted) {
        return;
      }

      setState(() {
        driverList = loadedDriverList;
        isLoading = false;
      });

      print('[manage_drivers] Loading completed');
      print('[manage_drivers] isLoading: $isLoading');
      print('[manage_drivers] driverList length: ${driverList.length}');
    } catch (error) {
      print('[manage_drivers] Error: $error');

      if (!mounted) {
        return;
      }

      setState(() {
        isLoading = false;
      });

      showMessage(error.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> openCreateDriverScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
        const CreateNewDriverScreen(),
      ),
    );

    await loadDrivers();
  }
  Future<void> openDriverPerformanceScreen(DriverModel driver) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DriverPerformanceScreen(
          driver: driver,
        ),
      ),
    );
  }

  Future<void> showDeleteDriverDialog(DriverModel driver) async {
    bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.border, width: 1),
          ),
          title: const Text(
            'Delete Driver',
            style: TextStyle(
              color: AppColors.primaryText,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Are you sure you want to delete ${driver.name}?',
            style: const TextStyle(color: AppColors.secondaryText, fontSize: 16),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          actions: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Cancel button aligned to the right
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                    style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Full-width Delete button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      backgroundColor: Colors.transparent,
                      side: const BorderSide(color: AppColors.error, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      'Delete',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    await deleteDriver(driver);
  }

  Future<void> deleteDriver(DriverModel driver) async {
    try {
      await driverController.deleteDriver(DriverIdModel(userId: driver.userId));

      if (!mounted) {
        return;
      }

      showMessage('Driver deleted successfully');

      await loadDrivers();
    } catch (error) {
      if (!mounted) {
        return;
      }

      showMessage(error.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> showEditDriverDialog(DriverModel driver) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return DriverEditDialog(driver: driver, formatDate: formatDate, onUpdate: updateDriver);
      },
    );
  }

  Future<void> updateDriver(DriverModel driver) async {
    await driverController.updateDriver(driver);

    if (!mounted) {
      return;
    }

    showMessage('Driver updated successfully');

    await loadDrivers();
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  Widget buildBody() {
    return ManageDriversContent(
      driverList: driverList,
      isLoading: isLoading,
      onAddDriver: openCreateDriverScreen,
      onEditDriver: showEditDriverDialog,
      onDeleteDriver: showDeleteDriverDialog,
      onRefresh: loadDrivers,
      onViewPerformance: openDriverPerformanceScreen,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Drivers'),
      ),
      body: buildBody(),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: SizedBox(
          width: 70,
          height: 70,
          child: FloatingActionButton(
            onPressed: openCreateDriverScreen,
            child: const Icon(Icons.add, size: 35),
          ),
        ),
      ),
      floatingActionButtonLocation:
      FloatingActionButtonLocation.endFloat,
    );
  }
}
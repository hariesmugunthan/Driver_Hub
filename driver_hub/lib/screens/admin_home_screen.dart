import 'package:flutter/material.dart';

import '../services/google_auth_service.dart';
import '../widgets/admin_home/admin_home_content.dart';
import 'manage_drivers_screen.dart';
import 'manage_vehicles_screen.dart';
import 'create_new_trip_screen.dart';
import '../models/trip_model.dart';
import 'admin_live_tracking_screen.dart';
import 'trip_stats_screen.dart';
class AdminHomeScreen extends StatelessWidget {
  final String adminName;
  final GoogleAuthService googleAuthService = GoogleAuthService();

  AdminHomeScreen({super.key, required this.adminName});

  Future<void> handleLogout(BuildContext context) async {
    await googleAuthService.signOutFromGoogle();

    if (!context.mounted) {
      return;
    }

    Navigator.popUntil(context, (route) => route.isFirst);
  }

  void openManageDriversScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ManageDriversScreen()),
    );
  }

  void openManageVehiclesScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ManageVehiclesScreen()),
    );
  }

  void openManageTripsScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateNewTripScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Home'),
        actions: [
          IconButton(onPressed: () => handleLogout(context), icon: const Icon(Icons.logout)),
        ],
      ),
      body: AdminHomeContent(
        adminName: adminName,
        openManageDriversScreen: () {
          openManageDriversScreen(context);
        },
        openManageVehiclesScreen: () {
          openManageVehiclesScreen(context);
        },
        openManageTripsScreen: () {
          openManageTripsScreen(context);
        },
        openEditTripScreen: (trip) {
          return openEditTripScreen(context, trip);
        },
        openLiveTrackingScreen: (trip) {
          openAdminLiveTrackingScreen(context, trip);
        },
        openTripStatsScreen: (trip) {
          openTripStatsScreen(context, trip);
        },
      ),
    );
  }

  Future<bool?> openEditTripScreen(BuildContext context, TripModel trip) {
    return Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => CreateNewTripScreen(trip: trip)),
    );
  }

  void openAdminLiveTrackingScreen(BuildContext context, TripModel trip) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminLiveTrackingScreen(trip: trip),
      ),
    );
  }
  void openTripStatsScreen(BuildContext context, TripModel trip) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TripStatsScreen(trip: trip),
      ),
    );
  }
}

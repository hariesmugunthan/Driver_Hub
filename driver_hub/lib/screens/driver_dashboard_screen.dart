import 'package:flutter/material.dart';
import '../controllers/driver_language_controller.dart';
import '../l10n/app_localizations.dart';
import '../controllers/trip_controller.dart';
import '../models/driver_model.dart';
import '../models/trip_model.dart';
import '../widgets/driver_dashboard/driver_dashboard_content.dart';

class DriverDashboardScreen extends StatefulWidget {
  final DriverModel driver;
  final DriverLanguageController driverLanguageController;

  const DriverDashboardScreen({
    super.key,
    required this.driver,
    required this.driverLanguageController,
  });

  @override
  State<DriverDashboardScreen> createState() => _DriverDashboardScreenState();
}

class _DriverDashboardScreenState extends State<DriverDashboardScreen> {
  TripController tripController = TripController();

  List<TripModel> tripList = [];

  bool isLoading = true;
  String? errorMessage;

  String selectedFilter = 'All Trips';

  @override
  void initState() {
    super.initState();
    getDriverTrips();
  }

  Future<void> getDriverTrips() async {
    try {
      List<TripModel> trips = await tripController.getTripsByDriverId(widget.driver.userId);

      if (!mounted) return;

      setState(() {
        tripList = trips;
        isLoading = false;
        errorMessage = null;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = error.toString();
      });
    }
  }

  List<TripModel> get filteredTrips {
    if (selectedFilter == 'Upcoming') {
      return tripList.where((trip) => trip.status == 'scheduled').toList();
    }

    if (selectedFilter == 'Completed') {
      return tripList.where((trip) => trip.status == 'completed').toList();
    }

    return tripList;
  }

  Widget buildFilterButton(String filter) {
    bool isSelected = selectedFilter == filter;

    return ChoiceChip(
      label: Text(filter),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          selectedFilter = filter;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).driverDashboard),
        automaticallyImplyLeading: false,
        actions: [
          PopupMenuButton<Locale>(
            icon: const Icon(Icons.language),
            tooltip: 'Change language',
            onSelected: (Locale locale) async {
              await widget.driverLanguageController.changeLanguage(locale);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: Locale('en'), child: Text('English')),
              const PopupMenuItem(value: Locale('ta'), child: Text('தமிழ்')),
            ],
          ),
        ],
      ),
      body: DriverDashboardContent(
        driver: widget.driver,
        filteredTrips: filteredTrips,
        isLoading: isLoading,
        errorMessage: errorMessage,
        selectedFilter: selectedFilter,
        onFilterChanged: (filter) {
          setState(() {
            selectedFilter = filter;
          });
        },
        onRefresh: getDriverTrips,
      ),
    );
  }
}
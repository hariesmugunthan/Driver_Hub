import 'package:flutter/material.dart';

import '../../configs/app_theme.dart';
import '../../controllers/trip_controller.dart';
import '../../models/trip_model.dart';
import 'admin_home_action_button.dart';
import 'admin_trip_card.dart';

class AdminHomeContent extends StatefulWidget {
  final String adminName;
  final VoidCallback openManageDriversScreen;
  final VoidCallback openManageVehiclesScreen;
  final VoidCallback openManageTripsScreen;
  final Future<bool?> Function(TripModel trip) openEditTripScreen;
  final ValueChanged<TripModel> openLiveTrackingScreen;
  final ValueChanged<TripModel> openTripStatsScreen;
  const AdminHomeContent({
    super.key,
    required this.adminName,
    required this.openManageDriversScreen,
    required this.openManageVehiclesScreen,
    required this.openManageTripsScreen,
    required this.openEditTripScreen,
    required this.openLiveTrackingScreen,
    required this.openTripStatsScreen,
  });

  @override
  State<AdminHomeContent> createState() => _AdminHomeContentState();
}

class _AdminHomeContentState extends State<AdminHomeContent> {
  TripController tripController = TripController();

  List<TripModel> tripList = [];

  bool isLoading = true;
  String? errorMessage;

  String selectedFilter = 'All';

  final List<String> tripFilters = ['All', 'Scheduled', 'In Progress', 'Completed', 'Cancelled'];

  @override
  void initState() {
    super.initState();
    getAllTrips();
  }

  Future<void> getAllTrips() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      List<TripModel> trips = await tripController.getAllTrips();

      if (!mounted) return;

      setState(() {
        tripList = trips;
        isLoading = false;
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
    if (selectedFilter == 'All') {
      return tripList;
    }

    String status;

    switch (selectedFilter) {
      case 'Scheduled':
        status = 'scheduled';
        break;

      case 'In Progress':
        status = 'inProgress';
        break;

      case 'Completed':
        status = 'completed';
        break;

      case 'Cancelled':
        status = 'cancelled';
        break;

      default:
        return tripList;
    }

    return tripList.where((trip) => trip.status == status).toList();
  }

  Widget buildWelcomeSection(BuildContext context) {
    String initial = widget.adminName.isNotEmpty ? widget.adminName[0].toUpperCase() : 'A';

    return Row(
      children: [
        CircleAvatar(
          radius: 38,
          backgroundColor: AppColors.primary,
          child: Text(initial, style: const TextStyle(fontSize: 28, color: AppColors.primaryText)),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome,',
                style: TextStyle(fontSize: 18, color: AppColors.secondaryText),
              ),
              const SizedBox(height: 2),
              Text(
                widget.adminName,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildDashboardTitle(BuildContext context) {
    return Text(
      'Admin Dashboard',
      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget buildManagementCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 180,
                child: AdminHomeActionButton(
                  title: 'Manage Drivers',
                  description: 'Add and manage drivers',
                  icon: Icons.people_alt_outlined,
                  onPressed: widget.openManageDriversScreen,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 180,
                child: AdminHomeActionButton(
                  title: 'Manage Vehicles',
                  description: 'Manage your fleet',
                  icon: Icons.directions_car_outlined,
                  onPressed: widget.openManageVehiclesScreen,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 112,
          child: AdminHomeActionButton(
            title: 'Create New Trip',
            description: 'Plan and assign a new trip',
            icon: Icons.add_road_outlined,
            isHorizontal: true,
            onPressed: widget.openManageTripsScreen,
          ),
        ),
      ],
    );
  }

  Widget buildTripFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: tripFilters.map((filter) {
          bool isSelected = selectedFilter == filter;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filter),
              selected: isSelected,
              showCheckmark: false,
              onSelected: (selected) {
                setState(() {
                  selectedFilter = filter;
                });
              },
              backgroundColor: Colors.transparent,
              selectedColor: AppColors.primary,
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              labelStyle: TextStyle(
                fontSize: 15,
                color: isSelected ? Colors.white : AppColors.secondaryText,
                fontWeight: FontWeight.w500,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget buildTripOverviewSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trip Overview',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          'View and monitor all your trips by status.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        buildTripFilters(),
        const SizedBox(height: 16),
        if (isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          )
        else if (errorMessage != null)
          Center(
            child: Column(
              children: [
                Text(errorMessage!, textAlign: TextAlign.center),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: getAllTrips,
                  child: const Text('Retry'),
                ),
              ],
            ),
          )
        else if (filteredTrips.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                selectedFilter == 'All'
                    ? 'No trips available.'
                    : 'No ${selectedFilter.toLowerCase()} trips found.',
              ),
            ),
          )
        else
          Column(
            children: filteredTrips.map((trip) {
              return buildTripCard(trip);
            }).toList(),
          ),
      ],
    );
  }

  Widget buildTripCard(TripModel trip) {
    return AdminTripCard(
      trip: trip,
      onEdit: () async {
        bool? isUpdated = await widget.openEditTripScreen(trip);

        if (isUpdated == true) {
          await getAllTrips();
        }
      },
      onDelete: () {
        confirmAndDeleteTrip(trip);
      },
      onLiveTracking: () {
        widget.openLiveTrackingScreen(trip);
      },
      onViewStats: () {
        widget.openTripStatsScreen(trip);
      },
    );
  }

  Widget buildTripActionButton(TripModel trip) {
    String buttonText;
    IconData buttonIcon;
    bool isScheduled = false;

    switch (trip.status) {
      case 'scheduled':
        buttonText = 'Live Tracking';
        buttonIcon = Icons.location_searching;
        isScheduled = true;
        break;

      case 'inProgress':
        buttonText = 'Live Tracking';
        buttonIcon = Icons.map_outlined;
        break;

      case 'completed':
      case 'cancelled':
        buttonText = 'Stats';
        buttonIcon = Icons.analytics_outlined;
        break;

      default:
        return const SizedBox.shrink();
    }

    return OutlinedButton.icon(
      onPressed: isScheduled ? showTripNotStartedMessage : null,
      icon: Icon(buttonIcon),
      label: Text(buttonText),
    );
  }

  void showTripNotStartedMessage() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Trip Not Started'),
          content: const Text(
            'The trip has not started yet. Live tracking will be '
            'available once the driver starts the trip.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  String formatDate(DateTime date) {
    String day = date.day.toString().padLeft(2, '0');
    String month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  String formatTime(DateTime date) {
    String hour = date.hour.toString().padLeft(2, '0');
    String minute = date.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'scheduled':
        return Colors.blue;
      case 'inProgress':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: getAllTrips,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildWelcomeSection(context),
            const SizedBox(height: 32),
            buildDashboardTitle(context),
            const SizedBox(height: 20),
            buildManagementCards(),
            const SizedBox(height: 32),
            buildTripOverviewSection(context),
          ],
        ),
      ),
    );
  }

  Future<void> confirmAndDeleteTrip(TripModel trip) async {
    bool? isConfirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Trip?'),
          content: const Text(
            'Are you sure you want to delete this trip? '
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (isConfirmed != true || !mounted) {
      return;
    }

    try {
      await tripController.deleteTrip(trip.tripId);

      if (!mounted) return;

      await getAllTrips();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trip deleted successfully')),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    }
  }
}

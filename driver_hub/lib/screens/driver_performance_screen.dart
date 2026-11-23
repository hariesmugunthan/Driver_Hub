import 'package:flutter/material.dart';
import 'driver_trip_history_screen.dart';
import '../configs/app_theme.dart';
import '../controllers/driver_performance_controller.dart';
import '../models/driver_model.dart';
import '../models/driver_performance_model.dart';

class DriverPerformanceScreen extends StatefulWidget {
  final DriverModel driver;

  const DriverPerformanceScreen({super.key, required this.driver});

  @override
  State<DriverPerformanceScreen> createState() => _DriverPerformanceScreenState();
}

class _DriverPerformanceScreenState extends State<DriverPerformanceScreen> {
  final DriverPerformanceController performanceController = DriverPerformanceController();

  @override
  void initState() {
    super.initState();

    performanceController.addListener(handleControllerUpdate);

    loadPerformance();
  }
  void openTripHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DriverTripHistoryScreen(
          driverId: widget.driver.userId,
          driverName: widget.driver.name,
        ),
      ),
    );
  }

  void loadPerformance() {
    performanceController.loadPerformance(widget.driver.userId);
  }

  void handleControllerUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    performanceController.removeListener(handleControllerUpdate);
    performanceController.dispose();

    super.dispose();
  }

  String formatHours(double hours) {
    int totalMinutes = (hours * 60).round();
    int wholeHours = totalMinutes ~/ 60;
    int remainingMinutes = totalMinutes % 60;

    if (wholeHours == 0) {
      return '$remainingMinutes min';
    }

    if (remainingMinutes == 0) {
      return '$wholeHours hr';
    }

    return '$wholeHours hr $remainingMinutes min';
  }

  Widget buildPerformanceCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
  }) {
    return Card(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(height: 18),
            Text(
              value,
              style: const TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 5),
            Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.secondaryText)),
          ],
        ),
      ),
    );
  }

  Widget buildPerformanceGrid(DriverPerformanceModel performance) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      mainAxisExtent: 230,
      children: [
        buildPerformanceCard(
          title: 'Completed Trips',
          value: '${performance.completedTrips}',
          subtitle: 'Out of ${performance.totalAssignedTrips} assigned trips',
          icon: Icons.check_circle_outline,
          iconColor: AppColors.success,
        ),
        buildPerformanceCard(
          title: 'Planned Route Distance',
          value: '${performance.totalDistanceKilometers} km',
          subtitle: 'Total distance of completed trips',
          icon: Icons.route,
          iconColor: AppColors.primary,
        ),
        buildPerformanceCard(
          title: 'Total Driving Hours',
          value: formatHours(performance.totalDrivingHours),
          subtitle: 'Based on actual trip times',
          icon: Icons.access_time,
          iconColor: AppColors.accent,
        ),
        buildPerformanceCard(
          title: 'Average Trip Distance',
          value: '${performance.averageTripDistanceKilometers} km',
          subtitle: 'Per completed trip',
          icon: Icons.social_distance,
          iconColor: AppColors.warning,
        ),
        buildPerformanceCard(
          title: 'Average Trip Duration',
          value: formatHours(performance.averageTripDurationHours),
          subtitle: 'Per completed trip',
          icon: Icons.timer_outlined,
          iconColor: Colors.purpleAccent,
        ),
        buildPerformanceCard(
          title: 'Completion Rate',
          value: '${performance.completionRate}%',
          subtitle: 'Completed / assigned trips',
          icon: Icons.trending_up,
          iconColor: AppColors.success,
        ),
      ],
    );
  }

  Widget buildLoading() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 48),
            const SizedBox(height: 16),
            Text(
              performanceController.errorMessage ??
                  'Unable to load driver performance',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.primaryText, fontSize: 15),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: loadPerformance,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildContent() {
    if (performanceController.isLoading) {
      return buildLoading();
    }

    if (performanceController.errorMessage != null) {
      return buildError();
    }

    final performance = performanceController.performance;

    if (performance == null) {
      return const Center(
        child: Text(
          'No performance data available',
          style: TextStyle(color: AppColors.secondaryText),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.driver.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Driver ID: ${widget.driver.userId}',
            style: const TextStyle(fontSize: 13, color: AppColors.secondaryText),
          ),
          const SizedBox(height: 24),
// Trip History Section
          const Text(
            'Trip History',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: openTripHistory,
              icon: const Icon(Icons.history),
              label: const Text('View Trip History'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryText,
                side: const BorderSide(color: AppColors.border),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'Performance Overview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 14),
          buildPerformanceGrid(performance),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Performance'),
      ),
      body: buildContent(),
    );
  }
}
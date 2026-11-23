import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../models/driver_model.dart';
import '../../models/trip_model.dart';
import 'driver_trip_card.dart';

const Color _backgroundColor = Color(0xFF0F172A);
const Color _cardColor = Color(0xFF1E293B);
const Color _borderColor = Color(0x1AFFFFFF);
const Color _accentColor = Color(0xFF3B82F6);
const Color _primaryTextColor = Color(0xFFF1F5F9);
const Color _mutedTextColor = Color(0xFF94A3B8);

class DriverDashboardContent extends StatelessWidget {
  final DriverModel driver;
  final List<TripModel> filteredTrips;
  final bool isLoading;
  final String? errorMessage;
  final String selectedFilter;
  final void Function(String) onFilterChanged;
  final Future<void> Function() onRefresh;

  const DriverDashboardContent({
    super.key,
    required this.driver,
    required this.filteredTrips,
    required this.isLoading,
    required this.errorMessage,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.onRefresh,
  });

  Widget buildDriverHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _accentColor, width: 2),
            ),
            child: const CircleAvatar(
              radius: 30,
              backgroundColor: _primaryTextColor,
              child: Icon(Icons.person, size: 34, color: _backgroundColor),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.welcome, style: const TextStyle(fontSize: 13, color: _mutedTextColor)),
                const SizedBox(height: 4),
                Text(
                  driver.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: _primaryTextColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFilterButton(String filter, String label) {
    bool isSelected = selectedFilter == filter;

    return Material(
      color: isSelected ? _accentColor : Colors.transparent,
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        borderRadius: BorderRadius.circular(9),
        onTap: () {
          onFilterChanged(filter);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSelected) ...[
                const Icon(Icons.check, size: 14, color: Colors.white),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                maxLines: 1,
                softWrap: false,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? Colors.white : _mutedTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildFilterSection(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.myTrips,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: _primaryTextColor,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(color: _cardColor, borderRadius: BorderRadius.circular(12)),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                buildFilterButton('All Trips', l10n.allTrips),
                const SizedBox(width: 4),
                buildFilterButton('Upcoming', l10n.upcoming),
                const SizedBox(width: 4),
                buildFilterButton('Completed', l10n.completed),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildTripListSection(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          children: [
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _mutedTextColor),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: onRefresh,
              child: Text(l10n.retry),
            ),
          ],
        ),
      );
    }

    if (filteredTrips.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(l10n.noTripsFound, style: const TextStyle(color: _mutedTextColor)),
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredTrips.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        TripModel trip = filteredTrips[index];

        return DriverTripCard(trip: trip, onTripActionCompleted: onRefresh);
      },
    );
  }

  Widget buildBody(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildDriverHeader(context),
        const SizedBox(height: 24),
        buildFilterSection(context),
        const SizedBox(height: 16),
        buildTripListSection(context),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: buildBody(context),
      ),
    );
  }
}
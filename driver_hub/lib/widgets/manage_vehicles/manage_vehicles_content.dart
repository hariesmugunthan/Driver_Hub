import 'package:flutter/material.dart';

import '../../configs/app_theme.dart';
import '../../configs/vehicle_categories.dart';
import '../../models/vehicle_model.dart';
import 'vehicle_category_card.dart';

class ManageVehiclesContent extends StatelessWidget {
  final List<VehicleModel> vehicleList;
  final bool isLoading;
  final Future<void> Function() onRefresh;
  final VoidCallback onOpenAllVehicles;
  final void Function(String categoryName) onOpenVehicleCategory;

  const ManageVehiclesContent({
    super.key,
    required this.vehicleList,
    required this.isLoading,
    required this.onRefresh,
    required this.onOpenAllVehicles,
    required this.onOpenVehicleCategory,
  });

  Widget buildAllVehiclesCard(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpenAllVehicles,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.directions_car, size: 30, color: AppColors.secondary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('All Vehicles', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 5),
                    Text(
                      '${vehicleList.length} vehicles • View grouped list',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 18, color: AppColors.secondaryText),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCategorySection(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      sliver: SliverToBoxAdapter(
        child: Text('Vehicle Categories', style: Theme.of(context).textTheme.titleLarge),
      ),
    );
  }

  Widget buildCategoryGrid() {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            Map<String, dynamic> category = VehicleCategories.categories[index];

            String categoryName = category['name'] as String;

            int vehicleCount = vehicleList
                .where((vehicle) => vehicle.vehicleType == categoryName)
                .length;

            return VehicleCategoryCard(
              categoryName: categoryName,
              vehicleCount: vehicleCount,
              categoryIcon: category['icon'] as IconData,
              onTap: () {
                onOpenVehicleCategory(categoryName);
              },
            );
          },
          childCount: VehicleCategories.categories.length,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
      ),
    );
  }

  Widget buildBody(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            sliver: SliverToBoxAdapter(
              child: buildAllVehiclesCard(context),
            ),
          ),
          buildCategorySection(context),
          buildCategoryGrid(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildBody(context);
  }
}

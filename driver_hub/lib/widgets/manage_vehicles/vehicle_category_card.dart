import 'package:flutter/material.dart';

import '../../configs/app_theme.dart';

class VehicleCategoryCard extends StatelessWidget {
  final String categoryName;
  final int vehicleCount;
  final IconData categoryIcon;
  final VoidCallback onTap;

  const VehicleCategoryCard({
    super.key,
    required this.categoryName,
    required this.vehicleCount,
    required this.categoryIcon,
    required this.onTap,
  });

  Widget buildIcon() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(categoryIcon, size: 30, color: AppColors.secondary),
    );
  }

  Widget buildCategoryTitle(BuildContext context) {
    return Text(
      categoryName,
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.titleMedium,
    );
  }

  Widget buildVehicleCount(BuildContext context) {
    return Text('$vehicleCount Vehicles', style: Theme.of(context).textTheme.bodySmall);
  }

  Widget buildArrowIcon() {
    return const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.secondaryText);
  }

  Widget buildCardContent(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buildIcon(),
        const SizedBox(height: 14),
        buildCategoryTitle(context),
        const SizedBox(height: 6),
        buildVehicleCount(context),
        const SizedBox(height: 8),
        buildArrowIcon(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: buildCardContent(context),
        ),
      ),
    );
  }
}
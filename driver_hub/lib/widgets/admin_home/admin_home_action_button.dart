import 'package:flutter/material.dart';

import '../../configs/app_theme.dart';

class AdminHomeActionButton extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isHorizontal;

  const AdminHomeActionButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.description = '',
    this.icon = Icons.dashboard_outlined,
    this.isHorizontal = false,
  });

  Widget buildIconBadge() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(20)),
      child: Icon(icon, color: Colors.white, size: 30),
    );
  }

  Widget buildCardContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        if (description.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.secondaryText),
          ),
        ],
      ],
    );
  }

  Widget buildVerticalLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [buildIconBadge(), const Spacer(), buildCardContent(context)],
    );
  }

  Widget buildHorizontalLayout(BuildContext context) {
    return Row(
      children: [
        buildIconBadge(),
        const SizedBox(width: 16),
        Expanded(child: buildCardContent(context)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: isHorizontal ? buildHorizontalLayout(context) : buildVerticalLayout(context),
        ),
      ),
    );
  }
}

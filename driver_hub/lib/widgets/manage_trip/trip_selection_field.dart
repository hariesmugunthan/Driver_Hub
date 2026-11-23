import 'package:flutter/material.dart';

import '../../configs/app_theme.dart';

class TripSelectionField extends StatelessWidget {
  final String label;
  final String placeholder;
  final String? selectedValue;
  final String? subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool isLoading;
  final bool isEnabled;

  const TripSelectionField({
    super.key,
    required this.label,
    required this.placeholder,
    required this.selectedValue,
    required this.icon,
    required this.onTap,
    required this.isLoading,
    this.subtitle,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label == 'Driver Selection' ? 'Driver' : 'Vehicle',
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.secondaryText,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: isEnabled && !isLoading ? onTap : null,
          borderRadius: BorderRadius.circular(22),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 66),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppColors.secondary, size: 22),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        selectedValue ?? placeholder,
                        style: TextStyle(
                          fontSize: 16,
                          color: selectedValue == null
                              ? AppColors.secondaryText
                              : AppColors.primaryText,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ],
                  ),
                ),
                if (isLoading)
                  const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  const Icon(Icons.keyboard_arrow_down, color: AppColors.secondaryText),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

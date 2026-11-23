import 'package:flutter/material.dart';

import '../../configs/app_theme.dart';

class TripDescriptionField extends StatelessWidget {
  final TextEditingController controller;
  final bool isEnabled;

  const TripDescriptionField({
    super.key,
    required this.controller,
    required this.isEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Trip description (optional)',
          style: TextStyle(fontSize: 14, color: AppColors.secondaryText),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: 4,
          minLines: 3,
          enabled: isEnabled,
          style: const TextStyle(fontSize: 16, color: AppColors.primaryText),
          decoration: InputDecoration(
            hintText: 'Add notes for the driver',
            hintStyle: const TextStyle(color: AppColors.secondaryText, fontSize: 16),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.all(20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(22),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(22),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(22),
              borderSide: const BorderSide(color: AppColors.secondary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

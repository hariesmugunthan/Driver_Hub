import 'package:flutter/material.dart';

import '../../configs/app_theme.dart';

class CreateTripButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const CreateTripButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 80,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          disabledBackgroundColor: AppColors.secondary.withValues(alpha: 0.5),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        ),
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : const Text(
                'Create trip',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
      ),
    );
  }
}

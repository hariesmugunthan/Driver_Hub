import 'package:flutter/material.dart';

import '../../configs/app_theme.dart';

class TripFormActions extends StatelessWidget {
  final bool isEditMode;
  final bool isSaving;
  final bool canCancelTrip;
  final VoidCallback onCreate;
  final VoidCallback onUpdate;
  final VoidCallback onCancel;

  const TripFormActions({
    super.key,
    required this.isEditMode,
    required this.isSaving,
    required this.canCancelTrip,
    required this.onCreate,
    required this.onUpdate,
    required this.onCancel,
  });

  // DESIGN VALUES

  static const double _buttonHeight = 48;
  static const double _radius = 12;

  Widget _spinner() {
    return const SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
    );
  }

  Widget _primaryButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: _buttonHeight,
      child: ElevatedButton(
        onPressed: isSaving ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
          disabledForegroundColor: Colors.white70,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_radius)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
        child: isSaving ? _spinner() : Text(label),
      ),
    );
  }

  Widget buildCreateButton() {
    return _primaryButton(label: 'Create trip', onPressed: onCreate);
  }

  Widget buildUpdateButton() {
    return _primaryButton(label: 'Update trip', onPressed: onUpdate);
  }

  Widget buildCancelButton() {
    return SizedBox(
      width: double.infinity,
      height: _buttonHeight,
      child: OutlinedButton(
        onPressed: isSaving ? null : onCancel,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: BorderSide(color: AppColors.error.withValues(alpha: 0.6)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_radius)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
        child: const Text('Cancel trip'),
      ),
    );
  }

  Widget buildEditActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        buildUpdateButton(),
        if (canCancelTrip) ...[const SizedBox(height: 10), buildCancelButton()],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!isEditMode) {
      return buildCreateButton();
    }

    return buildEditActions();
  }
}
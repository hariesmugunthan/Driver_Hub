import 'package:flutter/material.dart';

import '../../configs/app_theme.dart';

class TripLocationFields extends StatelessWidget {
  final TextEditingController startLocationController;
  final TextEditingController endLocationController;
  final TextEditingController startLatitudeController;
  final TextEditingController startLongitudeController;
  final TextEditingController endLatitudeController;
  final TextEditingController endLongitudeController;
  final bool isEnabled;

  final String? Function(String?) validateRequiredField;
  final String? Function(String?, double, double, String) validateCoordinate;

  final VoidCallback onStartCoordinatesPressed;
  final VoidCallback onEndCoordinatesPressed;

  const TripLocationFields({
    super.key,
    required this.startLocationController,
    required this.endLocationController,
    required this.startLatitudeController,
    required this.startLongitudeController,
    required this.endLatitudeController,
    required this.endLongitudeController,
    required this.validateRequiredField,
    required this.validateCoordinate,
    required this.onStartCoordinatesPressed,
    required this.onEndCoordinatesPressed,
    required this.isEnabled,
  });

  // DESIGN VALUES
  // Sizes match the Driver / Vehicle dropdowns. To make every field
  // compact later, change these values together with the dropdowns.

  static const double _fieldRadius = 22;
  static const double _buttonRadius = 20;
  static const double _labelSize = 14;
  static const double _inputTextSize = 16;
  static const double _inputPaddingH = 20;
  static const double _inputPaddingV = 20;
  static const double _buttonHeight = 52;

  static const double _railWidth = 20;
  static const double _railGap = 14;
  static const double _blockGap = 20;

  static const Color _startColor = Color(0xFF28C99A);
  static const Color _endColor = Color(0xFFE45B5B);

  OutlineInputBorder _border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(_fieldRadius),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  // LOCATION TEXT FIELD

  Widget _locationInput({
    required String label,
    required String hint,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: _labelSize, color: AppColors.secondaryText)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validateRequiredField,
          enabled: isEnabled,
          style: const TextStyle(fontSize: _inputTextSize, color: AppColors.primaryText),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.secondaryText, fontSize: _inputTextSize),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: _inputPaddingH,
              vertical: _inputPaddingV,
            ),
            border: _border(AppColors.border),
            enabledBorder: _border(AppColors.border),
            disabledBorder: _border(AppColors.border),
            focusedBorder: _border(AppColors.secondary, width: 1.5),
            errorBorder: _border(AppColors.error),
            focusedErrorBorder: _border(AppColors.error, width: 1.5),
          ),
        ),
      ],
    );
  }

  // SET COORDINATES BUTTON

  Widget _coordinateButton({
    required String fieldKey,
    required String label,
    required TextEditingController latitudeController,
    required TextEditingController longitudeController,
    required VoidCallback onPressed,
  }) {
    final isSelected = latitudeController.text.isNotEmpty && longitudeController.text.isNotEmpty;

    return FormField<bool>(
      key: ValueKey('$fieldKey-$isSelected'),
      initialValue: isSelected,
      validator: (_) {
        final latitudeError = validateCoordinate(latitudeController.text, -90, 90, 'Latitude');

        if (latitudeError != null) return latitudeError;

        return validateCoordinate(longitudeController.text, -180, 180, 'Longitude');
      },
      builder: (field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              height: _buttonHeight,
              child: OutlinedButton.icon(
                onPressed: isEnabled ? onPressed : null,
                icon: const Icon(Icons.location_on_outlined, size: 21),
                label: Text(
                  label,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryText,
                  side: BorderSide(
                    color: isSelected
                        ? AppColors.success.withValues(alpha: 0.6)
                        : AppColors.border,
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_buttonRadius)),
                ),
              ),
            ),
            if (isSelected)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: AppColors.success, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Coordinates selected',
                      style: TextStyle(color: AppColors.success, fontSize: 12),
                    ),
                  ],
                ),
              ),
            if (field.errorText != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  field.errorText!,
                  style: TextStyle(color: Theme.of(field.context).colorScheme.error, fontSize: 12),
                ),
              ),
          ],
        );
      },
    );
  }

  // INPUT + COORDINATE BUTTON BLOCK

  Widget _locationBlock({
    required String fieldKey,
    required String label,
    required String hint,
    required String coordinatesLabel,
    required TextEditingController locationController,
    required TextEditingController latitudeController,
    required TextEditingController longitudeController,
    required VoidCallback onCoordinatesPressed,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _locationInput(label: label, hint: hint, controller: locationController),
        const SizedBox(height: 12),
        _coordinateButton(
          fieldKey: fieldKey,
          label: coordinatesLabel,
          latitudeController: latitudeController,
          longitudeController: longitudeController,
          onPressed: onCoordinatesPressed,
        ),
      ],
    );
  }

  // TIMELINE RAIL

  // Green dot with a dotted line that runs down to the end marker.
  Widget _startRail() {
    return SizedBox(
      width: _railWidth,
      child: Column(
        children: [
          const SizedBox(height: 2),
          Container(
            width: 14,
            height: 14,
            decoration: const BoxDecoration(color: _startColor, shape: BoxShape.circle),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: CustomPaint(size: const Size(_railWidth, 0), painter: _DottedLinePainter()),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  // Red flag marking the destination.
  Widget _endRail() {
    return const SizedBox(
      width: _railWidth,
      child: Align(
        alignment: Alignment.topCenter,
        child: Icon(Icons.flag_rounded, size: 20, color: _endColor),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _startRail(),
              const SizedBox(width: _railGap),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: _blockGap),
                  child: _locationBlock(
                    fieldKey: 'start_coordinates',
                    label: 'Start location',
                    hint: 'Enter start location',
                    coordinatesLabel: 'Set starting coordinates',
                    locationController: startLocationController,
                    latitudeController: startLatitudeController,
                    longitudeController: startLongitudeController,
                    onCoordinatesPressed: onStartCoordinatesPressed,
                  ),
                ),
              ),
            ],
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _endRail(),
            const SizedBox(width: _railGap),
            Expanded(
              child: _locationBlock(
                fieldKey: 'end_coordinates',
                label: 'End location',
                hint: 'Enter end location',
                coordinatesLabel: 'Set ending coordinates',
                locationController: endLocationController,
                latitudeController: endLatitudeController,
                longitudeController: endLongitudeController,
                onCoordinatesPressed: onEndCoordinatesPressed,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.secondaryText.withValues(alpha: 0.6)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    const dash = 4.0;
    const gap = 5.0;

    double y = 0;

    while (y < size.height) {
      final end = (y + dash) > size.height ? size.height : y + dash;

      canvas.drawLine(Offset(size.width / 2, y), Offset(size.width / 2, end), paint);

      y += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
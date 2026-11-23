import 'package:flutter/material.dart';

import '../../configs/app_theme.dart';
import '../../controllers/create_trip_controller.dart';
import 'trip_description_field.dart';
import 'trip_driver_selection.dart';
import 'trip_form_actions.dart';
import 'trip_location_fields.dart';
import 'trip_vehicle_selection.dart';

class ManageTripContent extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final CreateTripController createTripController;
  final TextEditingController startLocationController;
  final TextEditingController endLocationController;
  final TextEditingController startLatitudeController;
  final TextEditingController startLongitudeController;
  final TextEditingController endLatitudeController;
  final TextEditingController endLongitudeController;
  final TextEditingController descriptionController;
  final bool isEditMode;
  final bool canCancelTrip;
  final String? Function(String?) validateRequiredField;
  final String? Function(String?, double, double, String) validateCoordinate;
  final VoidCallback onCreate;
  final VoidCallback onUpdate;
  final VoidCallback onCancel;
  final VoidCallback onStartCoordinatesPressed;
  final VoidCallback onEndCoordinatesPressed;

  const ManageTripContent({
    super.key,
    required this.formKey,
    required this.createTripController,
    required this.startLocationController,
    required this.endLocationController,
    required this.startLatitudeController,
    required this.startLongitudeController,
    required this.endLatitudeController,
    required this.endLongitudeController,
    required this.descriptionController,
    required this.isEditMode,
    required this.canCancelTrip,
    required this.validateRequiredField,
    required this.validateCoordinate,
    required this.onCreate,
    required this.onUpdate,
    required this.onCancel,
    required this.onStartCoordinatesPressed,
    required this.onEndCoordinatesPressed,
  });

  Widget buildSectionTitle(String title, IconData icon) {
    return Transform.translate(
      offset: const Offset(-18.5, 0),
      child: Row(
        children: [
          Icon(icon, size: 22, color: AppColors.secondary),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildAvailabilityLoading() {
    if (!createTripController.isLoadingAvailability) {
      return const SizedBox.shrink();
    }

    return const Padding(
      padding: EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 12),
          Expanded(child: Text('Checking available drivers and vehicles...')),
        ],
      ),
    );
  }

  Widget buildDriverSelection(bool enabled) {
    return TripDriverSelection(
      selectedDriver: createTripController.selectedDriver,
      availableDrivers: createTripController.availableDrivers,
      isEnabled: enabled,
      onDriverSelected: createTripController.selectDriver,
    );
  }

  Widget buildVehicleSelection(bool enabled) {
    return TripVehicleSelection(
      selectedVehicle: createTripController.selectedVehicle,
      availableVehicles: createTripController.availableVehicles,
      isEnabled: enabled,
      onVehicleSelected: createTripController.selectVehicle,
    );
  }

  Widget buildLocationFields() {
    return TripLocationFields(
      startLocationController: startLocationController,
      endLocationController: endLocationController,
      startLatitudeController: startLatitudeController,
      startLongitudeController: startLongitudeController,
      endLatitudeController: endLatitudeController,
      endLongitudeController: endLongitudeController,
      validateRequiredField: validateRequiredField,
      validateCoordinate: validateCoordinate,
      onStartCoordinatesPressed: onStartCoordinatesPressed,
      onEndCoordinatesPressed: onEndCoordinatesPressed,
      isEnabled: !createTripController.isSavingTrip,
    );
  }

  Widget buildDescriptionField() {
    return TripDescriptionField(
      controller: descriptionController,
      isEnabled: !createTripController.isSavingTrip,
    );
  }

  Widget buildFormActions() {
    return TripFormActions(
      isEditMode: isEditMode,
      isSaving: createTripController.isSavingTrip,
      canCancelTrip: canCancelTrip,
      onCreate: onCreate,
      onUpdate: onUpdate,
      onCancel: onCancel,
    );
  }

  Widget buildForm(BuildContext context, bool canSelectResources) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(32, 32, 32, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildSectionTitle('Trip details', Icons.assignment_outlined),
                  const SizedBox(height: 24),

                  buildAvailabilityLoading(),

                  buildDriverSelection(canSelectResources),
                  const SizedBox(height: 22),

                  buildVehicleSelection(canSelectResources),
                  const SizedBox(height: 36),

                  const Divider(color: AppColors.border),
                  const SizedBox(height: 32),

                  buildSectionTitle('Route', Icons.alt_route),
                  const SizedBox(height: 24),

                  buildLocationFields(),

                  const SizedBox(height: 32),
                  const Divider(color: AppColors.border),
                  const SizedBox(height: 32),

                  buildSectionTitle('Additional information', Icons.description_outlined),
                  const SizedBox(height: 24),

                  buildDescriptionField(),
                ],
              ),
            ),
          ),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(32, 16, 32, 24),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: buildFormActions(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: createTripController,
      builder: (context, child) {
        final bool canSelectResources =
            !createTripController.isLoadingAvailability &&
            !createTripController.isSavingTrip;

        return buildForm(context, canSelectResources);
      },
    );
  }
}

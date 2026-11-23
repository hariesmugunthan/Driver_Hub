import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'select_location_screen.dart';
import '../configs/app_theme.dart';
import '../controllers/create_trip_controller.dart';
import '../models/trip_model.dart';
import '../widgets/manage_trip/manage_trip_content.dart';

class CreateNewTripScreen extends StatefulWidget {
  final TripModel? trip;

  const CreateNewTripScreen({super.key, this.trip});

  @override
  State<CreateNewTripScreen> createState() => _CreateNewTripScreenState();
}

class _CreateNewTripScreenState extends State<CreateNewTripScreen> {
  final formKey = GlobalKey<FormState>();

  bool get isEditMode => widget.trip != null;

  final createTripController = CreateTripController();

  final startLocationController = TextEditingController();
  final endLocationController = TextEditingController();
  final startLatitudeController = TextEditingController();
  final startLongitudeController = TextEditingController();
  final endLatitudeController = TextEditingController();
  final endLongitudeController = TextEditingController();
  final descriptionController = TextEditingController();

  // INITIALIZE EDIT FORM

  @override
  void initState() {
    super.initState();

    initializeEditForm();
    initializeEditResources();
    loadAvailableResources();
  }

  void initializeEditForm() {
    final trip = widget.trip;

    if (trip == null) return;

    startLocationController.text = trip.startLocation;
    endLocationController.text = trip.endLocation;

    startLatitudeController.text = trip.startLatitude.toString();

    startLongitudeController.text = trip.startLongitude.toString();

    endLatitudeController.text = trip.endLatitude.toString();

    endLongitudeController.text = trip.endLongitude.toString();

    descriptionController.text = trip.description ?? '';
  }

  // INITIALIZE EXISTING DRIVER AND VEHICLE IN EDIT MODE

  Future<void> initializeEditResources() async {
    final trip = widget.trip;

    if (trip == null) return;

    try {
      await createTripController.initializeEditResources(
        driverId: trip.driverId,
        vehicleId: trip.vehicleId,
      );
    } catch (error) {
      if (!mounted) return;

      showErrorMessage('Failed to load existing trip resources: $error');
    }
  }

  // FETCH AVAILABLE DRIVERS AND VEHICLES

  Future<void> loadAvailableResources() async {
    try {
      await createTripController.loadAvailableResources();
    } catch (error) {
      if (!mounted) return;

      showErrorMessage('Failed to load available drivers and vehicles: $error');
    }
  }

  // FIELD VALIDATION

  String? validateRequiredField(String? value) {
    return createTripController.validateRequiredField(value);
  }

  String? validateCoordinate(String? value, double minimum, double maximum, String label) {
    return createTripController.validateCoordinate(value, minimum, maximum, label);
  }

  // SELECT STARTING COORDINATES

  Future<void> selectStartCoordinates() async {
    final double? latitude = double.tryParse(startLatitudeController.text);

    final double? longitude = double.tryParse(startLongitudeController.text);

    LatLng? initialLocation;

    if (latitude != null &&
        longitude != null &&
        latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180) {
      initialLocation = LatLng(latitude, longitude);
    }

    final selectedLocation = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(
        builder: (context) => SelectLocationScreen(
          initialLocation: initialLocation,
        ),
      ),
    );

    if (!mounted || selectedLocation == null) return;

    setState(() {
      startLatitudeController.text = selectedLocation.latitude.toString();

      startLongitudeController.text = selectedLocation.longitude.toString();
    });
  }

  // SELECT ENDING COORDINATES

  Future<void> selectEndCoordinates() async {
    final double? latitude = double.tryParse(endLatitudeController.text);

    final double? longitude = double.tryParse(endLongitudeController.text);

    LatLng? initialLocation;

    if (latitude != null &&
        longitude != null &&
        latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180) {
      initialLocation = LatLng(latitude, longitude);
    }

    final selectedLocation = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(
        builder: (context) => SelectLocationScreen(
          initialLocation: initialLocation,
        ),
      ),
    );

    if (!mounted || selectedLocation == null) return;

    setState(() {
      endLatitudeController.text = selectedLocation.latitude.toString();

      endLongitudeController.text = selectedLocation.longitude.toString();
    });
  }

  // TRIP VALIDATION

  bool validateTripDetails() {
    if (createTripController.isLoadingAvailability) {
      showErrorMessage('Please wait while availability is loading');
      return false;
    }

    if (createTripController.selectedDriver == null) {
      showErrorMessage('Please select a driver');
      return false;
    }

    if (createTripController.selectedVehicle == null) {
      showErrorMessage('Please select a vehicle');
      return false;
    }

    if (!formKey.currentState!.validate()) {
      return false;
    }

    return true;
  }

  // CREATE TRIP

  Future<void> createTrip() async {
    if (!validateTripDetails()) return;

    createTripController.setSavingState(true);

    try {
      final requestData = {
        'driverId': createTripController.selectedDriver!.userId,
        'vehicleId': createTripController.selectedVehicle!.vehicleId,
        'startLocation': startLocationController.text.trim(),
        'endLocation': endLocationController.text.trim(),
        'startLatitude': double.parse(startLatitudeController.text),
        'startLongitude': double.parse(startLongitudeController.text),
        'endLatitude': double.parse(endLatitudeController.text),
        'endLongitude': double.parse(endLongitudeController.text),
        'description':
        descriptionController.text.trim().isEmpty
            ? null
            : descriptionController.text.trim(),
      };

      final data = await createTripController.createTrip(requestData);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(data['message'] ?? 'Trip created successfully'),
          backgroundColor: AppColors.success,
        ),
      );

      Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;

      String message = error.toString();

      if (error is DioException) {
        final data = error.response?.data;

        if (data is Map<String, dynamic>) {
          message = data['message']?.toString() ?? message;
        }
      }

      showErrorMessage(message);
    } finally {
      if (mounted) {
        createTripController.setSavingState(false);
      }
    }
  }

  // UPDATE TRIP

  Future<void> updateTrip() async {
    if (!validateTripDetails()) return;

    final trip = widget.trip;

    if (trip == null) {
      showErrorMessage('Trip details not found');
      return;
    }

    createTripController.setSavingState(true);

    try {
      final requestData = {
        'tripId': trip.tripId,
        'driverId': createTripController.selectedDriver!.userId,
        'vehicleId': createTripController.selectedVehicle!.vehicleId,
        'startLocation': startLocationController.text.trim(),
        'endLocation': endLocationController.text.trim(),
        'startLatitude': double.parse(startLatitudeController.text.trim()),
        'startLongitude': double.parse(startLongitudeController.text.trim()),
        'endLatitude': double.parse(endLatitudeController.text.trim()),
        'endLongitude': double.parse(endLongitudeController.text.trim()),
        'description':
        descriptionController.text.trim().isEmpty
            ? null
            : descriptionController.text.trim(),
      };

      final data = await createTripController.updateTrip(requestData);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(data['message'] ?? 'Trip updated successfully'),
          backgroundColor: AppColors.success,
        ),
      );

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;

      String message = error.toString();

      if (error is DioException) {
        final responseData = error.response?.data;

        if (responseData is Map<String, dynamic>) {
          message = responseData['message']?.toString() ?? message;
        }
      }

      showErrorMessage(message);
    } finally {
      if (mounted) {
        createTripController.setSavingState(false);
      }
    }
  }

  // CANCEL TRIP

  Future<void> cancelTrip() async {
    final trip = widget.trip;

    if (trip == null) {
      showErrorMessage('Trip details not found');
      return;
    }

    createTripController.setSavingState(true);

    try {
      final data = await createTripController.cancelTrip(trip.tripId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(data['message'] ?? 'Trip cancelled successfully'),
          backgroundColor: AppColors.success,
        ),
      );

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;

      String message = error.toString();

      if (error is DioException) {
        final responseData = error.response?.data;

        if (responseData is Map<String, dynamic>) {
          message = responseData['message']?.toString() ?? message;
        }
      }

      showErrorMessage(message);
    } finally {
      if (mounted) {
        createTripController.setSavingState(false);
      }
    }
  }

  // CANCEL TRIP CONFIRMATION

  void showCancelTripConfirmation() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.border),
          ),
          contentPadding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.event_busy_outlined,
                  color: AppColors.error,
                  size: 22,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Cancel trip?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Are you sure you want to cancel this trip?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.secondaryText),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryText,
                          side: const BorderSide(color: AppColors.border),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Go back'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(dialogContext);
                          await cancelTrip();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Cancel trip'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ERROR MESSAGE

  void showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  // UI

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditMode ? 'Edit Trip' : 'Create New Trip',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(
            height: 1,
            thickness: 1,
            color: AppColors.border.withValues(alpha: 0.5),
          ),
        ),
      ),
      body: ManageTripContent(
        formKey: formKey,
        createTripController: createTripController,
        startLocationController: startLocationController,
        endLocationController: endLocationController,
        startLatitudeController: startLatitudeController,
        startLongitudeController: startLongitudeController,
        endLatitudeController: endLatitudeController,
        endLongitudeController: endLongitudeController,
        descriptionController: descriptionController,
        onStartCoordinatesPressed: selectStartCoordinates,
        onEndCoordinatesPressed: selectEndCoordinates,
        isEditMode: isEditMode,
        canCancelTrip: widget.trip?.status == 'scheduled',
        validateRequiredField: validateRequiredField,
        validateCoordinate: validateCoordinate,
        onCreate: createTrip,
        onUpdate: updateTrip,
        onCancel: showCancelTripConfirmation,
      ),
    );
  }

  // DISPOSE

  @override
  void dispose() {
    createTripController.invalidateAvailabilityRequests();
    createTripController.dispose();

    startLocationController.dispose();
    endLocationController.dispose();
    startLatitudeController.dispose();
    startLongitudeController.dispose();
    endLatitudeController.dispose();
    endLongitudeController.dispose();
    descriptionController.dispose();

    super.dispose();
  }
}
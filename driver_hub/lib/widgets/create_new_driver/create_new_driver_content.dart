import 'package:flutter/material.dart';

import 'driver_availability.dart';
import 'driver_basic_detail.dart';
import 'driver_license_detail.dart';
import 'driver_personal_detail.dart';
import 'driver_register_button.dart';

class CreateNewDriverContent extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController mobileNumberController;
  final TextEditingController emailController;
  final TextEditingController addressController;
  final TextEditingController licenseNumberController;
  final DateTime? selectedDateOfBirth;
  final DateTime? selectedLicenseExpiryDate;
  final String? selectedGender;
  final bool isAvailable;
  final bool isRegistering;
  final Future<void> Function() selectDateOfBirth;
  final Future<void> Function() selectLicenseExpiryDate;
  final ValueChanged<String?> onGenderChanged;
  final ValueChanged<bool> onAvailabilityChanged;
  final String Function(DateTime) formatDate;
  final VoidCallback onRegister;

  const CreateNewDriverContent({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.mobileNumberController,
    required this.emailController,
    required this.addressController,
    required this.licenseNumberController,
    required this.selectedDateOfBirth,
    required this.selectedLicenseExpiryDate,
    required this.selectedGender,
    required this.isAvailable,
    required this.isRegistering,
    required this.selectDateOfBirth,
    required this.selectLicenseExpiryDate,
    required this.onGenderChanged,
    required this.onAvailabilityChanged,
    required this.formatDate,
    required this.onRegister,
  });

  Widget buildDriverDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Driver Details', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        DriverBasicDetail(
          nameController: nameController,
          mobileNumberController: mobileNumberController,
          emailController: emailController,
        ),
        const SizedBox(height: 16),
        DriverPersonalDetail(
          addressController: addressController,
          selectedDateOfBirth: selectedDateOfBirth,
          selectedGender: selectedGender,
          selectDateOfBirth: selectDateOfBirth,
          selectGender: onGenderChanged,
          formatDate: formatDate,
        ),
      ],
    );
  }

  Widget buildLicenseDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('License Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        DriverLicenseDetail(
          licenseNumberController: licenseNumberController,
          selectedLicenseExpiryDate: selectedLicenseExpiryDate,
          selectLicenseExpiryDate: selectLicenseExpiryDate,
          formatDate: formatDate,
        ),
      ],
    );
  }

  Widget buildAvailability() {
    return DriverAvailability(isAvailable: isAvailable, onChanged: onAvailabilityChanged);
  }

  Widget buildRegisterButton() {
    return DriverRegisterButton(isRegistering: isRegistering, onPressed: onRegister);
  }

  Widget buildForm() {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildDriverDetails(),
          const SizedBox(height: 24),
          buildLicenseDetails(),
          const SizedBox(height: 16),
          buildAvailability(),
          const SizedBox(height: 32),
          buildRegisterButton(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildForm();
  }
}

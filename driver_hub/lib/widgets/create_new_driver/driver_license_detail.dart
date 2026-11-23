import 'package:flutter/material.dart';

class DriverLicenseDetail extends StatelessWidget {
  final TextEditingController licenseNumberController;

  final DateTime? selectedLicenseExpiryDate;

  final Future<void> Function() selectLicenseExpiryDate;
  final String Function(DateTime) formatDate;

  DriverLicenseDetail({
    super.key,
    required this.licenseNumberController,
    required this.selectedLicenseExpiryDate,
    required this.selectLicenseExpiryDate,
    required this.formatDate,
  });

  Widget buildLicenseNumberField() {
    return TextFormField(
      controller: licenseNumberController,
      decoration: const InputDecoration(labelText: 'License Number', border: OutlineInputBorder()),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'License number is required';
        }

        return null;
      },
    );
  }

  Widget buildLicenseExpiryField() {
    return InkWell(
      onTap: selectLicenseExpiryDate,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'License Expiry Date',
          border: OutlineInputBorder(),
        ),
        child: Text(
          selectedLicenseExpiryDate == null
              ? 'Select license expiry date'
              : formatDate(selectedLicenseExpiryDate!),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [buildLicenseNumberField(), const SizedBox(height: 16), buildLicenseExpiryField()],
    );
  }
}
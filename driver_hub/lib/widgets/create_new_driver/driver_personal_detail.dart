import 'package:flutter/material.dart';

class DriverPersonalDetail extends StatelessWidget {
  final TextEditingController addressController;

  final DateTime? selectedDateOfBirth;
  final String? selectedGender;

  final Future<void> Function() selectDateOfBirth;
  final void Function(String?) selectGender;
  final String Function(DateTime) formatDate;

  DriverPersonalDetail({
    super.key,
    required this.addressController,
    required this.selectedDateOfBirth,
    required this.selectedGender,
    required this.selectDateOfBirth,
    required this.selectGender,
    required this.formatDate,
  });

  Widget buildDateOfBirthField() {
    return InkWell(
      onTap: selectDateOfBirth,
      child: InputDecorator(
        decoration: const InputDecoration(labelText: 'Date of Birth', border: OutlineInputBorder()),
        child: Text(
          selectedDateOfBirth == null ? 'Select date of birth' : formatDate(selectedDateOfBirth!),
        ),
      ),
    );
  }

  Widget buildGenderField() {
    return DropdownButtonFormField<String>(
      initialValue: selectedGender,
      decoration: const InputDecoration(labelText: 'Gender', border: OutlineInputBorder()),
      items: const [
        DropdownMenuItem(
          value: 'Male',
          child: Text('Male'),
        ),
        DropdownMenuItem(
          value: 'Female',
          child: Text('Female'),
        ),
        DropdownMenuItem(
          value: 'Other',
          child: Text('Other'),
        ),
      ],
      onChanged: selectGender,
    );
  }

  Widget buildAddressField() {
    return TextFormField(
      controller: addressController,
      maxLines: 3,
      decoration: const InputDecoration(labelText: 'Address', border: OutlineInputBorder()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildDateOfBirthField(),
        const SizedBox(height: 16),
        buildGenderField(),
        const SizedBox(height: 16),
        buildAddressField(),
      ],
    );
  }
}
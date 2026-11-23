import 'package:flutter/material.dart';

class DriverBasicDetail extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController mobileNumberController;
  final TextEditingController emailController;

  DriverBasicDetail({
    super.key,
    required this.nameController,
    required this.mobileNumberController,
    required this.emailController,
  });

  Widget buildNameField() {
    return TextFormField(
      controller: nameController,
      decoration: const InputDecoration(labelText: 'Driver Name', border: OutlineInputBorder()),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Driver name is required';
        }

        return null;
      },
    );
  }

  Widget buildMobileNumberField() {
    return TextFormField(
      controller: mobileNumberController,
      keyboardType: TextInputType.phone,
      decoration: const InputDecoration(labelText: 'Mobile Number', border: OutlineInputBorder()),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Mobile number is required';
        }

        return null;
      },
    );
  }

  Widget buildEmailField() {
    return TextFormField(
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Email is required';
        }

        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildNameField(),
        const SizedBox(height: 16),
        buildMobileNumberField(),
        const SizedBox(height: 16),
        buildEmailField(),
      ],
    );
  }
}
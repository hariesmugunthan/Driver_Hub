
import 'package:flutter/material.dart';

import '../../models/driver_model.dart';
import '../../configs/app_theme.dart';

class DriverEditDialog extends StatefulWidget {
  final DriverModel driver;
  final Future<void> Function(DriverModel) onUpdate;
  final String Function(DateTime) formatDate;

  DriverEditDialog({
    super.key,
    required this.driver,
    required this.onUpdate,
    required this.formatDate,
  });

  @override
  State<DriverEditDialog> createState() =>
      DriverEditDialogState();
}

class DriverEditDialogState
    extends State<DriverEditDialog> {
  TextEditingController nameController = TextEditingController();

  TextEditingController mobileNumberController = TextEditingController();

  TextEditingController emailController = TextEditingController();

  TextEditingController addressController = TextEditingController();

  TextEditingController licenseNumberController = TextEditingController();

  DateTime? selectedDateOfBirth;
  DateTime selectedLicenseExpiryDate = DateTime.now();

  String? selectedGender;

  bool isAvailable = true;
  bool isUpdating = false;

  GlobalKey<FormState> editFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    nameController.text = widget.driver.name;
    mobileNumberController.text = widget.driver.mobileNumber;
    emailController.text = widget.driver.email;
    addressController.text = widget.driver.address ?? '';
    licenseNumberController.text = widget.driver.licenseNumber;

    selectedDateOfBirth = widget.driver.dateOfBirth;

    selectedLicenseExpiryDate = widget.driver.licenseExpiryDate;

    selectedGender = widget.driver.gender;
    isAvailable = widget.driver.isAvailable;
  }

  @override
  void dispose() {
    nameController.dispose();
    mobileNumberController.dispose();
    emailController.dispose();
    addressController.dispose();
    licenseNumberController.dispose();

    super.dispose();
  }

  // Common input decoration matching AppTheme.
  InputDecoration inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: AppColors.background,

      floatingLabelBehavior:
      FloatingLabelBehavior.auto,

      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),

      labelStyle: const TextStyle(color: AppColors.secondaryText),

      floatingLabelStyle: const TextStyle(color: Colors.lightBlueAccent, fontSize: 16),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
    );
  }

  Future<void> selectDateOfBirth() async {
    DateTime? selectedDate =
    await showDatePicker(
      context: context,
      initialDate: selectedDateOfBirth ??
          DateTime(DateTime.now().year - 25, DateTime.now().month, DateTime.now().day),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (selectedDate == null) {
      return;
    }

    setState(() {
      selectedDateOfBirth = selectedDate;
    });
  }

  Future<void> selectLicenseExpiryDate() async {
    DateTime? selectedDate =
    await showDatePicker(
      context: context,
      initialDate: selectedLicenseExpiryDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (selectedDate == null) {
      return;
    }

    setState(() {
      selectedLicenseExpiryDate = selectedDate;
    });
  }

  DriverModel buildUpdatedDriver() {
    return DriverModel(
      userId: widget.driver.userId,
      name: nameController.text.trim(),
      mobileNumber:
      mobileNumberController.text.trim(),
      email: emailController.text.trim(),
      dateOfBirth: selectedDateOfBirth,
      gender: selectedGender,
      address: addressController.text.trim(),
      licenseNumber:
      licenseNumberController.text.trim(),
      licenseExpiryDate:
      selectedLicenseExpiryDate,
      isAvailable: isAvailable,
    );
  }

  Future<void> updateDriver() async {
    if (!editFormKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isUpdating = true;
    });

    try {
      DriverModel updatedDriver = buildUpdatedDriver();

      await widget.onUpdate(updatedDriver);

      if (!mounted) {
        return;
      }

      Navigator.pop(context);
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        isUpdating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Widget buildNameField() {
    return TextFormField(
      controller: nameController,
      style: const TextStyle(color: AppColors.primaryText),
      decoration: inputDecoration('Driver Name'),
      validator: (value) {
        if (value == null ||
            value.trim().isEmpty) {
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
      style: const TextStyle(color: AppColors.primaryText),
      decoration: inputDecoration('Mobile Number'),
      validator: (value) {
        if (value == null ||
            value.trim().isEmpty) {
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
      style: const TextStyle(color: AppColors.primaryText),
      decoration: inputDecoration('Email'),
      validator: (value) {
        if (value == null ||
            value.trim().isEmpty) {
          return 'Email is required';
        }

        return null;
      },
    );
  }

  Widget buildDateOfBirthField() {
    return InkWell(
      onTap: selectDateOfBirth,
      child: InputDecorator(
        decoration: inputDecoration('Date of Birth'),
        child: Text(
          selectedDateOfBirth == null
              ? 'Select date of birth'
              : widget.formatDate(selectedDateOfBirth!),
          style: const TextStyle(color: AppColors.primaryText),
        ),
      ),
    );
  }

  Widget buildGenderField() {
    return DropdownButtonFormField<String>(
      initialValue: selectedGender,
      decoration: inputDecoration('Gender'),
      dropdownColor: AppColors.surface,
      style: const TextStyle(color: AppColors.primaryText),
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
      onChanged: (value) {
        setState(() {
          selectedGender = value;
        });
      },
    );
  }

  Widget buildAddressField() {
    return TextFormField(
      controller: addressController,
      maxLines: 3,
      style: const TextStyle(color: AppColors.primaryText),
      decoration: inputDecoration('Address'),
    );
  }

  Widget buildLicenseNumberField() {
    return TextFormField(
      controller: licenseNumberController,
      style: const TextStyle(color: AppColors.primaryText),
      decoration: inputDecoration('License Number'),
      validator: (value) {
        if (value == null ||
            value.trim().isEmpty) {
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
        decoration: inputDecoration('License Expiry Date'),
        child: Text(
          widget.formatDate(selectedLicenseExpiryDate),
          style: const TextStyle(color: AppColors.primaryText),
        ),
      ),
    );
  }

  Widget buildAvailabilityField() {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      activeThumbColor: AppColors.primaryText,
      activeTrackColor: AppColors.primary,
      inactiveTrackColor: AppColors.surface,
      title: const Text('Driver Available', style: TextStyle(color: AppColors.primaryText)),
      value: isAvailable,
      onChanged: (value) {
        setState(() {
          isAvailable = value;
        });
      },
    );
  }

  Widget buildForm() {
    return Form(
      key: editFormKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildNameField(),
          const SizedBox(height: 16),

          buildMobileNumberField(),
          const SizedBox(height: 16),

          buildEmailField(),
          const SizedBox(height: 16),

          buildDateOfBirthField(),
          const SizedBox(height: 16),

          buildGenderField(),
          const SizedBox(height: 16),

          buildAddressField(),
          const SizedBox(height: 16),

          buildLicenseNumberField(),
          const SizedBox(height: 16),

          buildLicenseExpiryField(),
          const SizedBox(height: 16),

          buildAvailabilityField(),
        ],
      ),
    );
  }

  List<Widget> buildDialogActions() {
    return [
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Cancel button aligned to the right.
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: isUpdating
                  ? null
                  : () {
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              child: const Text(
                'Cancel',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Full-width Update button.
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed:
              isUpdating ? null : updateDriver,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.primaryText,
                disabledBackgroundColor: AppColors.primary,
                disabledForegroundColor: AppColors.primaryText,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: isUpdating
                  ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.primaryText),
              )
                  : const Text(
                'Update',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,

      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.border, width: 1),
      ),

      title: const Text(
        'Edit Driver',
        style: TextStyle(color: AppColors.primaryText, fontSize: 22, fontWeight: FontWeight.w600),
      ),

      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),

      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: buildForm(),
          ),
        ),
      ),

      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),

      actions: buildDialogActions(),

      actionsPadding: const EdgeInsets.fromLTRB(24, 12, 24, 24),

      actionsAlignment: MainAxisAlignment.end,
    );
  }
}

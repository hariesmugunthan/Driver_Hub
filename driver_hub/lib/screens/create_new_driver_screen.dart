import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../controllers/driver_controller.dart';
import '../models/driver_model.dart';
import '../widgets/create_new_driver/create_new_driver_content.dart';
import '../widgets/create_new_driver/driver_qr_dialog.dart';

class CreateNewDriverScreen extends StatefulWidget {
  const CreateNewDriverScreen({super.key});

  @override
  State<CreateNewDriverScreen> createState() => _CreateNewDriverScreenState();
}

class _CreateNewDriverScreenState extends State<CreateNewDriverScreen> {
  DriverController driverController = DriverController();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();

  TextEditingController mobileNumberController = TextEditingController();

  TextEditingController emailController = TextEditingController();

  TextEditingController addressController = TextEditingController();

  TextEditingController licenseNumberController = TextEditingController();

  DateTime? selectedDateOfBirth;
  DateTime? selectedLicenseExpiryDate;

  String? selectedGender;

  bool isAvailable = true;
  bool isRegistering = false;

  @override
  void dispose() {
    nameController.dispose();
    mobileNumberController.dispose();
    emailController.dispose();
    addressController.dispose();
    licenseNumberController.dispose();

    super.dispose();
  }

  Future<void> selectDateOfBirth() async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(DateTime.now().year - 25, DateTime.now().month, DateTime.now().day),
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
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
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

  Future<void> registerDriver() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (selectedLicenseExpiryDate == null) {
      showMessage('Please select license expiry date');
      return;
    }

    setState(() {
      isRegistering = true;
    });

    try {
      DriverModel driverModel = DriverModel(
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
        selectedLicenseExpiryDate!,
        isAvailable: isAvailable,
      );

      DriverModel createdDriver = await driverController.createDriver(driverModel);

      if (!mounted) {
        return;
      }

      setState(() {
        isRegistering = false;
      });

      await showDriverQrDialog(createdDriver);

      if (!mounted) {
        return;
      }

      Navigator.pop(context);

    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        isRegistering = false;
      });

      showMessage(error.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<Uint8List?> generateQrImage(String driverId) async {
    return await driverController.generateQrImage(driverId);
  }

  Future<void> shareDriverQr(String driverId) async {
    await driverController.shareDriverQr(driverId);
  }

  Future<void> saveDriverQr(String driverId) async {
    await driverController.saveDriverQr(driverId);

    if (!mounted) {
      return;
    }

    showMessage('QR code saved successfully');
  }

  Future<void> showDriverQrDialog(DriverModel driver) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return DriverQrDialog(
          driver: driver,
          shareDriverQr: shareDriverQr,
          saveDriverQr: saveDriverQr,
        );
      },
    );
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  Widget buildForm() {
    return CreateNewDriverContent(
      formKey: formKey,
      nameController: nameController,
      mobileNumberController: mobileNumberController,
      emailController: emailController,
      addressController: addressController,
      licenseNumberController: licenseNumberController,
      selectedDateOfBirth: selectedDateOfBirth,
      selectedLicenseExpiryDate: selectedLicenseExpiryDate,
      selectedGender: selectedGender,
      isAvailable: isAvailable,
      isRegistering: isRegistering,
      selectDateOfBirth: selectDateOfBirth,
      selectLicenseExpiryDate: selectLicenseExpiryDate,
      onGenderChanged: (value) {
        setState(() {
          selectedGender = value;
        });
      },
      onAvailabilityChanged: (value) {
        setState(() {
          isAvailable = value;
        });
      },
      formatDate: formatDate,
      onRegister: registerDriver,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Driver'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: buildForm(),
      ),
    );
  }
}
import 'package:flutter/material.dart';

import '../../models/admin_registration_model.dart';

class AdminRegistrationDialog extends StatefulWidget {
  final Future<void> Function(AdminRegistrationModel adminRegistrationModel) handleRegistration;

  AdminRegistrationDialog({super.key, required this.handleRegistration});

  @override
  State<AdminRegistrationDialog> createState() => AdminRegistrationDialogState();
}

class AdminRegistrationDialogState
    extends State<AdminRegistrationDialog> {
  TextEditingController nameController = TextEditingController();

  TextEditingController emailController = TextEditingController();

  TextEditingController masterPasswordController = TextEditingController();

  bool isRegistering = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    masterPasswordController.dispose();

    super.dispose();
  }

  Future<void> submitRegistration() async {
    String name = nameController.text.trim();
    String email = emailController.text.trim();
    String masterPassword = masterPasswordController.text;

    if (name.isEmpty || email.isEmpty || masterPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All fields are required'),
        ),
      );
      return;
    }

    AdminRegistrationModel adminRegistrationModel = AdminRegistrationModel(
      name: name,
      email: email,
      masterPassword: masterPassword,
    );

    setState(() {
      isRegistering = true;
    });

    try {
      await widget.handleRegistration(adminRegistrationModel);

      if (!mounted) {
        return;
      }

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Admin registered successfully'),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        isRegistering = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Admin registration failed'),
        ),
      );
    }
  }

  Widget buildNameField() {
    return TextField(
      controller: nameController,
      decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
    );
  }

  Widget buildEmailField() {
    return TextField(
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
    );
  }

  Widget buildMasterPasswordField() {
    return TextField(
      controller: masterPasswordController,
      obscureText: true,
      decoration: const InputDecoration(labelText: 'Master Password', border: OutlineInputBorder()),
    );
  }

  Widget buildForm() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildNameField(),
          const SizedBox(height: 16),
          buildEmailField(),
          const SizedBox(height: 16),
          buildMasterPasswordField(),
        ],
      ),
    );
  }

  List<Widget> buildDialogActions() {
    return [
      TextButton(
        onPressed: isRegistering
            ? null
            : () {
          Navigator.pop(context);
        },
        child: const Text('Cancel'),
      ),
      ElevatedButton(
        onPressed: isRegistering ? null : submitRegistration,
        child: isRegistering
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(),
        )
            : const Text('Register'),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Register Admin'),
      content: buildForm(),
      actions: buildDialogActions(),
    );
  }
}
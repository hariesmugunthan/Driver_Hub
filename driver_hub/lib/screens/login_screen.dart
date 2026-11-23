import 'dart:ui';

import 'package:flutter/material.dart';

import '../controllers/auth_controller.dart';
import '../controllers/admin_registration_controller.dart';
import '../models/auth_model.dart';
import '../models/driver_model.dart';
import '../models/admin_registration_model.dart';
import '../widgets/admin_login/admin_login_content.dart';
import '../widgets/admin_login/admin_registration_dialog.dart';
import 'admin_home_screen.dart';
import 'driver_flow_screen.dart';

class LoginScreen extends StatelessWidget {
  final String role;

  final AuthController authController = AuthController();

  final AdminRegistrationController adminRegistrationController = AdminRegistrationController();

  LoginScreen({super.key, required this.role});

  Future<void> handleGoogleSignIn(BuildContext context) async {
    try {
      dynamic authenticatedUser = await authController.authenticateUser(role);

      if (!context.mounted) {
        return;
      }

      if (authenticatedUser is AdminAuthModel) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AdminHomeScreen(
              adminName: authenticatedUser.name,
            ),
          ),
        );
      } else if (authenticatedUser is DriverModel) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DriverFlowScreen(
              driver: authenticatedUser,
            ),
          ),
        );
      }
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  void handleAdminRegistration(BuildContext context) {
    if (role != 'admin') {
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AdminRegistrationDialog(handleRegistration: handleRegistrationSubmit);
      },
    );
  }

  Future<void> handleRegistrationSubmit(AdminRegistrationModel adminRegistrationModel) async {
    await adminRegistrationController.registerAdmin(adminRegistrationModel);
  }

  // Round glass back button (replaces the old app bar arrow)
  Widget buildBackButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 8),
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Material(
            color: const Color(0x10FFFFFF),
            shape: const CircleBorder(side: BorderSide(color: Color(0xFF2A3D66))),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () {
                Navigator.maybePop(context);
              },
              child: const SizedBox(
                width: 42,
                height: 42,
                child: Icon(Icons.chevron_left, size: 26, color: Color(0xFFE6EEFF)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    precacheImage(const AssetImage('lib/assets/driverhub_bg.png'), context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Full-screen map background
          Positioned.fill(
            child: Image.asset(
              'lib/assets/driverhub_bg.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
          SafeArea(
            child: AdminLoginContent(
              role: role,
              handleGoogleSignIn: () {
                handleGoogleSignIn(context);
              },
              handleAdminRegistration: role == 'admin'
                  ? () {
                handleAdminRegistration(context);
              }
                  : null,
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: buildBackButton(context),
            ),
          ),
        ],
      ),
    );
  }
}

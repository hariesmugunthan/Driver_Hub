import 'package:flutter/material.dart';
import '../controllers/driver_language_controller.dart';
import '../l10n/app_localizations.dart';

import '../models/driver_model.dart';
import 'driver_dashboard_screen.dart';

class DriverFlowScreen extends StatefulWidget {
  final DriverModel driver;

  const DriverFlowScreen({super.key, required this.driver});

  @override
  State<DriverFlowScreen> createState() => _DriverFlowScreenState();
}

class _DriverFlowScreenState extends State<DriverFlowScreen> {
  final DriverLanguageController driverLanguageController = DriverLanguageController();

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initializeLanguage();
  }

  Future<void> initializeLanguage() async {
    await driverLanguageController.loadLanguage();

    if (!mounted) {
      return;
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    driverLanguageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return AnimatedBuilder(
      animation: driverLanguageController,
      builder: (context, child) {
        return Localizations(
          locale: driverLanguageController.locale,
          delegates: AppLocalizations.localizationsDelegates,
          child: Navigator(
            onGenerateRoute: (settings) {
              return MaterialPageRoute(
                builder: (context) => DriverDashboardScreen(
                  driver: widget.driver,
                  driverLanguageController: driverLanguageController,
                ),
              );
            },
          ),
        );
      },
    );
  }
}
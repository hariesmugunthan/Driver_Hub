import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'configs/app_theme.dart';
import 'firebase_options.dart';
import 'services/google_auth_service.dart';
import 'screens/user_selection_screen.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});

  Future<void> initializeApp() async {
    //responsible for establishing the connection between the Flutter framework and the Flutter engine.
    WidgetsFlutterBinding.ensureInitialized();

    //initillizing firebase
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//initilize google sign in
    GoogleAuthService googleAuthService = GoogleAuthService();
    await googleAuthService.initializeGoogleSignIn();
  }

  Widget buildGradientBackground(BuildContext context, Widget? child) {
    return AppBackground(
      child: child ?? const SizedBox.shrink(),
    );
  }

  Widget buildLoadingApp() {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      builder: buildGradientBackground,
      home: const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget buildMainApp() {
    return MaterialApp(
      title: 'DriveHub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      builder: buildGradientBackground,
      home: const UserSelectionScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {

    /*FutureBuilder needs two important things:
- future: The asynchronous operation it should monitor.
- builder: A function that tells it what UI to display based on the Future's current state.*/
    return FutureBuilder<void>(
      future: initializeApp(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return buildLoadingApp();
        }

        return buildMainApp();
      },
    );
  }
}
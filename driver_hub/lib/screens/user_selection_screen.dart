import 'package:flutter/material.dart';

import '../widgets/user_selection/user_selection_content.dart';
import 'login_screen.dart';

class UserSelectionScreen extends StatelessWidget {
  const UserSelectionScreen({super.key});

  void handleAdminSelection(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen(role: 'admin')),
    );
  }

  void handleDriverSelection(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen(role: 'driver')),
    );
  }

  @override
  Widget build(BuildContext context) {
    //to load the background image into memory before Flutter needs to display it.
    //helps avoid that delay by loading the image earlier.
    precacheImage(const AssetImage('lib/assets/driverhub_bg.png'), context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Full-screen map background (sits behind the status bar too)
          Positioned.fill(
            child: Image.asset(
              'lib/assets/driverhub_bg.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
          SafeArea(
            child: UserSelectionContent(
              onAdminSelected: () => handleAdminSelection(context),
              onDriverSelected: () => handleDriverSelection(context),
            ),
          ),
        ],
      ),
    );
  }
}

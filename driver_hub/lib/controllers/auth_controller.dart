import '../models/auth_model.dart';
import '../models/driver_model.dart';
import '../services/admin_auth_service.dart';
import '../services/google_auth_service.dart';

class AuthController {
  //Handles Google Sign-In and Firebase authentication.
  GoogleAuthService googleAuthService = GoogleAuthService();
  //Communicates with your backend to authenticate the user.
  AdminAuthService adminAuthService = AdminAuthService();

  Future<dynamic> authenticateUser(String role) async {
    String firebaseIdToken = await googleAuthService.signInWithGoogle();

    Map<String, dynamic> authenticatedUserData = await adminAuthService.authenticateUser(
      firebaseIdToken,
      role,
    );

    if (role == 'admin') {
      return AdminAuthModel.fromJson(authenticatedUserData);
    }

    if (role == 'driver') {
      return DriverModel.fromJson(authenticatedUserData);
    }

    throw Exception('Invalid user role');
  }
}
import '../models/admin_registration_model.dart';
import '../services/admin_registration_service.dart';

class AdminRegistrationController {
  AdminRegistrationService adminRegistrationService = AdminRegistrationService();

  Future<void> registerAdmin(AdminRegistrationModel adminRegistrationModel) async {
    await adminRegistrationService.registerAdmin(adminRegistrationModel);
  }
}
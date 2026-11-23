class AdminRegistrationModel {
  String name;
  String email;
  String masterPassword;

  AdminRegistrationModel({required this.name, required this.email, required this.masterPassword});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'masterPassword': masterPassword,
    };
  }
}
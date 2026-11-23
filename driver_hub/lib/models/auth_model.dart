class AdminAuthModel {
  final String userId;
  final String name;
  final String email;

  AdminAuthModel({required this.userId, required this.name, required this.email});

  factory AdminAuthModel.fromJson(Map<String, dynamic> json) {
    return AdminAuthModel(
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }
}
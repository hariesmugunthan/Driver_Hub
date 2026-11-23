class DriverModel {
  String userId;
  String name;
  String mobileNumber;
  String email;
  DateTime? dateOfBirth;
  String? gender;
  String? address;
  String licenseNumber;
  DateTime licenseExpiryDate;
  bool isAvailable;

  DriverModel({
    this.userId = '',
    required this.name,
    required this.mobileNumber,
    required this.email,
    this.dateOfBirth,
    this.gender,
    this.address,
    required this.licenseNumber,
    required this.licenseExpiryDate,
    this.isAvailable = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'mobileNumber': mobileNumber,
      'email': email,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'address': address,
      'licenseNumber': licenseNumber,
      'licenseExpiryDate': licenseExpiryDate.toIso8601String(),
      'isAvailable': isAvailable,
    };
  }

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      userId: json['userId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      mobileNumber: json['mobileNumber'] as String? ?? '',
      email: json['email'] as String? ?? '',
      dateOfBirth: json['dateOfBirth'] != null ? DateTime.parse(
    json['dateOfBirth'] as String,
  ) : null,
      gender: json['gender'] as String?,
      address: json['address'] as String?,
      licenseNumber: json['licenseNumber'] as String? ?? '',
      licenseExpiryDate: DateTime.parse(json['licenseExpiryDate'] as String),
      isAvailable: json['isAvailable'] as bool? ?? true,
    );
  }
}
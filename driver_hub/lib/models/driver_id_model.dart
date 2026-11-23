class DriverIdModel {
  String userId;

  DriverIdModel({required this.userId});

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
    };
  }
}
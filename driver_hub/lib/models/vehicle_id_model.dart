class VehicleIdModel {
  String vehicleId;

  VehicleIdModel({required this.vehicleId});

  Map<String, dynamic> toJson() {
    return {
      'vehicleId': vehicleId,
    };
  }

  factory VehicleIdModel.fromJson(Map<String, dynamic> json) {
    return VehicleIdModel(vehicleId: json['vehicleId'] as String? ?? '');
  }
}
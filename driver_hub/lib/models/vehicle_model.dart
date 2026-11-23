class VehicleModel {
  String vehicleId;
  String registrationNumber;
  String vehicleType;
  String brand;
  String model;
  String fuelType;
  int seatingCapacity;
  bool isAvailable;

  VehicleModel({
    this.vehicleId = '',
    required this.registrationNumber,
    required this.vehicleType,
    required this.brand,
    required this.model,
    required this.fuelType,
    required this.seatingCapacity,
    this.isAvailable = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'vehicleId': vehicleId,
      'registrationNumber': registrationNumber,
      'vehicleType': vehicleType,
      'brand': brand,
      'model': model,
      'fuelType': fuelType,
      'seatingCapacity': seatingCapacity,
      'isAvailable': isAvailable,
    };
  }

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      vehicleId: json['vehicleId'] as String? ?? '',
      registrationNumber: json['registrationNumber'] as String? ?? '',
      vehicleType: json['vehicleType'] as String? ?? '',
      brand: json['brand'] as String? ?? '',
      model: json['model'] as String? ?? '',
      fuelType: json['fuelType'] as String? ?? '',
      seatingCapacity: json['seatingCapacity'] as int? ?? 0,
      isAvailable: json['isAvailable'] as bool? ?? true,
    );
  }
}
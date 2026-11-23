class AdminLocationModel {
  final String tripId;
  final String driverId;
  final String vehicleId;
  final double latitude;
  final double longitude;
  final double speed;
  final double heading;
  final double accuracy;
  final DateTime? updatedAt;

  const AdminLocationModel({
    required this.tripId,
    required this.driverId,
    required this.vehicleId,
    required this.latitude,
    required this.longitude,
    required this.speed,
    required this.heading,
    required this.accuracy,
    this.updatedAt,
  });

  factory AdminLocationModel.fromJson(Map<String, dynamic> json) {
    return AdminLocationModel(
      tripId: json['tripId'] as String? ?? '',
      driverId: json['driverId'] as String? ?? '',
      vehicleId: json['vehicleId'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      speed: (json['speed'] as num?)?.toDouble() ?? 0,
      heading: (json['heading'] as num?)?.toDouble() ?? 0,
      accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'] as String) : null,
    );
  }

  double get speedInKmh => speed * 3.6;
}

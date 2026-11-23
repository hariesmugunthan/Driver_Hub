class DriverPerformanceModel {
  final String driverId;
  final int totalAssignedTrips;
  final int completedTrips;
  final double totalDistanceMeters;
  final double totalDistanceKilometers;
  final double totalDrivingHours;
  final double averageTripDistanceKilometers;
  final double averageTripDurationHours;
  final double completionRate;

  DriverPerformanceModel({
    required this.driverId,
    required this.totalAssignedTrips,
    required this.completedTrips,
    required this.totalDistanceMeters,
    required this.totalDistanceKilometers,
    required this.totalDrivingHours,
    required this.averageTripDistanceKilometers,
    required this.averageTripDurationHours,
    required this.completionRate,
  });

  factory DriverPerformanceModel.fromJson(Map<String, dynamic> json) {
    return DriverPerformanceModel(
      driverId: json['driverId'] ?? '',
      totalAssignedTrips: json['totalAssignedTrips'] ?? 0,
      completedTrips: json['completedTrips'] ?? 0,
      totalDistanceMeters: (json['totalDistanceMeters'] ?? 0).toDouble(),
      totalDistanceKilometers: (json['totalDistanceKilometers'] ?? 0).toDouble(),
      totalDrivingHours: (json['totalDrivingHours'] ?? 0).toDouble(),
      averageTripDistanceKilometers: (json['averageTripDistanceKilometers'] ?? 0).toDouble(),
      averageTripDurationHours: (json['averageTripDurationHours'] ?? 0).toDouble(),
      completionRate: (json['completionRate'] ?? 0).toDouble(),
    );
  }
}
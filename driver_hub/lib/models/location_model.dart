class LocationModel {
  final double latitude;
  final double longitude;
  final double speed;
  final double accuracy;
  final double heading;
  final DateTime timestamp;

  const LocationModel({
    required this.latitude,
    required this.longitude,
    required this.speed,
    required this.accuracy,
    required this.heading,
    required this.timestamp,
  });

  double get speedInKmh => speed * 3.6;
}
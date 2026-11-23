class VehicleDetailsModel {
  String registrationNumber;
  String brand;
  String model;

  VehicleDetailsModel({this.registrationNumber = '', this.brand = '', this.model = ''});

  factory VehicleDetailsModel.fromJson(Map<String, dynamic> json) {
    return VehicleDetailsModel(
      registrationNumber: json['registrationNumber'] as String? ?? '',
      brand: json['brand'] as String? ?? '',
      model: json['model'] as String? ?? '',
    );
  }
}

class TripModel {
  String tripId;
  String driverId;
  String vehicleId;
  String driverName;

  String startLocation;
  String endLocation;

  double startLatitude;
  double startLongitude;
  double endLatitude;
  double endLongitude;

  DateTime? actualStartTime;
  DateTime? actualEndTime;

  double? totalDistanceMeters;

  String status;
  String? description;

  VehicleDetailsModel? vehicle;

  TripModel({
    this.tripId = '',
    this.driverId = '',
    this.vehicleId = '',
    this.driverName = '',
    this.startLocation = '',
    this.endLocation = '',
    this.startLatitude = 0,
    this.startLongitude = 0,
    this.endLatitude = 0,
    this.endLongitude = 0,
    this.actualStartTime,
    this.actualEndTime,
    this.totalDistanceMeters,
    this.status = 'scheduled',
    this.description,
    this.vehicle,
  });

  factory TripModel.fromJson(Map<String, dynamic> json) {
    return TripModel(
      tripId: json['tripId'] as String? ?? '',
      driverId: json['driverId'] as String? ?? '',
      vehicleId: json['vehicleId'] as String? ?? '',
      driverName: json['driverName'] as String? ?? '',
      startLocation: json['startLocation'] as String? ?? '',
      endLocation: json['endLocation'] as String? ?? '',
      startLatitude: (json['startLatitude'] as num?)?.toDouble() ?? 0,
      startLongitude: (json['startLongitude'] as num?)?.toDouble() ?? 0,
      endLatitude: (json['endLatitude'] as num?)?.toDouble() ?? 0,
      endLongitude: (json['endLongitude'] as num?)?.toDouble() ?? 0,
      actualStartTime: json['actualStartTime'] != null
          ? DateTime.parse(json['actualStartTime'] as String) : null,
      actualEndTime: json['actualEndTime'] != null ? DateTime.parse(json['actualEndTime'] as String)
          : null,
      totalDistanceMeters: (json['totalDistanceMeters'] as num?)?.toDouble(),
      status: json['status'] as String? ?? 'scheduled',
      description: json['description'] as String?,
      vehicle: json['vehicle'] != null ? VehicleDetailsModel.fromJson(
    json['vehicle'] as Map<String, dynamic>,
  ) : null,
    );
  }
}
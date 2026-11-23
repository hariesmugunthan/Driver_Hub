import 'package:flutter/material.dart';

class VehicleCategories {
  static const List<Map<String, dynamic>> categories = [
    {
      'name': 'Hatchback',
      'icon': Icons.directions_car,
    },
    {'name': 'Sedan', 'icon': Icons.directions_car_filled},
    {'name': 'SUV', 'icon': Icons.car_rental},
    {'name': 'MUV', 'icon': Icons.airport_shuttle},
    {'name': 'MPV', 'icon': Icons.airport_shuttle},
    {'name': 'Van', 'icon': Icons.directions_bus},
    {'name': 'Tempo Traveller', 'icon': Icons.directions_bus_filled},
    {'name': 'Minibus', 'icon': Icons.directions_bus},
    {'name': 'Bus', 'icon': Icons.directions_bus_filled},
    {'name': 'Pickup Truck', 'icon': Icons.local_shipping},
    {'name': 'Light Commercial Vehicle', 'icon': Icons.local_shipping},
    {'name': 'Heavy Truck', 'icon': Icons.fire_truck},
  ];
}
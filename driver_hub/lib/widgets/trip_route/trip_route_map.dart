import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TripRouteMap extends StatelessWidget {
  final LatLng initialPosition;
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final Function(GoogleMapController) onMapCreated;

  const TripRouteMap({
    super.key,
    required this.initialPosition,
    required this.markers,
    required this.polylines,
    required this.onMapCreated,
  });

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(target: initialPosition, zoom: 12),
      markers: markers,
      polylines: polylines,
      myLocationButtonEnabled: false,
      mapToolbarEnabled: false,
      onMapCreated: onMapCreated,
    );
  }
}
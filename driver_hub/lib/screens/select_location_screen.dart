import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_places_sdk_plus/google_places_sdk_plus.dart'
    hide LatLng;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SelectLocationScreen extends StatefulWidget {
  final LatLng? initialLocation;

  const SelectLocationScreen({super.key, this.initialLocation});

  @override
  State<SelectLocationScreen> createState() => _SelectLocationScreenState();
}

class _SelectLocationScreenState extends State<SelectLocationScreen> {
  static const MethodChannel mapsChannel = MethodChannel('com.driverhub.app/maps');

  static const LatLng defaultLocation = LatLng(20.5937, 78.9629);

  late LatLng? selectedLocation;

  final TextEditingController searchController = TextEditingController();

  FlutterGooglePlacesSdk? placesSdk;
  GoogleMapController? mapController;

  List<AutocompletePrediction> predictions = [];

  Timer? searchDebounce;
  bool isSearching = false;
  bool isLoadingPlace = false;
  bool isInitializingPlaces = true;

  @override
  void initState() {
    super.initState();

    selectedLocation = widget.initialLocation;

    initializePlacesSdk();
  }

  Future<void> initializePlacesSdk() async {
    try {
      final String? apiKey = await mapsChannel.invokeMethod<String>('getMapsApiKey');

      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('Google Maps API key is missing.');
      }

      if (!mounted) return;

      setState(() {
        placesSdk = FlutterGooglePlacesSdk(apiKey);
        isInitializingPlaces = false;
      });

      debugPrint('Places SDK initialized successfully.');
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isInitializingPlaces = false;
      });

      debugPrint('Places SDK initialization failed: $error');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to initialize location search.')),
      );
    }
  }

  @override
  void dispose() {
    searchDebounce?.cancel();
    searchController.dispose();
    super.dispose();
  }

  void handleMapTap(LatLng location) {
    setState(() {
      selectedLocation = location;
      predictions = [];
      searchController.clear();
    });
  }

  void handleSearchChanged(String query) {
    searchDebounce?.cancel();

    if (query.trim().isEmpty) {
      setState(() {
        predictions = [];
        isSearching = false;
      });
      return;
    }

    searchDebounce = Timer(
      const Duration(milliseconds: 400),
          () {
        searchPlaces(query.trim());
      },
    );
  }

  Future<void> searchPlaces(String query) async {
    final FlutterGooglePlacesSdk? sdk = placesSdk;

    if (sdk == null) {
      return;
    }

    setState(() {
      isSearching = true;
    });

    try {
      final response = await sdk.findAutocompletePredictions(query, countries: ['IN']);

      if (!mounted || searchController.text.trim() != query) {
        return;
      }

      setState(() {
        predictions = response.predictions;
        isSearching = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        predictions = [];
        isSearching = false;
      });

      debugPrint('Place search failed: $error');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to search locations. Please try again.')),
      );
    }
  }

  Future<void> selectPrediction(AutocompletePrediction prediction) async {
    FocusScope.of(context).unfocus();

    final String? placeId = prediction.placeId;

    if (placeId == null || placeId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid location selected.')),
      );
      return;
    }

    final FlutterGooglePlacesSdk? sdk = placesSdk;

    if (sdk == null) {
      return;
    }

    setState(() {
      isLoadingPlace = true;
      predictions = [];
    });

    try {
      final response = await sdk.fetchPlace(
        placeId,
        fields: [PlaceField.Location, PlaceField.DisplayName],
      );

      if (!mounted) return;

      final placeLocation = response.place?.latLng;

      if (placeLocation == null) {
        throw Exception('Selected place has no coordinates.');
      }

      final location = LatLng(placeLocation.lat, placeLocation.lng);

      setState(() {
        selectedLocation = location;
        searchController.text = prediction.fullText ?? prediction.primaryText ?? '';
        isLoadingPlace = false;
      });

      await mapController?.animateCamera(CameraUpdate.newLatLngZoom(location, 15));
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isLoadingPlace = false;
      });

      debugPrint('Place selection failed: $error');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to load this location.')),
      );
    }
  }

  Set<Marker> get markers {
    if (selectedLocation == null) {
      return {};
    }

    return {
      Marker(markerId: const MarkerId('selected_location'), position: selectedLocation!),
    };
  }

  void confirmLocation() {
    if (selectedLocation == null) return;

    Navigator.pop(context, selectedLocation);
  }

  Widget buildMap(LatLng cameraTarget) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: cameraTarget,
        zoom: widget.initialLocation == null ? 5 : 14,
      ),
      markers: markers,
      onTap: handleMapTap,
      onMapCreated: (controller) {
        mapController = controller;
      },
      myLocationButtonEnabled: false,
      mapToolbarEnabled: false,
    );
  }

  Widget buildSearchBar() {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(12),
      child: TextField(
        controller: searchController,
        onChanged: handleSearchChanged,
        style: const TextStyle(color: Colors.black, fontSize: 16),
        decoration: InputDecoration(
          hintText: 'Search a location',
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 16),
          prefixIcon: const Icon(Icons.search),
          suffixIcon: isSearching || isLoadingPlace || isInitializingPlaces
              ? const Padding(
                  padding: EdgeInsets.all(14),
                  child: SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    setState(() {
                      predictions = [];
                    });
                  },
                ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget buildPredictionsList() {
    if (predictions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 4),
      constraints: const BoxConstraints(maxHeight: 250),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 5)],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: predictions.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final prediction = predictions[index];

          final String primaryText =
              prediction.primaryText ?? prediction.fullText ?? 'Unknown location';

          final String? secondaryText = prediction.secondaryText;

          return ListTile(
            leading: const Icon(Icons.location_on_outlined),
            title: Text(
              primaryText,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: secondaryText != null && secondaryText.isNotEmpty
                ? Text(secondaryText, style: const TextStyle(color: Colors.black54, fontSize: 14))
                : null,
            onTap: () {
              selectPrediction(prediction);
            },
          );
        },
      ),
    );
  }

  Widget buildSearchOverlay() {
    return Positioned(
      top: 12,
      left: 16,
      right: 16,
      child: Column(
        children: [
          buildSearchBar(),
          buildPredictionsList(),
        ],
      ),
    );
  }

  Widget buildConfirmButton() {
    return Positioned(
      left: 16,
      right: 16,
      bottom: 20,
      child: SafeArea(
        child: ElevatedButton.icon(
          onPressed: selectedLocation == null ? null : confirmLocation,
          icon: const Icon(Icons.check),
          label: const Text('Confirm Location'),
          style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final LatLng cameraTarget = widget.initialLocation ?? defaultLocation;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location'),
      ),
      body: Stack(
        children: [
          buildMap(cameraTarget),
          buildSearchOverlay(),
          buildConfirmButton(),
        ],
      ),
    );
  }
}
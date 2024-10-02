import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:track/utils/location_service.dart';
import 'package:track/utils/map_services.dart';

class GoogleMapView extends StatefulWidget {
  const GoogleMapView({super.key});

  @override
  State<GoogleMapView> createState() => _GoogleMapViewState();
}

class _GoogleMapViewState extends State<GoogleMapView> {
  late CameraPosition initialCameraPosition;
  late MapServices mapServices;
  late GoogleMapController googleMapController;
  Set<Marker> markers = {};
  Set<Polyline> polyLines = {};
  LatLng? selectedLocation;
  Timer? debounce;

  @override
  void initState() {
    super.initState();
    mapServices = MapServices();
    initialCameraPosition =
        const CameraPosition(target: LatLng(0, 0), zoom: 10);
    _initLocationAndListeners();
  }

  void _initLocationAndListeners() {
    _updateCurrentLocation();
  }

  @override
  void dispose() {
    debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          polylines: polyLines,
          markers: markers,
          onMapCreated: (controller) {
            googleMapController = controller;
          },
          onTap: _onMapTapped, // Handle map taps
          zoomControlsEnabled: false,
          initialCameraPosition: initialCameraPosition,
        ),
      ],
    );
  }

  /// When the user taps on the map, set the selected location
  void _onMapTapped(LatLng tappedLocation) async {
    setState(() {
      selectedLocation = tappedLocation;
      markers.clear();
      markers.add(
        Marker(
          markerId: MarkerId("selectedLocation"),
          position: tappedLocation,
          infoWindow: const InfoWindow(title: "Selected Location"),
        ),
      );
    });

    var points = await mapServices.getRouteData(desintation: selectedLocation!);
    mapServices.displayRoute(
      points,
      polyLines: polyLines,
      googleMapController: googleMapController,
    );
    setState(() {});
  }

  void _updateCurrentLocation() {
    try {
      mapServices.updateCurrentLocation(
        onUpdatecurrentLocation: () => setState(() {}),
        googleMapController: googleMapController,
        markers: markers,
      );
    } on LocationServiceException catch (e) {
      // Handle location service error
    } on LocationPermissionException catch (e) {
      // Handle location permission error
    } catch (e) {
      // Handle generic error
    }
  }
}

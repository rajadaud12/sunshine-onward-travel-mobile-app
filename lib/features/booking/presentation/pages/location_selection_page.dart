// location_selection_page.dart
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sot/core/config/app_colors.dart';
import 'package:sot/features/booking/state/booking_cubit.dart';
import 'package:sot/features/booking/state/booking_state.dart';
import 'package:http/http.dart' as http;

class LocationSelectionPage extends StatefulWidget {
  final int? editIndex;
  final String googleMapsApiKey; // Added to pass API key

  const LocationSelectionPage({
    Key? key,
    this.editIndex,
    required this.googleMapsApiKey,
  }) : super(key: key);

  @override
  State<LocationSelectionPage> createState() => _LocationSelectionPageState();
}

class _LocationSelectionPageState extends State<LocationSelectionPage> {
  GoogleMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();
  LatLng? _selectedLocation;
  LatLng? _currentLocation;
  List<LocationSearchResult> _searchResults = [];
  bool _isSearching = false;
  String? _selectedLocationName; // Tracks the selected location name
  String? _selectedLocationAddress; // Tracks the selected location address

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _initializeSelectedLocation();
  }

  void _initializeSelectedLocation() {
    final state = context.read<BookingCubit>().state;
    if (widget.editIndex != null && widget.editIndex! < state.locations.length) {
      final loc = state.locations[widget.editIndex!];
      if (loc != null) {
        _selectedLocation = LatLng(loc.lat, loc.lng);
        _selectedLocationName = loc.name ?? loc.address;
        _selectedLocationAddress = loc.address;
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });

      // Move map to current location if no selected location
      if (_selectedLocation == null && _mapController != null) {
        _mapController!.animateCamera(CameraUpdate.newLatLngZoom(_currentLocation!, 15.0));
      }
    } catch (e) {
      // Fallback to Chicago (assuming US-based app)
      setState(() {
        _currentLocation = const LatLng(41.8781, -87.6298);
      });
      if (_selectedLocation == null && _mapController != null) {
        _mapController!.animateCamera(CameraUpdate.newLatLngZoom(_currentLocation!, 13.0));
      }
    }
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    _performSearch(query);
  }

  Future<void> _performSearch(String query) async {
    if (_currentLocation == null) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    try {
      final encodedQuery = Uri.encodeQueryComponent(query);
      final locBias = '${_currentLocation!.latitude},${_currentLocation!.longitude}';
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/textsearch/json?query=$encodedQuery&location=$locBias&radius=50000&region=US&key=${widget.googleMapsApiKey}',
      );

      final response = await http.get(url);
      if (response.statusCode != 200) {
        print('Places API HTTP error: ${response.statusCode}');
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
        return;
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      final status = data['status'] as String? ?? 'NO_STATUS';
      if (status != 'OK') {
        print('Places API status: $status');
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
        return;
      }

      final results = (data['results'] as List<dynamic>?) ?? [];
      final searchResults = <LocationSearchResult>[];

      for (final result in results.take(4)) { // Limit to 4
        final resultMap = result as Map<String, dynamic>;
        final name = resultMap['name'] as String? ?? query;
        final address = resultMap['formatted_address'] as String? ?? '';
        final geometry = resultMap['geometry'] as Map<String, dynamic>?;
        final location = geometry?['location'] as Map<String, dynamic>?;
        final lat = location?['lat'] as double?;
        final lng = location?['lng'] as double?;
        if (lat != null && lng != null) {
          searchResults.add(LocationSearchResult(
            name: name,
            address: address,
            location: LatLng(lat, lng),
          ));
        }
      }

      setState(() {
        _searchResults = searchResults;
        _isSearching = false;
      });
    } catch (e) {
      print('Places search error: $e');
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
    }
  }

  void _onLocationSelected(LocationSearchResult result) {
    setState(() {
      _selectedLocation = result.location;
      _selectedLocationName = result.name;
      _selectedLocationAddress = result.address;
      _searchController.clear();
      _searchResults = [];
    });
    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(result.location, 16.0));
  }

  Future<String> _reverseGeocode(LatLng location) async {
    try {
      await setLocaleIdentifier('en_US');
      List<Placemark> placemarks = await placemarkFromCoordinates(location.latitude, location.longitude);
      if (placemarks.isNotEmpty) {
        Placemark pm = placemarks[0];
        return [pm.name, pm.street, pm.subLocality, pm.locality, pm.country]
            .where((e) => e != null && e.isNotEmpty)
            .join(', ');
      }
    } catch (e) {
      // Handle error if needed
    }
    return 'Custom Location (${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)})';
  }

  void _onMapTapped(LatLng location) async {
    // Simulate reverse geocoding for map-tapped location
    final name = await _reverseGeocode(location);
    setState(() {
      _selectedLocation = location;
      _selectedLocationName = name;
      _selectedLocationAddress = name; // Use same as name for simplicity
    });
  }

  void _confirmSelection() {
    if (_selectedLocation != null) {
      final bookingLocation = BookingLocation(
        lat: _selectedLocation!.latitude,
        lng: _selectedLocation!.longitude,
        address: _selectedLocationAddress ?? _selectedLocationName ?? 'Unknown Location',
        name: _selectedLocationName ?? 'Unknown Location',
      );

      final cubit = context.read<BookingCubit>();
      if (widget.editIndex == null) {
        cubit.addWaypoint(bookingLocation);
      } else {
        cubit.setLocation(widget.editIndex!, bookingLocation);
      }

      Navigator.of(context).pop();
    }
  }

  String get _title {
    if (widget.editIndex == null) {
      return 'Choose stop';
    }
    final state = context.read<BookingCubit>().state;
    if (widget.editIndex == 0) {
      return 'Choose pick up point';
    } else if (widget.editIndex == state.locations.length - 1) {
      return 'Choose destination';
    } else {
      return 'Choose stop';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fullscreen Map Background
          GoogleMap(
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
              // Move to initial position after creation
              if (_selectedLocation == null && _currentLocation != null) {
                _mapController!.animateCamera(CameraUpdate.newLatLngZoom(_currentLocation!, 15.0));
              }
            },
            initialCameraPosition: CameraPosition(
              target: _selectedLocation ?? _currentLocation ?? const LatLng(41.8781, -87.6298),
              zoom: _selectedLocation != null ? 16.0 : 13.0,
            ),
            onTap: _onMapTapped,
            markers: {
              // Current location marker
              if (_currentLocation != null)
                Marker(
                  markerId: const MarkerId('current'),
                  position: _currentLocation!,
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
                ),
              // Selected location marker
              if (_selectedLocation != null)
                Marker(
                  markerId: const MarkerId('selected'),
                  position: _selectedLocation!,
                ),
            },
            myLocationEnabled: true, // Optional: Show built-in current location button
            myLocationButtonEnabled: true,
            gestureRecognizers: {
              Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
            },
          ),

          // Header overlay with pink background
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.only(
                top: 50,
                left: 20,
                right: 20,
                bottom: 20,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  // Header row
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: AppColors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: AppColors.black,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _title,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Search field - fully rounded with border radius
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.black,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search location...',
                        hintStyle: TextStyle(
                          color: AppColors.textSecondary.withOpacity(0.7),
                          fontSize: 16,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: AppColors.textSecondary.withOpacity(0.6),
                          size: 30,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Search results overlay
          if (_searchResults.isNotEmpty || _isSearching)
            Positioned(
              top: 130,
              left: 20,
              right: 20,
              child: Container(
                constraints: const BoxConstraints(maxHeight: 300),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.border,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withOpacity(0.1),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: _isSearching
                    ? Container(
                  height: 80,
                  padding: const EdgeInsets.all(20),
                  child: const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 2.5,
                      ),
                    ),
                  ),
                )
                    : ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: _searchResults.length,
                    separatorBuilder: (context, index) => const Divider(
                      height: 1,
                      color: AppColors.border,
                    ),
                    itemBuilder: (context, index) {
                      final result = _searchResults[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        leading: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.primarySoft,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.location_on,
                            color: AppColors.primary,
                            size: 18,
                          ),
                        ),
                        title: Text(
                          result.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                            color: AppColors.black,
                            height: 1.3,
                          ),
                        ),
                        subtitle: Text(
                          result.address,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            height: 1.2,
                          ),
                        ),
                        onTap: () => _onLocationSelected(result),
                      );
                    },
                  ),
                ),
              ),
            ),

          // Confirm button
          if (_selectedLocation != null)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: GestureDetector(
                onTap: _confirmSelection,
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.black,
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withOpacity(0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'Confirm',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }
}

class LocationSearchResult {
  final String name;
  final String address;
  final LatLng location;

  LocationSearchResult({
    required this.name,
    required this.address,
    required this.location,
  });
}
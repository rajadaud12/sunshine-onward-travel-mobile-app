// location_selection_page.dart
// Adjusted to use editIndex instead of selectionType for elegance and support for waypoints.
// Updated to handle map-tapped locations with a placeholder name and prepare for reverse geocoding.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as lat_lng;
import 'package:geolocator/geolocator.dart';
import 'package:sot/core/config/app_colors.dart';
import 'package:sot/features/booking/state/booking_cubit.dart';
import 'package:sot/features/booking/state/booking_state.dart';

class LocationSelectionPage extends StatefulWidget {
  final int? editIndex;

  const LocationSelectionPage({
    Key? key,
    this.editIndex,
  }) : super(key: key);

  @override
  State<LocationSelectionPage> createState() => _LocationSelectionPageState();
}

class _LocationSelectionPageState extends State<LocationSelectionPage> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  lat_lng.LatLng? _selectedLocation;
  lat_lng.LatLng? _currentLocation;
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
        _selectedLocation = lat_lng.LatLng(loc.lat, loc.lng);
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
        _currentLocation = lat_lng.LatLng(position.latitude, position.longitude);
      });

      // Move map to current location if no selected location
      if (_selectedLocation == null) {
        _mapController.move(_currentLocation!, 15.0);
      }
    } catch (e) {
      // Fallback to Islamabad
      setState(() {
        _currentLocation = const lat_lng.LatLng(33.6844, 73.0479);
      });
      if (_selectedLocation == null) {
        _mapController.move(_currentLocation!, 13.0);
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

    // Mock search results for demonstration
    _performSearch(query);
  }

  void _performSearch(String query) {
    // Mock search results based on the query
    List<LocationSearchResult> results = [];

    if (query.toLowerCase().contains('heath')) {
      results.addAll([
        LocationSearchResult(
          name: 'Heathrow Airport Hounslow, UK',
          address: 'Longford TW6, UK',
          location: const lat_lng.LatLng(51.4700, -0.4543),
        ),
        LocationSearchResult(
          name: 'Heathrow Terminal 2 Short Stay Car Park',
          address: 'Hounslow TW6 1EW, UK',
          location: const lat_lng.LatLng(51.4697, -0.4520),
        ),
        LocationSearchResult(
          name: 'Heathrow Long Stay Terminal 5 North Car Park',
          address: 'Hounslow TW6, UK',
          location: const lat_lng.LatLng(51.4720, -0.4890),
        ),
      ]);
    } else if (query.toLowerCase().contains('islamabad')) {
      results.addAll([
        LocationSearchResult(
          name: 'Islamabad International Airport',
          address: 'Islamabad, Pakistan',
          location: const lat_lng.LatLng(33.5651, 72.8614),
        ),
        LocationSearchResult(
          name: 'Blue Area Islamabad',
          address: 'Blue Area, Islamabad, Pakistan',
          location: const lat_lng.LatLng(33.7077, 73.0563),
        ),
        LocationSearchResult(
          name: 'F-6 Markaz Islamabad',
          address: 'F-6, Islamabad, Pakistan',
          location: const lat_lng.LatLng(33.6973, 73.0515),
        ),
      ]);
    } else {
      // Generic results
      results.addAll([
        LocationSearchResult(
          name: '$query Location',
          address: 'Near $query, Pakistan',
          location: lat_lng.LatLng(
            33.6844 + (query.length * 0.001),
            73.0479 + (query.length * 0.001),
          ),
        ),
      ]);
    }

    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  void _onLocationSelected(LocationSearchResult result) {
    setState(() {
      _selectedLocation = result.location;
      _selectedLocationName = result.name;
      _selectedLocationAddress = result.address;
      _searchController.clear();
      _searchResults = [];
    });
    _mapController.move(result.location, 16.0);
  }

  Future<String> _reverseGeocode(lat_lng.LatLng location) async {
    // Placeholder for reverse geocoding
    // In a real app, use a service like Nominatim or Google Geocoding API
    // For now, return a mock name based on coordinates
    return 'Custom Location (${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)})';
  }

  void _onMapTapped(lat_lng.LatLng location) async {
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
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedLocation ??
                  _currentLocation ??
                  const lat_lng.LatLng(33.6844, 73.0479),
              initialZoom: _selectedLocation != null ? 16.0 : 13.0,
              onTap: (tapPosition, point) => _onMapTapped(point),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: [
                  // Current location marker
                  if (_currentLocation != null)
                    Marker(
                      point: _currentLocation!,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.white,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  // Selected location marker
                  if (_selectedLocation != null)
                    Marker(
                      point: _selectedLocation!,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.white,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.location_pin,
                          color: AppColors.white,
                          size: 28,
                        ),
                      ),
                    ),
                ],
              ),
            ],
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
    super.dispose();
  }
}

class LocationSearchResult {
  final String name;
  final String address;
  final lat_lng.LatLng location;

  LocationSearchResult({
    required this.name,
    required this.address,
    required this.location,
  });
}
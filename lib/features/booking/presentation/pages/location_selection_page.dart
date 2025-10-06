// location_selection_page.dart
import 'dart:convert';
import 'dart:math' as math;
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
  final String googleMapsApiKey;
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
  TextEditingController _searchController = TextEditingController();
  TextEditingController _fromController = TextEditingController();
  TextEditingController _toController = TextEditingController();
  FocusNode _searchFocusNode = FocusNode();
  FocusNode _fromFocusNode = FocusNode();
  FocusNode _toFocusNode = FocusNode();
  LatLng? _selectedLocation;
  String? _selectedLocationName;
  String? _selectedLocationAddress;
  LatLng? _fromLocation;
  String? _fromLocationName;
  String? _fromLocationAddress;
  LatLng? _toLocation;
  String? _toLocationName;
  String? _toLocationAddress;
  LatLng? _currentLocation;
  List<LocationSearchResult> _searchResults = [];
  bool _isSearching = false;
  String _lastFocused = 'to';

  static const LatLng heathrow = LatLng(51.4700, -0.4543);
  static const double fiveMiles = 5.0;
  static const double thirtyMiles = 30.0;

  static  List<LocationSearchResult> heathrowSuggestions = [
    LocationSearchResult(
      name: 'Heathrow Airport',
      address: 'Hounslow, United Kingdom',
      location: LatLng(51.4700, -0.4543),
    ),
    LocationSearchResult(
      name: 'Heathrow Terminal 2',
      address: 'Longford, Hounslow, United Kingdom',
      location: LatLng(51.4703, -0.4521),
    ),
    LocationSearchResult(
      name: 'Heathrow Terminal 3',
      address: 'Longford, Hounslow, United Kingdom',
      location: LatLng(51.4713, -0.4586),
    ),
    LocationSearchResult(
      name: 'Heathrow Terminal 4',
      address: 'Longford, Hounslow, United Kingdom',
      location: LatLng(51.4595, -0.4470),
    ),
    LocationSearchResult(
      name: 'Heathrow Terminal 5',
      address: 'Longford, Hounslow, United Kingdom',
      location: LatLng(51.4728, -0.4879),
    ),
  ];

  static const String _darkMapStyle = '[{"elementType":"geometry","stylers":[{"color":"#212121"}]},{"elementType":"labels.icon","stylers":[{"visibility":"off"}]},{"elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},{"elementType":"labels.text.stroke","stylers":[{"color":"#212121"}]},{"featureType":"administrative","elementType":"geometry","stylers":[{"color":"#757575"}]},{"featureType":"administrative.country","elementType":"labels.text.fill","stylers":[{"color":"#9e9e9e"}]},{"featureType":"administrative.land_parcel","stylers":[{"visibility":"off"}]},{"featureType":"administrative.locality","elementType":"labels.text.fill","stylers":[{"color":"#bdbdbd"}]},{"featureType":"poi","elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},{"featureType":"poi.park","elementType":"geometry","stylers":[{"color":"#181818"}]},{"featureType":"poi.park","elementType":"labels.text.fill","stylers":[{"color":"#616161"}]},{"featureType":"poi.park","elementType":"labels.text.stroke","stylers":[{"color":"#1b1b1b"}]},{"featureType":"road","elementType":"geometry.fill","stylers":[{"color":"#2c2c2c"}]},{"featureType":"road","elementType":"labels.text.fill","stylers":[{"color":"#8a8a8a"}]},{"featureType":"road.arterial","elementType":"geometry","stylers":[{"color":"#373737"}]},{"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#3c3c3c"}]},{"featureType":"road.highway.controlled_access","elementType":"geometry","stylers":[{"color":"#4e4e4e"}]},{"featureType":"road.local","elementType":"labels.text.fill","stylers":[{"color":"#616161"}]},{"featureType":"transit","elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},{"featureType":"water","elementType":"geometry","stylers":[{"color":"#000000"}]},{"featureType":"water","elementType":"labels.text.fill","stylers":[{"color":"#3d3d3d"}]}]';

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _initializeSelectedLocation();
    _fromFocusNode.addListener(() {
      if (_fromFocusNode.hasFocus) {
        _lastFocused = 'from';
        if (_fromController.text.isEmpty) {
          setState(() {
            _searchResults = heathrowSuggestions;
            _isSearching = false;
          });
        } else {
          _onSearchChanged(_fromController.text);
        }
      }
    });
    _toFocusNode.addListener(() {
      if (_toFocusNode.hasFocus) {
        _lastFocused = 'to';
        if (_toController.text.isEmpty) {
          setState(() {
            _searchResults = heathrowSuggestions;
            _isSearching = false;
          });
        } else {
          _onSearchChanged(_toController.text);
        }
      }
    });
    _searchFocusNode.addListener(() {
      if (_searchFocusNode.hasFocus) {
        _lastFocused = 'single';
        if (_searchController.text.isEmpty) {
          setState(() {
            _searchResults = heathrowSuggestions;
            _isSearching = false;
          });
        } else {
          _onSearchChanged(_searchController.text);
        }
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.editIndex == null) {
        if (_fromController.text.isEmpty) {
          _fromFocusNode.requestFocus();
        } else {
          _toFocusNode.requestFocus();
        }
      } else {
        _searchFocusNode.requestFocus();
      }
    });
  }

  void _initializeSelectedLocation() {
    final state = context.read<BookingCubit>().state;
    if (widget.editIndex != null && widget.editIndex! < state.locations.length) {
      final loc = state.locations[widget.editIndex!];
      if (loc != null) {
        _selectedLocation = LatLng(loc.lat, loc.lng);
        _selectedLocationName = loc.name ?? loc.address;
        _selectedLocationAddress = loc.address;
        _searchController.text = _selectedLocationName ?? '';
      }
    } else {
      if (state.locations.isNotEmpty && state.locations[0] != null) {
        final loc = state.locations[0]!;
        _fromLocation = LatLng(loc.lat, loc.lng);
        _fromLocationName = loc.name ?? loc.address;
        _fromLocationAddress = loc.address;
        _fromController.text = _fromLocationName!;
      }
      if (state.locations.length > 1 && state.locations.last != null) {
        final loc = state.locations.last!;
        _toLocation = LatLng(loc.lat, loc.lng);
        _toLocationName = loc.name ?? loc.address;
        _toLocationAddress = loc.address;
        _toController.text = _toLocationName!;
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
      if (_mapController != null) {
        _updateCamera();
      }
    } catch (e) {
      setState(() {
        _currentLocation = heathrow;
      });
      if (_mapController != null) {
        _updateCamera();
      }
    }
  }

  void _updateCamera() {
    if (_mapController == null) return;
    if (widget.editIndex != null) {
      if (_selectedLocation != null) {
        _mapController!.animateCamera(CameraUpdate.newLatLngZoom(_selectedLocation!, 16.0));
      } else if (_currentLocation != null) {
        _mapController!.animateCamera(CameraUpdate.newLatLngZoom(_currentLocation!, 15.0));
      }
    } else {
      List<LatLng> points = [];
      if (_fromLocation != null) points.add(_fromLocation!);
      if (_toLocation != null) points.add(_toLocation!);
      if (points.isEmpty) {
        if (_currentLocation != null) _mapController!.animateCamera(CameraUpdate.newLatLngZoom(_currentLocation!, 15.0));
        return;
      }
      if (points.length == 1) {
        _mapController!.animateCamera(CameraUpdate.newLatLngZoom(points.first, 16.0));
        return;
      }
      double minLat = points.map((e) => e.latitude).reduce((a, b) => a < b ? a : b);
      double maxLat = points.map((e) => e.latitude).reduce((a, b) => a > b ? a : b);
      double minLng = points.map((e) => e.longitude).reduce((a, b) => a < b ? a : b);
      double maxLng = points.map((e) => e.longitude).reduce((a, b) => a > b ? a : b);
      final bounds = LatLngBounds(
        southwest: LatLng(minLat, minLng),
        northeast: LatLng(maxLat, maxLng),
      );
      _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
    }
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = heathrowSuggestions;
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
        'https://maps.googleapis.com/maps/api/place/textsearch/json?query=$encodedQuery&location=$locBias&radius=50000&region=GB&key=${widget.googleMapsApiKey}',
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

  Future<void> _onLocationSelected(LocationSearchResult result) async {
    final (name, country) = await _reverseGeocode(result.location);
    if (country != 'United Kingdom') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a location within the UK')),
      );
      return;
    }
    setState(() {
      if (widget.editIndex != null) {
        _selectedLocation = result.location;
        _selectedLocationName = result.name;
        _selectedLocationAddress = result.address;
        _searchController.text = result.name;
        _searchResults = [];
      } else if (_lastFocused == 'from') {
        _fromLocation = result.location;
        _fromLocationName = result.name;
        _fromLocationAddress = result.address;
        _fromController.text = result.name;
        _searchResults = [];
      } else {
        _toLocation = result.location;
        _toLocationName = result.name;
        _toLocationAddress = result.address;
        _toController.text = result.name;
        _searchResults = [];
      }
    });
    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(result.location, 16.0)).then((_) {
      _mapController?.showMarkerInfoWindow(MarkerId(widget.editIndex != null ? 'selected' : _lastFocused == 'from' ? 'from' : 'to'));
    });
    _updateCamera();
  }

  Future<(String, String?)> _reverseGeocode(LatLng location) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(location.latitude, location.longitude);
      if (placemarks.isNotEmpty) {
        Placemark pm = placemarks[0];
        String address = [pm.name, pm.street, pm.subLocality, pm.locality, pm.country]
            .where((e) => e != null && e.isNotEmpty)
            .join(', ');
        String? country = pm.country;
        return (address, country);
      }
    } catch (e) {
      // Handle error if needed
    }
    return ('Custom Location (${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)})', null);
  }

  void _onMapTapped(LatLng location) async {
    final (name, country) = await _reverseGeocode(location);
    if (country != null && country != 'United Kingdom') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a location within the UK')),
      );
      return;
    }
    setState(() {
      if (widget.editIndex != null) {
        _selectedLocation = location;
        _selectedLocationName = name;
        _selectedLocationAddress = name;
        _searchController.text = name;
      } else if (_lastFocused == 'from') {
        _fromLocation = location;
        _fromLocationName = name;
        _fromLocationAddress = name;
        _fromController.text = name;
      } else {
        _toLocation = location;
        _toLocationName = name;
        _toLocationAddress = name;
        _toController.text = name;
      }
    });
    _mapController?.showMarkerInfoWindow(MarkerId(widget.editIndex != null ? 'selected' : _lastFocused == 'from' ? 'from' : 'to'));
    _updateCamera();
  }

  void _swapFromTo() {
    setState(() {
      final tempLocation = _fromLocation;
      final tempName = _fromLocationName;
      final tempAddress = _fromLocationAddress;
      final tempText = _fromController.text;

      _fromLocation = _toLocation;
      _fromLocationName = _toLocationName;
      _fromLocationAddress = _toLocationAddress;
      _fromController.text = _toController.text;

      _toLocation = tempLocation;
      _toLocationName = tempName;
      _toLocationAddress = tempAddress;
      _toController.text = tempText;
    });
    _updateCamera();
  }

  void _confirmSelection() {
    final cubit = context.read<BookingCubit>();
    var currentState = cubit.state;
    if (widget.editIndex != null) {
      if (_selectedLocation == null) return;
      final bookingLocation = BookingLocation(
        lat: _selectedLocation!.latitude,
        lng: _selectedLocation!.longitude,
        address: _selectedLocationAddress ?? _selectedLocationName ?? 'Unknown Location',
        name: _selectedLocationName ?? 'Unknown Location',
      );
      final LatLng newLocLatLng = LatLng(bookingLocation.lat, bookingLocation.lng);
      final double newDist = _haversineDistanceMiles(newLocLatLng, heathrow);
      List<BookingLocation?> tempLocations = List.from(currentState.locations);
      tempLocations[widget.editIndex!] = bookingLocation;
      if (tempLocations.any((loc) => loc == null)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please set all locations first.')),
        );
        return;
      }
      List<BookingLocation> proposed = tempLocations.cast<BookingLocation>();
      final pickupLatLng = LatLng(proposed[0].lat, proposed[0].lng);
      final destLatLng = LatLng(proposed.last.lat, proposed.last.lng);
      final pickupDist = _haversineDistanceMiles(pickupLatLng, heathrow);
      final destDist = _haversineDistanceMiles(destLatLng, heathrow);
      if (pickupDist > fiveMiles && destDist > fiveMiles) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ride must start or end within 5 miles of Heathrow Airport.')),
        );
        return;
      }
      double totalDist = 0.0;
      for (int i = 0; i < proposed.length - 1; i++) {
        final a = LatLng(proposed[i].lat, proposed[i].lng);
        final b = LatLng(proposed[i + 1].lat, proposed[i + 1].lng);
        totalDist += _haversineDistanceMiles(a, b);
      }
      if (totalDist < thirtyMiles) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Route distance must be at least 30 miles.')),
        );
        return;
      }
      cubit.setLocation(widget.editIndex!, bookingLocation);
    } else {
      if (_fromLocation == null || _toLocation == null) return;
      final fromLoc = BookingLocation(
        lat: _fromLocation!.latitude,
        lng: _fromLocation!.longitude,
        address: _fromLocationAddress ?? _fromLocationName ?? 'Unknown Location',
        name: _fromLocationName ?? 'Unknown Location',
      );
      final toLoc = BookingLocation(
        lat: _toLocation!.latitude,
        lng: _toLocation!.longitude,
        address: _toLocationAddress ?? _toLocationName ?? 'Unknown Location',
        name: _toLocationName ?? 'Unknown Location',
      );
      if (currentState.locations.isEmpty) {
        cubit.setStep(BookingStep.location);
        currentState = cubit.state;
      }
      List<BookingLocation?> tempLocations = List.from(currentState.locations);
      tempLocations[0] = fromLoc;
      tempLocations[tempLocations.length - 1] = toLoc;
      if (tempLocations.any((loc) => loc == null)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please set all locations first.')),
        );
        return;
      }
      List<BookingLocation> proposed = tempLocations.cast<BookingLocation>();
      final pickupLatLng = LatLng(proposed[0].lat, proposed[0].lng);
      final destLatLng = LatLng(proposed.last.lat, proposed.last.lng);
      final pickupDist = _haversineDistanceMiles(pickupLatLng, heathrow);
      final destDist = _haversineDistanceMiles(destLatLng, heathrow);
      if (pickupDist > fiveMiles && destDist > fiveMiles) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ride must start or end within 5 miles of Heathrow Airport.')),
        );
        return;
      }
      double totalDist = 0.0;
      for (int i = 0; i < proposed.length - 1; i++) {
        final a = LatLng(proposed[i].lat, proposed[i].lng);
        final b = LatLng(proposed[i + 1].lat, proposed[i + 1].lng);
        totalDist += _haversineDistanceMiles(a, b);
      }
      if (totalDist < thirtyMiles) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Route distance must be at least 30 miles.')),
        );
        return;
      }
      cubit.setLocation(0, fromLoc);
      cubit.setLocation(cubit.state.locations.length - 1, toLoc);
    }
    Navigator.of(context).pop();
  }

  double _haversineDistanceMiles(LatLng a, LatLng b) {
    const double earthRadiusMiles = 3958.8;
    final double dLat = _degToRad(b.latitude - a.latitude);
    final double dLng = _degToRad(b.longitude - a.longitude);
    final double lat1 = _degToRad(a.latitude);
    final double lat2 = _degToRad(b.latitude);
    final double sinDLat = math.sin(dLat / 2);
    final double sinDLng = math.sin(dLng / 2);
    final double aa = sinDLat * sinDLat + math.cos(lat1) * math.cos(lat2) * sinDLng * sinDLng;
    final double c = 2 * math.atan2(math.sqrt(aa), math.sqrt(1 - aa));
    return earthRadiusMiles * c;
  }

  double _degToRad(double deg) => deg * (math.pi / 180.0);

  String get _title {
    if (widget.editIndex == null) {
      return 'Enter your route';
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
    final isDual = widget.editIndex == null;
    final hasSelection = isDual ? (_fromLocation != null && _toLocation != null) : _selectedLocation != null;
    double suggestionsTop = isDual ? 230.0 : 172.0; // Adjust based on fields height
    final state = context.read<BookingCubit>().state;
    final len = state.locations.length;
    final i = widget.editIndex;
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
              controller.setMapStyle(_darkMapStyle);
              if (_currentLocation != null) {
                controller.animateCamera(CameraUpdate.newLatLngZoom(_currentLocation!, 15.0));
              }
            },
            initialCameraPosition: CameraPosition(
              target: _currentLocation ?? heathrow,
              zoom: 13.0,
            ),
            onTap: _onMapTapped,
            markers: {
              if (_currentLocation != null)
                Marker(
                  markerId: const MarkerId('current'),
                  position: _currentLocation!,
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
                ),
              if (_selectedLocation != null)
                Marker(
                  markerId: const MarkerId('selected'),
                  position: _selectedLocation!,
                  infoWindow: InfoWindow(
                    title: _selectedLocationName,
                    snippet: _selectedLocationAddress != _selectedLocationName ? _selectedLocationAddress : null,
                  ),
                ),
              if (_fromLocation != null)
                Marker(
                  markerId: const MarkerId('from'),
                  position: _fromLocation!,
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
                  infoWindow: InfoWindow(
                    title: _fromLocationName,
                    snippet: _fromLocationAddress != _fromLocationName ? _fromLocationAddress : null,
                  ),
                ),
              if (_toLocation != null)
                Marker(
                  markerId: const MarkerId('to'),
                  position: _toLocation!,
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                  infoWindow: InfoWindow(
                    title: _toLocationName,
                    snippet: _toLocationAddress != _toLocationName ? _toLocationAddress : null,
                  ),
                ),
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
              Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
            },
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
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
                  if (isDual)
                    SizedBox(
                      height: 50 * 2 + 8,
                      child: Stack(
                        children: [
                          Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  _fromFocusNode.requestFocus();
                                },
                                child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: AppColors.card,
                                    borderRadius: BorderRadius.circular(28),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  padding: const EdgeInsets.only(left: 56, right: 16),
                                  alignment: Alignment.centerLeft,
                                  child: TextField(
                                    controller: _fromController,
                                    focusNode: _fromFocusNode,
                                    onChanged: _onSearchChanged,
                                    decoration: InputDecoration(
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      border: InputBorder.none,
                                      hintText: 'Choose pick up point',
                                      hintStyle: TextStyle(color: AppColors.placeholder, fontSize: 14, height: 1.0),
                                      hintMaxLines: 1,
                                      contentPadding: EdgeInsets.zero,
                                      isDense: true,
                                    ),
                                    style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.0, overflow: TextOverflow.ellipsis),
                                    textAlignVertical: TextAlignVertical.center,
                                    maxLines: 1,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () {
                                  _toFocusNode.requestFocus();
                                },
                                child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: AppColors.card,
                                    borderRadius: BorderRadius.circular(28),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  padding: const EdgeInsets.only(left: 56, right: 16),
                                  alignment: Alignment.centerLeft,
                                  child: TextField(
                                    controller: _toController,
                                    focusNode: _toFocusNode,
                                    onChanged: _onSearchChanged,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,


                                      hintText: 'Choose your destination',
                                      hintStyle: TextStyle(color: AppColors.placeholder, fontSize: 14, height: 1.0),
                                      hintMaxLines: 1,
                                      contentPadding: EdgeInsets.zero,
                                      isDense: true,
                                    ),
                                    style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.0, overflow: TextOverflow.ellipsis),
                                    textAlignVertical: TextAlignVertical.center,
                                    maxLines: 1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Positioned(
                            left: 12,
                            top: (50 - 28) / 2,
                            child: _buildLocationIcon(0, _fromLocation != null),
                          ),
                          Positioned(
                            left: 12,
                            top: 50 + 8 + (50 - 28) / 2,
                            child: _buildLocationIcon(1, _toLocation != null),
                          ),
                          Positioned(
                            left: 12 + (28 / 2) - 1,
                            top: (50 - 28) / 2 + 28,
                            child: SizedBox(
                              width: 2,
                              height: 50 + 8 - 28,
                              child: CustomPaint(
                                painter: _DashLinePainter(),
                              ),
                            ),
                          ),

                        ],
                      ),
                    ),
                  if (!isDual)
                    SizedBox(
                      height: 50,
                      child: Stack(
                        children: [
                          GestureDetector(
                            onTap: () {
                              _searchFocusNode.requestFocus();
                            },
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: AppColors.card,
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(color: AppColors.border),
                              ),
                              padding: const EdgeInsets.only(left: 56, right: 16),
                              alignment: Alignment.centerLeft,
                              child: TextField(
                                controller: _searchController,
                                focusNode: _searchFocusNode,
                                onChanged: _onSearchChanged,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,

                                  hintText: 'Search location...',
                                  hintStyle: TextStyle(color: AppColors.placeholder, fontSize: 14, height: 1.0),
                                  hintMaxLines: 1,
                                  contentPadding: EdgeInsets.zero,
                                  isDense: true,
                                ),
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.0, overflow: TextOverflow.ellipsis),
                                textAlignVertical: TextAlignVertical.center,
                                maxLines: 1,
                              ),
                            ),
                          ),
                          Positioned(
                            left: 12,
                            top: (50 - 28) / 2,
                            child: _buildLocationIcon(widget.editIndex!, _selectedLocation != null),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (_searchResults.isNotEmpty || _isSearching)
            Positioned(
              top: suggestionsTop,
              left: 20,
              right: 20,
              child: Container(
                constraints: const BoxConstraints(maxHeight: 300),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border, width: 1),
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
                    itemCount: _searchResults.length + 1,
                    separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.border),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          leading: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.primarySoft,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.map,
                              color: AppColors.primary,
                              size: 18,
                            ),
                          ),
                          title: const Text(
                            'Choose on map',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                              color: AppColors.primary,
                              height: 1.3,
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              _searchResults = [];
                            });
                            FocusScope.of(context).unfocus();
                          },
                        );
                      } else {
                        final result = _searchResults[index - 1];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                      }
                    },
                  ),
                ),
              ),
            ),
          if (hasSelection)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: GestureDetector(
                onTap: _confirmSelection,
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color:  AppColors.primary,
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
                      'Done',
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

  Widget _buildLocationIcon(int i, bool isSet) {
    final color = isSet
        ? (i == 0 ? AppColors.success : i == 1 ? AppColors.primary : AppColors.waypoint)
        : AppColors.placeholder;
    if (i == 0) {
      return Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    } else {
      return Icon(
        Icons.location_on,
        color: color,
        size: 28,
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fromController.dispose();
    _toController.dispose();
    _searchFocusNode.dispose();
    _fromFocusNode.dispose();
    _toFocusNode.dispose();
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

class _DashLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.border;
    double y = 0;
    while (y < size.height) {
      canvas.drawLine(Offset(0, y), Offset(0, y + 7), paint);
      y += 7 + 6;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


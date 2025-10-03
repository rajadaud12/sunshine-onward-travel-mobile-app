// booking_state.dart
import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

enum BookingStep {
  location,
  dateTime,
  selectRide,
  payment,
  confirmation,
}

class BookingLocation extends Equatable {
  final double lat;
  final double lng;
  final String address;
  final String? name;

  const BookingLocation({
    required this.lat,
    required this.lng,
    required this.address,
    this.name,
  });

  @override
  List<Object?> get props => [lat, lng, address, name];

  BookingLocation copyWith({
    double? lat,
    double? lng,
    String? address,
    String? name,
  }) {
    return BookingLocation(
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      address: address ?? this.address,
      name: name ?? this.name,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lng': lng,
      'address': address,
      'name': name,
    };
  }

  factory BookingLocation.fromJson(Map<String, dynamic> json) {
    return BookingLocation(
      lat: json['lat']?.toDouble() ?? 0.0,
      lng: json['lng']?.toDouble() ?? 0.0,
      address: json['address'] ?? '',
      name: json['name'],
    );
  }
}

class BookingState extends Equatable {
  final BookingStep? currentStep;
  final List<BookingLocation?> locations;
  final DateTime? departureDate;
  final String? selectedVehicle;
  final bool isLoading;
  final String? error;
  final String? selectedPaymentMethod;
  final List<LatLng>? routePoints;
  final double? distanceMiles;
  final Duration? estimatedTime;

  const BookingState({
    this.currentStep,
    this.locations = const [],
    this.departureDate,
    this.selectedVehicle,
    this.isLoading = false,
    this.error,
    this.selectedPaymentMethod,
    this.routePoints,
    this.distanceMiles,
    this.estimatedTime,
  });

  @override
  List<Object?> get props => [
    currentStep,
    locations,
    departureDate,
    selectedVehicle,
    isLoading,
    error,
    selectedPaymentMethod,
    routePoints,
    distanceMiles,
    estimatedTime,
  ];

  BookingState copyWith({
    BookingStep? currentStep,
    List<BookingLocation?>? locations,
    DateTime? departureDate,
    String? selectedVehicle,
    bool? isLoading,
    String? error,
    String? selectedPaymentMethod,
    List<LatLng>? routePoints,
    double? distanceMiles,
    Duration? estimatedTime,
  }) {
    return BookingState(
      currentStep: currentStep ?? this.currentStep,
      locations: locations ?? this.locations,
      departureDate: departureDate ?? this.departureDate,
      selectedVehicle: selectedVehicle ?? this.selectedVehicle,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      selectedPaymentMethod: selectedPaymentMethod ?? this.selectedPaymentMethod,
      routePoints: routePoints ?? this.routePoints,
      distanceMiles: distanceMiles ?? this.distanceMiles,
      estimatedTime: estimatedTime ?? this.estimatedTime,
    );
  }

  bool get canProceed {
    switch (currentStep) {
      case BookingStep.location:
        return locations.length >= 2 && locations.every((loc) => loc != null);
      case BookingStep.dateTime:
        return departureDate != null;
      case BookingStep.selectRide:
        print('canProceed for selectRide: ${selectedVehicle != null}, selectedVehicle: $selectedVehicle');
        return selectedVehicle != null;
      case BookingStep.payment:
        return selectedPaymentMethod != null;
      default:
        return true;
    }
  }

  String getLocationDisplay(int index) {
    final loc = locations[index];
    if (loc != null) return loc.name ?? loc.address;
    if (index == 0) return 'Choose pick up point';
    if (index == locations.length - 1) return 'Choose your destination';
    return 'Choose stop';
  }
}
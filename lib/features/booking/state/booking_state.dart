// booking_state.dart (no changes needed)
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
  final List<Map<String, dynamic>> pricingModels;
  final List<Map<String, dynamic>> offHours;
  final Map<String, double> vehiclePrices;
  final String? email;
  final String? phone;
  final String? additionalInfo;

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
    this.pricingModels = const [],
    this.offHours = const [],
    this.vehiclePrices = const {},
    this.email,
    this.phone,
    this.additionalInfo,
  });

  @override
  List<Object?> get props =>
      [
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
        pricingModels,
        offHours,
        vehiclePrices,
        email,
        phone,
        additionalInfo,
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
    List<Map<String, dynamic>>? pricingModels,
    List<Map<String, dynamic>>? offHours,
    Map<String, double>? vehiclePrices,
    String? email,
    String? phone,
    String? additionalInfo,
  }) {
    return BookingState(
      currentStep: currentStep ?? this.currentStep,
      locations: locations ?? this.locations,
      departureDate: departureDate ?? this.departureDate,
      selectedVehicle: selectedVehicle ?? this.selectedVehicle,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      selectedPaymentMethod: selectedPaymentMethod ??
          this.selectedPaymentMethod,
      routePoints: routePoints ?? this.routePoints,
      distanceMiles: distanceMiles ?? this.distanceMiles,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      pricingModels: pricingModels ?? this.pricingModels,
      offHours: offHours ?? this.offHours,
      vehiclePrices: vehiclePrices ?? this.vehiclePrices,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      additionalInfo: additionalInfo ?? this.additionalInfo,
    );
  }

  bool get canProceed {
    switch (currentStep) {
      case BookingStep.location:
        return locations.length >= 2 &&
            locations.every((loc) => loc != null) &&
            error == null &&
            distanceMiles != null &&
            estimatedTime != null;
      case BookingStep.dateTime:
        return departureDate != null && error == null;
      case BookingStep.selectRide:
        print('canProceed for selectRide: ${selectedVehicle !=
            null}, selectedVehicle: $selectedVehicle');
        return selectedVehicle != null && vehiclePrices.containsKey(selectedVehicle) && error == null;
      case BookingStep.payment:
        return selectedPaymentMethod != null && error == null;
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
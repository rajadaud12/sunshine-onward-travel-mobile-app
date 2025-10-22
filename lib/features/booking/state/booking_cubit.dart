// booking_cubit.dart (updated to remove invalid cast)
import 'dart:convert';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:sot/core/utils/api_service.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:sot/features/booking/state/booking_state.dart';

class BookingCubit extends Cubit<BookingState> {
  final String googleMapsApiKey;
  final PolylinePoints _polylinePoints;
  BookingCubit({required this.googleMapsApiKey})
      : _polylinePoints = PolylinePoints(apiKey: googleMapsApiKey),
        super(const BookingState());

  static const LatLng heathrow = LatLng(51.4700, -0.4543);
  static const double fiveMilesMeters = 8046.72;
  static const double thirtyMilesMeters = 48280.32;
  static const double thirtyMiles = 30.0;

  double _parseTime(String timeStr) {
    final parts = timeStr.split(':').map(int.parse).toList();
    return parts[0] + parts[1] / 60.0;
  }

  void setStep(BookingStep step) {
    if (step == BookingStep.location && state.locations.isEmpty) {
      emit(state.copyWith(locations: <BookingLocation?>[null, null], currentStep: step));
    } else {
      emit(state.copyWith(currentStep: step));
    }
  }
  void setLocation(int index, BookingLocation loc) {
    if (index < 0 || index >= state.locations.length) return;
    final List<BookingLocation?> newLocations = List<BookingLocation?>.from(state.locations);
    newLocations[index] = loc;
    emit(state.copyWith(locations: newLocations));
    _fetchRoute();
  }
  void addWaypoint() {
    if (state.locations.length < 2) return;
    final List<BookingLocation?> newLocations = List<BookingLocation?>.from(state.locations);
    newLocations.insert(newLocations.length - 1, null);
    emit(state.copyWith(locations: newLocations));
    _fetchRoute();
  }
  void removeLocation(int index) {
    if (index <= 0 || index >= state.locations.length - 1) return;
    final List<BookingLocation?> newLocations = List<BookingLocation?>.from(state.locations);
    newLocations.removeAt(index);
    emit(state.copyWith(locations: newLocations));
    _fetchRoute();
  }
  void setDepartureDateTime(DateTime dt) => emit(state.copyWith(departureDate: dt));
  void selectVehicle(String vehicle) {
    print('Selecting vehicle: $vehicle');
    emit(state.copyWith(selectedVehicle: vehicle));
  }
  Future<void> proceedToNextStep() async {
    switch (state.currentStep) {
      case BookingStep.location:
        if (state.canProceed) setStep(BookingStep.dateTime);
        break;
      case BookingStep.dateTime:
        if (state.canProceed) {
          if (state.pricingModels.isEmpty) {
            await fetchPricingRules();
          }
          setStep(BookingStep.selectRide);
          calculateAllPrices();
        }
        break;
      case BookingStep.selectRide:
        if (state.canProceed) setStep(BookingStep.payment);
        break;
      case BookingStep.payment:
        setStep(BookingStep.confirmation);
        break;
      case BookingStep.confirmation:
        break;
      default:
        setStep(BookingStep.location);
    }
  }
  void goToPreviousStep() {
    switch (state.currentStep) {
      case BookingStep.dateTime:
        setStep(BookingStep.location);
        break;
      case BookingStep.selectRide:
        setStep(BookingStep.dateTime);
        break;
      case BookingStep.payment:
        setStep(BookingStep.selectRide);
        break;
      case BookingStep.confirmation:
        setStep(BookingStep.payment);
        break;
      default:
        break;
    }
  }
  void reset() => emit(const BookingState());
  void selectPaymentMethod(String method) => emit(state.copyWith(selectedPaymentMethod: method));
  void clearError() => emit(state.copyWith(error: null));

  void setUserDetails({String? email, String? phone, String? additionalInfo}) {
    emit(state.copyWith(
      email: email ?? state.email,
      phone: phone ?? state.phone,
      additionalInfo: additionalInfo ?? state.additionalInfo,
    ));
  }

  Future<void> createBooking() async {
    if (state.isLoading) return;
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final List<Map<String, dynamic>> locationsJson = state.locations
          .where((l) => l != null)
          .cast<BookingLocation>()
          .map((l) => l.toJson())
          .toList();

      final Map<String, dynamic> data = {
        'locations': locationsJson,
        'departureDate': state.departureDate?.toIso8601String(),
        'selectedVehicle': state.selectedVehicle,
        'price': state.vehiclePrices[state.selectedVehicle ?? ''],
        'distanceMiles': state.distanceMiles,
        'estimatedTimeMinutes': state.estimatedTime?.inMinutes,
        'paymentMethod': state.selectedPaymentMethod,
        'email': state.email,
        'phone': state.phone,
        'additionalInfo': state.additionalInfo,
      };

      final response = await ApiService.post('/bookings', data); // Removed invalid cast
      if (response.statusCode == 201 || response.statusCode == 200) {
        emit(state.copyWith(currentStep: BookingStep.confirmation, error: null));
        // Optionally reset() or emit success message
        print('Booking created successfully');
      } else {
        emit(state.copyWith(error: 'Failed to create booking: ${response.statusCode}'));
      }
    } catch (e) {
      emit(state.copyWith(error: 'Error creating booking: $e'));
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<double?> getRouteDistance(List<BookingLocation> locations) async {
    if (locations.length < 2) return null;
    final pickupLatLng = LatLng(locations.first.lat, locations.first.lng);
    final destLatLng = LatLng(locations.last.lat, locations.last.lng);
    final double pickupDistMeters = _haversineDistanceMeters(pickupLatLng, heathrow);
    final double destDistMeters = _haversineDistanceMeters(destLatLng, heathrow);
    final bool isValid = (pickupDistMeters <= fiveMilesMeters) || (destDistMeters <= fiveMilesMeters);
    if (!isValid) {
      return null;
    }
    try {
      final String origin = '${locations.first.lat},${locations.first.lng}';
      final String destination = '${locations.last.lat},${locations.last.lng}';
      String? waypointsParam;
      if (locations.length > 2) {
        final List<BookingLocation> intermediates = locations.sublist(1, locations.length - 1);
        waypointsParam = intermediates.map((l) => '${l.lat},${l.lng}').join('|');
      }
      final Uri uri = Uri.https('maps.googleapis.com', '/maps/api/directions/json', <String, String>{
        'origin': origin,
        'destination': destination,
        if (waypointsParam != null && waypointsParam.isNotEmpty) 'waypoints': waypointsParam,
        'mode': 'driving',
        'key': googleMapsApiKey,
      });
      final http.Response response = await http.get(uri);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body) as Map<String, dynamic>;
        if ((data['status'] as String?) == 'OK' && (data['routes'] as List).isNotEmpty) {
          final Map<String, dynamic> route = (data['routes'] as List).first as Map<String, dynamic>;
          double distanceMeters = 0.0;
          final List<dynamic>? legs = route['legs'] as List<dynamic>?;
          if (legs != null) {
            for (final dynamic legRaw in legs) {
              final Map<String, dynamic> leg = legRaw as Map<String, dynamic>;
              final Map<String, dynamic>? dist = leg['distance'] as Map<String, dynamic>?;
              if (dist != null && dist['value'] != null) {
                distanceMeters += (dist['value'] as num).toDouble();
              }
            }
          }
          if (distanceMeters == 0.0) return null;
          final double distanceMiles = distanceMeters / 1609.34;
          return distanceMiles;
        }
      }
    } catch (e) {
      print('Directions API exception: $e');
    }
    // legacy per leg
    double totalMeters = 0.0;
    for (int i = 0; i < locations.length - 1; i++) {
      final PointLatLng origin = PointLatLng(locations[i].lat, locations[i].lng);
      final PointLatLng destination = PointLatLng(locations[i + 1].lat, locations[i + 1].lng);
      try {
        final PolylineResult result = await _polylinePoints.getRouteBetweenCoordinates(
          request: PolylineRequest(
            origin: origin,
            destination: destination,
            mode: TravelMode.driving,
          ),
        );
        if (result.points.isNotEmpty) {
          final List<LatLng> legPoints = result.points.map((p) => LatLng(p.latitude, p.longitude)).toList();
          final double legMeters = _haversineDistanceMetersFromPoints(legPoints);
          totalMeters += legMeters;
        } else {
          final double legMeters = _haversineDistanceMeters(LatLng(origin.latitude, origin.longitude),
              LatLng(destination.latitude, destination.longitude));
          totalMeters += legMeters;
        }
      } catch (e) {
        print('Error fetching legacy leg $i: $e');
        return null;
      }
    }
    if (totalMeters == 0.0) return null;
    final double distanceMiles = totalMeters / 1609.34;
    return distanceMiles;
  }
  Future<void> _fetchRoute() async {
    if (state.locations.any((loc) => loc == null) || state.locations.length < 2) {
      emit(state.copyWith(routePoints: null, distanceMiles: null, estimatedTime: null, error: null));
      return;
    }
    final List<BookingLocation> locations = state.locations.cast<BookingLocation>();
    final double? distanceMiles = await getRouteDistance(locations);
    if (distanceMiles == null) {
      emit(state.copyWith(
        routePoints: null,
        distanceMiles: null,
        estimatedTime: null,
        error: 'Invalid route.',
      ));
      return;
    }
    if (distanceMiles < thirtyMiles) {
      emit(state.copyWith(
        routePoints: null,
        distanceMiles: null,
        estimatedTime: null,
        error: 'Route distance must be at least 30 miles.',
      ));
      return;
    }
    // fetch the full route
    try {
      final String origin = '${locations.first.lat},${locations.first.lng}';
      final String destination = '${locations.last.lat},${locations.last.lng}';
      String? waypointsParam;
      if (locations.length > 2) {
        final List<BookingLocation> intermediates = locations.sublist(1, locations.length - 1);
        waypointsParam = intermediates.map((l) => '${l.lat},${l.lng}').join('|');
      }
      final Uri uri = Uri.https('maps.googleapis.com', '/maps/api/directions/json', <String, String>{
        'origin': origin,
        'destination': destination,
        if (waypointsParam != null && waypointsParam.isNotEmpty) 'waypoints': waypointsParam,
        'mode': 'driving',
        'key': googleMapsApiKey,
      });
      final http.Response response = await http.get(uri);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body) as Map<String, dynamic>;
        if ((data['status'] as String?) == 'OK' && (data['routes'] as List).isNotEmpty) {
          final Map<String, dynamic> route = (data['routes'] as List).first as Map<String, dynamic>;
          final Map<String, dynamic>? overviewPolyline = route['overview_polyline'] as Map<String, dynamic>?;
          List<LatLng> routePoints = <LatLng>[];
          if (overviewPolyline != null && overviewPolyline['points'] != null) {
            final String encoded = overviewPolyline['points'] as String;
            routePoints = _decodePolyline(encoded);
          }
          int durationSeconds = 0;
          final List<dynamic>? legs = route['legs'] as List<dynamic>?;
          if (legs != null) {
            for (final dynamic legRaw in legs) {
              final Map<String, dynamic> leg = legRaw as Map<String, dynamic>;
              final Map<String, dynamic>? dur = leg['duration'] as Map<String, dynamic>?;
              if (dur != null && dur['value'] != null) {
                durationSeconds += (dur['value'] as num).toInt();
              }
            }
          }
          if (durationSeconds == 0 && distanceMiles > 0.0) {
            durationSeconds = _estimateDurationFromDistance(distanceMiles).inSeconds;
          }
          final Duration estimated = Duration(seconds: durationSeconds);
          emit(state.copyWith(routePoints: routePoints, distanceMiles: distanceMiles, estimatedTime: estimated, error: null));
          return;
        } else {
          print('Directions API status: ${data['status']} error_message: ${data['error_message'] ?? 'none'}');
        }
      } else {
        print('Directions HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      print('Directions API exception: $e');
    }
    // legacy for points
    final List<LatLng> allPoints = <LatLng>[];
    int totalSeconds = 0;
    for (int i = 0; i < locations.length - 1; i++) {
      final PointLatLng origin = PointLatLng(locations[i].lat, locations[i].lng);
      final PointLatLng destination = PointLatLng(locations[i + 1].lat, locations[i + 1].lng);
      try {
        final PolylineResult result = await _polylinePoints.getRouteBetweenCoordinates(
          request: PolylineRequest(
            origin: origin,
            destination: destination,
            mode: TravelMode.driving,
          ),
        );
        if (result.points.isNotEmpty) {
          final List<LatLng> legPoints = result.points.map((p) => LatLng(p.latitude, p.longitude)).toList();
          if (allPoints.isNotEmpty && legPoints.isNotEmpty && allPoints.last == legPoints.first) {
            allPoints.addAll(legPoints.skip(1));
          } else {
            allPoints.addAll(legPoints);
          }
          final int legSeconds = _estimateDurationFromDistance(distanceMiles / locations.length).inSeconds;
          totalSeconds += legSeconds;
        } else {
          final int legSeconds = _estimateDurationFromDistance(distanceMiles / locations.length).inSeconds;
          totalSeconds += legSeconds;
        }
      } catch (e) {
        print('Error fetching legacy leg $i: $e');
        continue;
      }
    }
    final Duration estimated = Duration(seconds: totalSeconds > 0 ? totalSeconds : _estimateDurationFromDistance(distanceMiles).inSeconds);
    emit(state.copyWith(routePoints: allPoints, distanceMiles: distanceMiles, estimatedTime: estimated, error: null));
  }
  double _haversineDistanceMeters(LatLng a, LatLng b) {
    const double earthRadius = 6371000;
    final double dLat = _degToRad(b.latitude - a.latitude);
    final double dLng = _degToRad(b.longitude - a.longitude);
    final double lat1 = _degToRad(a.latitude);
    final double lat2 = _degToRad(b.latitude);
    final double sinDLat = sin(dLat / 2);
    final double sinDLng = sin(dLng / 2);
    final double aa = sinDLat * sinDLat + cos(lat1) * cos(lat2) * sinDLng * sinDLng;
    final double c = 2 * atan2(sqrt(aa), sqrt(1 - aa));
    return earthRadius * c;
  }
  double _degToRad(double deg) => deg * (pi / 180.0);
  List<LatLng> _decodePolyline(String encoded) {
    final List<LatLng> poly = <LatLng>[];
    int index = 0;
    final int length = encoded.length;
    int lat = 0;
    int lng = 0;
    while (index < length) {
      int shift = 0;
      int result = 0;
      int byte;
      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1F) << shift;
        shift += 5;
      } while (byte >= 0x20 && index < length);
      final int deltaLat = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lat += deltaLat;
      shift = 0;
      result = 0;
      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1F) << shift;
        shift += 5;
      } while (byte >= 0x20 && index < length);
      final int deltaLng = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lng += deltaLng;
      final double finalLat = lat / 1e5;
      final double finalLng = lng / 1e5;
      poly.add(LatLng(finalLat, finalLng));
    }
    return poly;
  }
  double _haversineDistanceMetersFromPoints(List<LatLng> points) {
    if (points.length < 2) return 0.0;
    double meters = 0.0;
    for (int i = 0; i < points.length - 1; i++) {
      meters += _haversineDistanceMeters(points[i], points[i + 1]);
    }
    return meters;
  }
  Duration _estimateDurationFromDistance(double distanceMiles) {
    const double averageSpeedMph = 25.0;
    final double hours = distanceMiles / averageSpeedMph;
    return Duration(seconds: (hours * 3600).round());
  }

  Future<void> fetchPricingRules() async {
    if (state.pricingModels.isNotEmpty) return;
    try {
      final response = await ApiService.get('/rules');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Fetched pricingModels: ${data['pricingModels']}');
        print('Fetched offHours: ${data['offHours']}');
        emit(state.copyWith(
          pricingModels: List<Map<String, dynamic>>.from(data['pricingModels']),
          offHours: List<Map<String, dynamic>>.from(data['offHours']),
        ));
      } else {
        emit(state.copyWith(error: 'Failed to fetch pricing rules'));
      }
    } catch (e) {
      emit(state.copyWith(error: 'Error fetching pricing rules: $e'));
    }
  }

  void calculateAllPrices() {
    if (state.distanceMiles == null || state.departureDate == null || state.pricingModels.isEmpty) return;

    Map<String, double> prices = {};
    final double distanceMiles = state.distanceMiles!;
    final DateTime departure = state.departureDate!;
    final double time = departure.hour + departure.minute / 60.0;

    for (final String vehicle in ['Saloon', 'Estate', 'Executive']) {
      final model = state.pricingModels.firstWhere(
            (m) => m['category'] == vehicle,
        orElse: () => <String, dynamic>{},
      );
      if (model.isEmpty) continue;

      final double perMile = (model['perMilePrice'] as num).toDouble();

      double total = distanceMiles * perMile;

      final Iterable<Map<String, dynamic>> offHoursForCat = state.offHours.where((o) => o['category'] == vehicle);
      for (final off in offHoursForCat) {
        final double start = _parseTime(off['startTime'] as String);
        final double end = _parseTime(off['endTime'] as String);
        final bool inRange = (start <= end) ? time >= start && time < end : time >= start || time < end;
        if (inRange) {
          final String priceType = off['priceType'] as String;
          final double value = (off['priceValue'] as num).toDouble();
          if (priceType == 'fixed') {
            total += value;
          } else if (priceType == 'percentage') {
            total *= (1 + value / 100);
          } else if (priceType == 'multiplier') {
            total *= value;
          }
          break; // apply only one
        }
      }

      print('Calculated price for $vehicle: $total (perMile: $perMile, distMiles: $distanceMiles)');
      prices[vehicle] = total;
    }

    emit(state.copyWith(vehiclePrices: prices));
  }
}
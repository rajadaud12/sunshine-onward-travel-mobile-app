// booking_cubit.dart
import 'dart:convert';
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:sot/features/booking/state/booking_state.dart';

class BookingCubit extends Cubit<BookingState> {
  final String googleMapsApiKey;
  final PolylinePoints _polylinePoints;

  BookingCubit({required this.googleMapsApiKey})
      : _polylinePoints = PolylinePoints(apiKey: googleMapsApiKey),
        super(const BookingState());

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

  void addWaypoint(BookingLocation loc) {
    if (state.locations.length < 2) return;
    final List<BookingLocation?> newLocations = List<BookingLocation?>.from(state.locations);
    newLocations.insert(newLocations.length - 1, loc);
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
    // optional debug
    // ignore: avoid_print
    print('Selecting vehicle: $vehicle');
    emit(state.copyWith(selectedVehicle: vehicle));
  }

  void proceedToNextStep() {
    switch (state.currentStep) {
      case BookingStep.location:
        if (state.canProceed) setStep(BookingStep.dateTime);
        break;
      case BookingStep.dateTime:
        if (state.canProceed) setStep(BookingStep.selectRide);
        break;
      case BookingStep.selectRide:
        if (state.canProceed) setStep(BookingStep.payment);
        break;
      case BookingStep.payment:
        setStep(BookingStep.confirmation);
        break;
      case BookingStep.confirmation:
      // completed
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

  Future<void> _fetchRoute() async {
    final List<BookingLocation> locations = state.locations.whereType<BookingLocation>().toList();
    if (locations.length < 2) {
      emit(state.copyWith(routePoints: null, distanceMiles: null, estimatedTime: null));
      return;
    }

    try {
      // Build Directions API request (HTTP Directions API as primary)
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

          double distanceMeters = 0.0;
          int durationSeconds = 0;

          final List<dynamic>? legs = route['legs'] as List<dynamic>?;
          if (legs != null) {
            for (final dynamic legRaw in legs) {
              final Map<String, dynamic> leg = legRaw as Map<String, dynamic>;
              final Map<String, dynamic>? dist = leg['distance'] as Map<String, dynamic>?;
              final Map<String, dynamic>? dur = leg['duration'] as Map<String, dynamic>?;

              if (dist != null && dist['value'] != null) {
                distanceMeters += (dist['value'] as num).toDouble();
              }
              if (dur != null && dur['value'] != null) {
                durationSeconds += (dur['value'] as num).toInt();
              }
            }
          }

          if (distanceMeters == 0.0 && routePoints.isNotEmpty) {
            distanceMeters = _haversineDistanceMetersFromPoints(routePoints);
          }
          if (durationSeconds == 0 && distanceMeters > 0.0) {
            durationSeconds = _estimateDurationFromDistance(distanceMeters / 1609.34).inSeconds;
          }

          final double distanceMiles = distanceMeters / 1609.34;
          final Duration estimated = Duration(seconds: durationSeconds);

          emit(state.copyWith(routePoints: routePoints, distanceMiles: distanceMiles, estimatedTime: estimated));
          return;
        } else {
          // ignore: avoid_print
          print('Directions API status: ${data['status']} error_message: ${data['error_message'] ?? 'none'}');
        }
      } else {
        // ignore: avoid_print
        print('Directions HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      // ignore: avoid_print
      print('Directions API exception: $e');
    }

    // Fallback: per-leg polyline_points fetch (uses flutter_polyline_points)
    await _fetchRouteLegacyPerLeg(locations);
  }

  // Fallback: fetch each leg pairwise and stitch polylines
  Future<void> _fetchRouteLegacyPerLeg(List<BookingLocation> locations) async {
    final List<LatLng> allPoints = <LatLng>[];
    double totalMeters = 0.0;
    int totalSeconds = 0;

    for (int i = 0; i < locations.length - 1; i++) {
      final PointLatLng origin = PointLatLng(locations[i].lat, locations[i].lng);
      final PointLatLng destination = PointLatLng(locations[i + 1].lat, locations[i + 1].lng);

      try {
        // Use named 'request' parameter per newer polyline_points API
        final PolylineResult result = await _polylinePoints.getRouteBetweenCoordinates(
          request: PolylineRequest(
            origin: origin,
            destination: destination,
            mode: TravelMode.driving,
          ),
        );

        if (result.points.isNotEmpty) {
          final List<LatLng> legPoints =
          result.points.map((PointLatLng p) => LatLng(p.latitude, p.longitude)).toList();

          // avoid duplicating the first point of subsequent legs
          if (allPoints.isNotEmpty && legPoints.isNotEmpty && allPoints.last == legPoints.first) {
            allPoints.addAll(legPoints.skip(1));
          } else {
            allPoints.addAll(legPoints);
          }

          // Compute leg distance from decoded points (avoids relying on package-specific getters)
          final double legMeters = _haversineDistanceMetersFromPoints(legPoints);
          totalMeters += legMeters;

          // Estimate leg duration (seconds) from leg distance (miles)
          final int legSeconds = _estimateDurationFromDistance(legMeters / 1609.34).inSeconds;
          totalSeconds += legSeconds;
        } else {
          // If no points returned, as best-effort compute straight distance between origin/destination
          final double legMeters = _haversineDistanceMeters(LatLng(origin.latitude, origin.longitude),
              LatLng(destination.latitude, destination.longitude));
          totalMeters += legMeters;
          totalSeconds += _estimateDurationFromDistance(legMeters / 1609.34).inSeconds;
        }
      } catch (e) {
        // ignore: avoid_print
        print('Error fetching legacy leg $i: $e');
        continue;
      }
    }

    if (allPoints.isEmpty) {
      emit(state.copyWith(routePoints: null, distanceMiles: null, estimatedTime: null));
      return;
    }

    final double distanceMiles = totalMeters / 1609.34;
    final Duration estimated =
    Duration(seconds: totalSeconds > 0 ? totalSeconds : _estimateDurationFromDistance(distanceMiles).inSeconds);

    emit(state.copyWith(routePoints: allPoints, distanceMiles: distanceMiles, estimatedTime: estimated));
  }

  double _haversineDistanceMetersFromPoints(List<LatLng> points) {
    if (points.length < 2) return 0.0;
    double meters = 0.0;
    for (int i = 0; i < points.length - 1; i++) {
      meters += _haversineDistanceMeters(points[i], points[i + 1]);
    }
    return meters;
  }

  // Estimate duration using fallback average speed (if Directions/Routes API durations are not available)
  Duration _estimateDurationFromDistance(double distanceMiles) {
    const double averageSpeedMph = 25.0;
    final double hours = distanceMiles / averageSpeedMph;
    return Duration(seconds: (hours * 3600).round());
  }

  double _haversineDistanceMeters(LatLng a, LatLng b) {
    const double earthRadius = 6371000; // meters
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

  /// Decode an encoded polyline string (Google polyline algorithm) into a list of LatLng.
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
}

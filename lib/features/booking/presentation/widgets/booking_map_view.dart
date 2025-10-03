// booking_map_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sot/features/booking/state/booking_cubit.dart';
import 'package:sot/features/booking/state/booking_state.dart';

class BookingMapView extends StatefulWidget {
  const BookingMapView({super.key});

  @override
  State<BookingMapView> createState() => _BookingMapViewState();
}

class _BookingMapViewState extends State<BookingMapView> {
  GoogleMapController? _mapController;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BookingCubit, BookingState>(
      listener: (context, state) {
        _updateMap(state);
      },
      builder: (context, state) {
        final locationPoints = state.locations
            .whereType<BookingLocation>()
            .map((loc) => LatLng(loc.lat, loc.lng))
            .toList();

        final markers = <Marker>{};
        for (int i = 0; i < locationPoints.length; i++) {
          double hue = i == 0
              ? BitmapDescriptor.hueGreen
              : (i == locationPoints.length - 1
              ? BitmapDescriptor.hueRed
              : BitmapDescriptor.hueViolet);
          markers.add(Marker(
            markerId: MarkerId('$i'),
            position: locationPoints[i],
            icon: BitmapDescriptor.defaultMarkerWithHue(hue),
          ));
        }

        final polylines = <Polyline>{};
        if (state.routePoints != null && state.routePoints!.length >= 2) {
          polylines.add(Polyline(
            polylineId: const PolylineId('route'),
            points: state.routePoints!,
            color: Colors.blue,
            width: 5,
          ));
        } else if (locationPoints.length >= 2) {
          // Fallback to straight line if routePoints not available (e.g., fetch failed or in progress)
          polylines.add(Polyline(
            polylineId: const PolylineId('route'),
            points: locationPoints,
            color: Colors.red,
            width: 5,
          ));
        }

        return GoogleMap(
          onMapCreated: (controller) {
            _mapController = controller;
            _updateMap(state);
          },
          initialCameraPosition: CameraPosition(
            target: locationPoints.isNotEmpty ? locationPoints.first : const LatLng(41.8781, -87.6298),
            zoom: 13.0,
          ),
          markers: markers,
          polylines: polylines,
        );
      },
    );
  }

  void _updateMap(BookingState state) async {
    if (_mapController == null) return;

    final locationPoints = state.locations
        .whereType<BookingLocation>()
        .map((loc) => LatLng(loc.lat, loc.lng))
        .toList();

    if (locationPoints.isEmpty) return;

    final boundPoints = (state.routePoints != null && state.routePoints!.isNotEmpty)
        ? state.routePoints!
        : locationPoints;

    if (boundPoints.length == 1) {
      _mapController!.animateCamera(CameraUpdate.newLatLngZoom(boundPoints.first, 15.0));
      return;
    }

    // Fit bounds
    double minLat = boundPoints.map((p) => p.latitude).reduce((a, b) => a < b ? a : b);
    double minLng = boundPoints.map((p) => p.longitude).reduce((a, b) => a < b ? a : b);
    double maxLat = boundPoints.map((p) => p.latitude).reduce((a, b) => a > b ? a : b);
    double maxLng = boundPoints.map((p) => p.longitude).reduce((a, b) => a > b ? a : b);

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
  }
}
// widgets/booking_map_view.dart
// Added polyline for route and multiple markers with colors.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as lat_lng;
import 'package:sot/features/booking/state/booking_cubit.dart';
import 'package:sot/features/booking/state/booking_state.dart';

class BookingMapView extends StatelessWidget {
  const BookingMapView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookingCubit, BookingState>(
      builder: (context, state) {
        final List<lat_lng.LatLng> points = state.locations
            .where((loc) => loc != null)
            .map((loc) => lat_lng.LatLng(loc!.lat, loc.lng))
            .toList();

        return FlutterMap(
          options: MapOptions(
            initialCenter: const lat_lng.LatLng(41.8781, -87.6298), // Chicago as default
            initialZoom: 13.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: const ['a', 'b', 'c'],
            ),
            MarkerLayer(
              markers: List.generate(state.locations.length, (i) {
                final loc = state.locations[i];
                if (loc == null) return null;
                Color color = i == 0
                    ? Colors.green
                    : i == state.locations.length - 1
                    ? Colors.red
                    : Colors.purple;
                return Marker(
                  point: lat_lng.LatLng(loc.lat, loc.lng),
                  child: Icon(Icons.location_pin, color: color, size: 40),
                );
              }).whereType<Marker>().toList(),
            ),
            PolylineLayer(
              polylines: [
                if (points.length >= 2)
                  Polyline(
                    points: points,
                    color: Colors.red,
                    strokeWidth: 5,
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}
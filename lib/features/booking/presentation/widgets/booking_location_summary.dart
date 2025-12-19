// booking_location_summary.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sot/core/config/app_colors.dart';
import 'package:sot/features/booking/presentation/pages/location_selection_page.dart';
import 'package:sot/features/booking/state/booking_cubit.dart';
import 'package:sot/features/booking/state/booking_state.dart';

class BookingLocationSummary extends StatelessWidget {
  final BookingState state;

  const BookingLocationSummary({
    super.key,
    required this.state,
  });

  void _openLocationSelection(BuildContext context, int? editIndex) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 1.0,
        minChildSize: 1.0,
        maxChildSize: 1.0,
        expand: false,
        builder: (context, scrollController) =>
            LocationSelectionPage(editIndex: editIndex, googleMapsApiKey: 'AIzaSyCPhfNzOVaHkHU7ewiwJGUvf8CxtYD3Mz8',),
      ),
    );
  }

  void _showStopsPopup(BuildContext context) {
    final len = state.locations.length;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Route Details'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: len,
            separatorBuilder: (_, __) => const Divider(color: AppColors.border, height: 1),
            itemBuilder: (c, i) => ListTile(
              leading: _iconForIndex(i, len),
              title: Text(
                state.getLocationDisplay(i) ?? 'Unknown Location',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              onTap: () {
                Navigator.pop(c);
                _openLocationSelection(context, i);
              },
              trailing: (i > 0 && i < len - 1)
                  ? IconButton(
                icon: const Icon(Icons.close, color: AppColors.placeholder),
                onPressed: () {
                  Navigator.pop(c);
                  context.read<BookingCubit>().removeLocation(i);
                },
              )
                  : null,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _pickupIcon() {
    return Container(
      width: 18,
      height: 18,
      decoration: const BoxDecoration(
        color: AppColors.success,
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: SizedBox(
          width: 8,
          height: 8,
          child: DecoratedBox(
            decoration: BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
          ),
        ),
      ),
    );
  }

  Widget _waypointIcon() {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: AppColors.waypoint,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
        ),
      ),
    );
  }

  Widget _destinationIcon() {
    return const Icon(
      Icons.location_on,
      color: AppColors.primary,
      size: 18,
    );
  }

  static const double _rowHeight = 40;
  static const double _addPillWidth = 84;
  static const double _addPillHeight = 36;

  static const double _closeBtnWidth = 36;

  Widget _addPill(BuildContext context, {required bool enabled}) {
    final pill = GestureDetector(
      onTap: enabled ? () {
        final cubit = context.read<BookingCubit>();
        final newLocations = List<BookingLocation?>.from(state.locations);
        newLocations.insert(newLocations.length - 1, null);
        cubit.emit(state.copyWith(locations: newLocations));
        _openLocationSelection(context, newLocations.length - 2);
      } : null,
      child: Container(
        width: _addPillWidth,
        height: _addPillHeight,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: enabled ? AppColors.card : AppColors.border.withOpacity(0.7),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: enabled ? AppColors.border : AppColors.border.withOpacity(0.7),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.add,
                  size: 14,
                  color: enabled ? AppColors.textSecondary : AppColors.placeholder.withOpacity(0.6),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Add',
              style: TextStyle(
                color: enabled ? AppColors.textSecondary : const Color(0xFF656565).withOpacity(0.6),
                fontSize: 12,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
              ),
            )
          ],
        ),
      ),
    );

    if (enabled) return pill;

    return Tooltip(
      message: 'Maximum of 3 waypoints reached',
      child: AbsorbPointer(child: pill),
    );
  }

  TextStyle _rowTextStyle() {
    return const TextStyle(
      color: Color(0xFF656565),
      fontSize: 14,
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w400,
    );
  }

  Widget _iconForIndex(int i, int len) {
    if (i == 0) return _pickupIcon();
    if (i == len - 1) return _destinationIcon();
    return _waypointIcon();
  }

  @override
  Widget build(BuildContext context) {
    final locations = state.locations;
    final len = locations.length;

    final int waypointCount = (len >= 2) ? (len - 2) : 0;
    final bool canAddWaypoint = waypointCount < 3;

    final double addPillTop = _rowHeight - (_addPillHeight / 2);

    final double trailingReserve = _addPillWidth + 12;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pickup row
              GestureDetector(
                onTap: () {
                  final editIndex = (len == 2) ? null : 0;
                  _openLocationSelection(context, editIndex);
                },
                child: SizedBox(
                  height: _rowHeight,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(width: 7),
                      _pickupIcon(),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          state.getLocationDisplay(0),
                          style: _rowTextStyle(),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: trailingReserve),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 8, right: 16),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.border,
                ),
              ),
              // Destination row
              SizedBox(
                height: _rowHeight,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(width: 7),
                    _destinationIcon(),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          final editIndex = (len == 2) ? null : len - 1;
                          _openLocationSelection(context, editIndex);
                        },
                        child: Text(
                          state.getLocationDisplay(len - 1),
                          style: _rowTextStyle(),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    if (waypointCount > 0)
                      GestureDetector(
                        onTap: () => _showStopsPopup(context),
                        child: Text(
                          ' • $waypointCount stop${waypointCount > 1 ? 's' : ''}',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    SizedBox(width: trailingReserve),
                  ],
                ),
              ),
            ],
          ),
          if (len >= 1)
            Positioned(
              right: 12,
              top: addPillTop,
              child: _addPill(context, enabled: canAddWaypoint),
            ),
        ],
      ),
    );
  }
}
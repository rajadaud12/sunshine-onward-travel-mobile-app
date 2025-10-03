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

  // Icons for pickup / waypoint / destination
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

  // fixed sized add pill so we can align its center with divider
  static const double _cardWidth = 302;
  static const double _rowHeight = 40;
  static const double _addPillWidth = 84;
  static const double _addPillHeight = 36;

  // width used by the close icon button (approx)
  static const double _closeBtnWidth = 36;

  Widget _addPill(BuildContext context, {required bool enabled}) {
    final pill = GestureDetector(
      onTap: enabled ? () => _openLocationSelection(context, null) : null,
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
                color: enabled ? AppColors.card : AppColors.border.withOpacity(0.7),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.add,
                  size: 14,
                  color: enabled ? AppColors.placeholder : AppColors.placeholder.withOpacity(0.6),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Add',
              style: TextStyle(
                color: const Color(0xFF656565).withOpacity(enabled ? 1.0 : 0.6),
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

    // when disabled show a tooltip explaining why (max waypoints reached)
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

    // number of intermediate waypoints (excluding pickup + destination)
    final int waypointCount = (len >= 2) ? (len - 2) : 0;
    final bool canAddWaypoint = waypointCount < 3;

    // place add pill so its center overlaps the divider between row 0 and row 1
    final double addPillTop = _rowHeight - (_addPillHeight / 2);

    // Reserve enough right-side space for the add pill so row content never goes under it.
    // trailingReserve = pill width + small margin
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
      child: SizedBox(
        width: _cardWidth,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // If there are no locations at all, show a placeholder first row to keep layout sane
                if (len == 0) ...[
                  SizedBox(
                    height: _rowHeight,
                    child: Row(
                      children: [
                        const SizedBox(width: 7),
                        _pickupIcon(),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Add pickup',
                            style: _rowTextStyle(),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: trailingReserve),
                      ],
                    ),
                  ),
                ],

                for (int i = 0; i < len; i++) ...[
                  InkWell(
                    onTap: () => _openLocationSelection(context, i),
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      height: _rowHeight,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(width: 7),
                          _iconForIndex(i, len),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              state.getLocationDisplay(i),
                              style: _rowTextStyle(),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          // Put row-specific controls (close icon for intermediate waypoints)
                          if (i > 0 && i < len - 1)
                            Container(
                              width: _closeBtnWidth,
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: const Icon(Icons.close, size: 18, color: Color(0xFFAAAAAA)),
                                onPressed: () => context.read<BookingCubit>().removeLocation(i),
                              ),
                            ),

                          // ALWAYS reserve the right area (so nothing moves under the Add pill)
                          SizedBox(width: trailingReserve - (i > 0 && i < len - 1 ? 0 : 0)),
                        ],
                      ),
                    ),
                  ),

                  // divider between rows, left inset to align under the text (icon area is spared)
                  if (i < len - 1)
                    Padding(
                      padding: const EdgeInsets.only(left: 8, right: 8),
                      child: Divider(
                        height: 1,
                        thickness: 1,
                        color: AppColors.border,
                      ),
                    ),
                ],
              ],
            ),

            // Positioned add pill so its center overlaps the divider after the first row
            if (len >= 1)
              Positioned(
                right: 12,
                top: addPillTop,
                child: _addPill(context, enabled: canAddWaypoint),
              ),
          ],
        ),
      ),
    );
  }
}
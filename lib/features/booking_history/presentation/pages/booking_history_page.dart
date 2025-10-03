// lib/features/booking_history/presentation/pages/bookings_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sot/core/config/app_colors.dart';
import 'package:sot/features/booking_history/state/booking_history_cubit.dart';
import 'package:sot/features/booking_history/state/booking_history_state.dart';

class BookingsPage extends StatefulWidget {
  const BookingsPage({super.key});

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  @override
  void initState() {
    super.initState();
    context.read<BookingHistoryCubit>().loadBookings();
  }

  String _formatTime(DateTime time, {bool includeEST = false}) {
    var hour12 = time.hour % 12;
    hour12 = hour12 == 0 ? 12 : hour12;
    final minuteStr = time.minute.toString().padLeft(2, '0');
    final amPm = time.hour < 12 ? 'AM' : 'PM';
    return '$hour12:$minuteStr $amPm${includeEST ? ' EST' : ''}';
  }

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top;
    final double headerHeight = topPadding + 120;
    final double extraOverlap = 40; // how much the sheet visually overlaps the header

    return BlocBuilder<BookingHistoryCubit, BookingHistoryState>(
      builder: (context, state) {
        // bottom safe area + extra breathing room so last card won't be clipped
        final double bottomPad = MediaQuery.of(context).padding.bottom + 40;

        return Scaffold(
          backgroundColor: AppColors.primary,
          body: Stack(
            children: [
              // 1) NestedScrollView with header sliver (pink top) and body (the white sheet)
              NestedScrollView(
                headerSliverBuilder: (ctx, innerBoxIsScrolled) {
                  return [
                    SliverToBoxAdapter(
                      child: Container(
                        height: headerHeight - extraOverlap, // the visible header part
                        color: AppColors.primary,
                      ),
                    ),
                  ];
                },
                body: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Container(
                    color: AppColors.white,
                    child: SafeArea(
                      top: false,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(20, 28 + 6, 20, bottomPad),
                        children: [
                          const Text(
                            'Active',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black),
                          ),
                          const SizedBox(height: 12),
                          if (state.activeBookings.isEmpty)
                            const Center(child: Text('No active bookings', style: TextStyle(color: Colors.grey)))
                          else
                            ...state.activeBookings.map((b) => _bookingCard(b, isHistory: false)).toList(),

                          const SizedBox(height: 22),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'History',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black),
                              ),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: Container(
                                  height: 36,
                                  color: AppColors.black,
                                  padding: const EdgeInsets.symmetric(horizontal: 6),
                                  child: DropdownButtonHideUnderline(
                                    child: Center(
                                      child: DropdownButton<String>(
                                        value: state.historyFilter,
                                        isDense: true,
                                        dropdownColor: AppColors.black,
                                        icon: const Icon(Icons.arrow_drop_down, color: AppColors.white),
                                        style: const TextStyle(color: AppColors.white, fontSize: 13),
                                        onChanged: (String? nv) {
                                          if (nv != null) {
                                            context.read<BookingHistoryCubit>().changeFilter(nv);
                                          }
                                        },
                                        items: <String>['This Month', 'Last Month', 'This Year']
                                            .map((v) => DropdownMenuItem<String>(
                                          value: v,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 8),
                                            child: Text(v, style: const TextStyle(fontSize: 13)),
                                          ),
                                        ))
                                            .toList(),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          if (state.historyBookings.isEmpty)
                            const Center(child: Text('No history bookings', style: TextStyle(color: Colors.grey)))
                          else
                            ...state.historyBookings.map((b) => _bookingCard(b, isHistory: true)).toList(),

                          const SizedBox(height: 12),
                          // final spacer — ensures the last card never touches the rounded bottom edge
                          SizedBox(height: bottomPad),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // 2) Header content overlay (close button + title), always visible and tappable
              Positioned(
                top: topPadding + 10,
                left: 16,
                right: 16,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
                        child: const Icon(Icons.close, color: AppColors.black, size: 20),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 50),
                        child: Text(
                          'Bookings',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ) ??
                              const TextStyle(
                                color: AppColors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _bookingCard(Booking booking, {required bool isHistory}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
      child: Column(
        children: [
          // Top tinted panel (rounded top corners)
          Container(
            decoration: const BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(width: 20, height: 20, decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle), child: const Center(child: Icon(Icons.circle, size: 8, color: AppColors.white))),
                    const SizedBox(width: 12),
                    Expanded(child: Text(booking.pickup, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black))),
                    Text(_formatTime(booking.departureTime), style: const TextStyle(fontSize: 12, color: Color(0xFFAAAAAA), fontWeight: FontWeight.w400)),
                  ],
                ),

                // Dashed vertical connector aligned under the waypoint
                Padding(
                    padding: const EdgeInsets.only(left: 9, top: 10, bottom: 8),
                    child: SizedBox(width: 2, height: 20, child: CustomPaint(painter: _DashLinePainter(dashHeight: 4, gap: 5, color: AppColors.border)))),
                Row(
                  children: [
                    const Icon(Icons.location_pin, color: AppColors.primary, size: 24),
                    const SizedBox(width: 12),
                    Expanded(child: Text(booking.destination, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black))),
                    Text(_formatTime(booking.arrivalTime, includeEST: true), style: const TextStyle(fontSize: 12, color: Color(0xFFAAAAAA), fontWeight: FontWeight.w400)),
                  ],
                ),
              ],
            ),
          ),

          // Bottom action row (rounded bottom corners)
          Container(
            decoration: const BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.vertical(bottom: Radius.circular(12))),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                const Expanded(child: Text('View Details  ⌄', style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w500))),
                if (isHistory)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(color: AppColors.success.withOpacity(0.14), borderRadius: BorderRadius.circular(20)),
                    child: const Text('Completed', style: TextStyle(color: AppColors.success, fontSize: 13, fontWeight: FontWeight.w500)),
                  )
                else
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    child: IconButton(
                      onPressed: () {
                        // handle chat action
                      },
                      icon: const Icon(Icons.message, color: AppColors.white, size: 20),
                      splashRadius: 22,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Dashed vertical painter used between pickup and destination
class _DashLinePainter extends CustomPainter {
  final double dashWidth;
  final double dashHeight;
  final double gap;
  final Color color;
  final double radius;

  _DashLinePainter({
    this.dashWidth = 2,
    this.dashHeight = 7,
    this.gap = 6,
    this.color = AppColors.border,
    this.radius = 3,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    double y = 0;
    final double centerX = (size.width - dashWidth) / 2;
    while (y < size.height) {
      final rect = Rect.fromLTWH(centerX, y, dashWidth, dashHeight);
      final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
      canvas.drawRRect(rrect, paint);
      y += dashHeight + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

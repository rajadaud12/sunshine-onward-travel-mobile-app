import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sot/core/config/app_colors.dart';
import 'package:sot/features/booking_history/state/booking_history_cubit.dart';
import 'package:sot/features/booking_history/state/booking_history_state.dart';
import 'package:sot/features/booking/presentation/pages/booking_home_page.dart';

class BookingsPage extends StatefulWidget {
  const BookingsPage({super.key});

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  @override
  void initState() {
    super.initState();
    // Load bookings when page opens
    context.read<BookingHistoryCubit>().loadBookings();
  }

  String _formatTime(DateTime time) {
    var hour12 = time.hour % 12;
    hour12 = hour12 == 0 ? 12 : hour12;
    final minuteStr = time.minute.toString().padLeft(2, '0');
    final amPm = time.hour < 12 ? 'AM' : 'PM';
    return '${time.month}/${time.day} $hour12:$minuteStr $amPm';
  }

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top;
    final double headerHeight = topPadding + 120;
    final double extraOverlap = 40;

    return BlocBuilder<BookingHistoryCubit, BookingHistoryState>(
      builder: (context, state) {
        final double bottomPad = MediaQuery.of(context).padding.bottom + 40;

        return Scaffold(
          backgroundColor: AppColors.primary,
          body: Stack(
            children: [
              // 1) Pull-to-refresh & List
              RefreshIndicator(
                onRefresh: () async {
                  await context.read<BookingHistoryCubit>().loadBookings();
                },
                child: NestedScrollView(
                  headerSliverBuilder: (ctx, innerBoxIsScrolled) {
                    return [
                      SliverToBoxAdapter(
                        child: Container(
                          height: headerHeight - extraOverlap,
                          color: AppColors.primary,
                        ),
                      ),
                    ];
                  },
                  body: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: Container(
                      color: AppColors.white,
                      child: state.isLoading && state.activeBookings.isEmpty && state.historyBookings.isEmpty
                          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                          : SafeArea(
                        top: false,
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(20, 28 + 6, 20, bottomPad),
                          children: [
                            // --- Active Section ---
                            const Text(
                              'Active',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black),
                            ),
                            const SizedBox(height: 12),
                            if (state.activeBookings.isEmpty)
                              const Padding(
                                padding: EdgeInsets.only(bottom: 20),
                                child: Center(child: Text('No active bookings', style: TextStyle(color: Colors.grey))),
                              )
                            else
                              ...state.activeBookings.map((b) => _bookingCard(b, isHistory: false)).toList(),

                            const SizedBox(height: 10),

                            // --- History Section ---
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
                              const Padding(
                                padding: EdgeInsets.only(top: 20),
                                child: Center(child: Text('No history bookings', style: TextStyle(color: Colors.grey))),
                              )
                            else
                              ...state.historyBookings.map((b) => _bookingCard(b, isHistory: true)).toList(),

                            SizedBox(height: bottomPad),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // 2) Custom App Bar Overlay with Smart Close Logic
              Positioned(
                top: topPadding + 10,
                left: 16,
                right: 16,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (Navigator.canPop(context)) {
                          // Standard Back behavior
                          Navigator.pop(context);
                        } else {
                          // If no page behind, replace current with Home
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => const BookingHomePage()),
                          );
                        }
                      },
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
                          style: const TextStyle(
                            fontFamily: 'Poppins',
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

              // 3) Error Toast (Optional overlay for errors)
              if (state.error != null)
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(8)),
                    child: Text(state.error!, style: const TextStyle(color: Colors.white)),
                  ),
                )
            ],
          ),
        );
      },
    );
  }

  Widget _bookingCard(Booking booking, {required bool isHistory}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border)),
      child: Column(
        children: [
          // Top Info Section
          Container(
            decoration: const BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              children: [
                // Pickup Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 20, height: 20, decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle), child: const Center(child: Icon(Icons.circle, size: 8, color: AppColors.white))),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Text(
                          booking.pickup,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        )
                    ),
                    const SizedBox(width: 8),
                    Text(_formatTime(booking.departureTime), style: const TextStyle(fontSize: 12, color: Color(0xFFAAAAAA), fontWeight: FontWeight.w400)),
                  ],
                ),
                // Dashed Line
                Padding(
                    padding: const EdgeInsets.only(left: 9, top: 2, bottom: 2),
                    child: SizedBox(width: 2, height: 20, child: CustomPaint(painter: _DashLinePainter(dashHeight: 4, gap: 5, color: AppColors.border)))),
                // Destination Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_pin, color: AppColors.primary, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Text(
                          booking.destination,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black),
                          maxLines: 2, // Allow up to 2 lines
                          overflow: TextOverflow.ellipsis, // Add ... if too long
                          softWrap: true, // Enable wrapping
                        )
                    ),
                    const SizedBox(width: 8),
                    // Display Cost
                    Text('\$${booking.cost.toStringAsFixed(2)}', style: const TextStyle(fontSize: 14, color: AppColors.primary, fontWeight: FontWeight.w700)),
                  ],
                ),
              ],
            ),
          ),

          // Bottom Action Section
          Container(
            decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(12))),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Vehicle Info
                Text('Vehicle: ${booking.carCategory}', style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)),

                if (isHistory)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                        color: booking.status == 'cancelled' ? Colors.red.withOpacity(0.1) : AppColors.success.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(20)
                    ),
                    child: Text(
                        booking.status.toUpperCase(),
                        style: TextStyle(
                            color: booking.status == 'cancelled' ? Colors.red : AppColors.success,
                            fontSize: 11,
                            fontWeight: FontWeight.w700
                        )
                    ),
                  )
                else
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(color: Colors.orange.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                        child: Text(booking.status.toUpperCase(), style: const TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 10),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashLinePainter extends CustomPainter {
  final double dashWidth;
  final double dashHeight;
  final double gap;
  final Color color;
  final double radius;

  _DashLinePainter({this.dashWidth = 2, this.dashHeight = 7, this.gap = 6, this.color = AppColors.border, this.radius = 3});

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
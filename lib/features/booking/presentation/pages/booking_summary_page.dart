import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Added for fetching user email
import 'package:sot/core/config/app_colors.dart';
import 'package:sot/core/widgets/custom_text_field.dart';
import 'package:sot/features/booking/presentation/pages/payment_method_page.dart';
import 'package:sot/features/booking/state/booking_cubit.dart';
import 'package:sot/features/booking/state/booking_state.dart';

class BookingSummaryPage extends StatefulWidget {
  const BookingSummaryPage({super.key});

  @override
  State<BookingSummaryPage> createState() => _BookingSummaryPageState();
}

class _BookingSummaryPageState extends State<BookingSummaryPage> {
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _additionalController;

  @override
  void initState() {
    super.initState();

    // Fetch current user email from Firebase
    final user = FirebaseAuth.instance.currentUser;

    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: ''); // Started empty as requested
    _additionalController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _additionalController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _getVehicleDetails(String? selectedVehicle) {
    final vehicles = [
      {'name': 'Saloon', 'capacity': '2-3 person', 'image': 'assets/images/car1.png'},
      {'name': 'Estate', 'capacity': '3-4 person', 'image': 'assets/images/car2.png'},
      {'name': 'Executive', 'capacity': '3-4 person', 'image': 'assets/images/car3.png'},
    ];
    return vehicles.firstWhere((v) => v['name'] == selectedVehicle, orElse: () => vehicles[1]);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookingCubit, BookingState>(
      builder: (context, state) {
        final cubit = context.read<BookingCubit>(); // Reference to cubit
        final vehicle = _getVehicleDetails(state.selectedVehicle);
        final price = state.vehiclePrices[state.selectedVehicle ?? ''] ?? 0.0;
        final departureDate = state.departureDate ?? DateTime.now();

        const months = [
          '', 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'
        ];
        final dateStr = '${departureDate.day}-${months[departureDate.month]}-${departureDate.year}';
        var hour12 = departureDate.hour % 12;
        hour12 = hour12 == 0 ? 12 : hour12;
        final departureTimeStr = '$hour12:${departureDate.minute.toString().padLeft(2, '0')} ${departureDate.hour < 12 ? 'AM' : 'PM'}';
        final tripDuration = state.estimatedTime ?? const Duration(hours: 3, minutes: 48);
        final arrivalDate = departureDate.add(tripDuration);
        var arrivalHour12 = arrivalDate.hour % 12;
        arrivalHour12 = arrivalHour12 == 0 ? 12 : arrivalHour12;
        final arrivalTimeStr = '${arrivalHour12}:${arrivalDate.minute.toString().padLeft(2, '0')} ${arrivalDate.hour < 12 ? 'AM' : 'PM'} EST';
        final pickup = state.locations.isNotEmpty && state.locations[0] != null ? (state.locations[0]!.name ?? state.locations[0]!.address) : 'State Park';
        final destination = state.locations.isNotEmpty && state.locations.last != null ? (state.locations.last!.name ?? state.locations.last!.address) : 'Heathrow Airport';
        final priceStr = price.toStringAsFixed(2).replaceAll('.', ',');

        return Scaffold(
          body: Stack(
            children: [
              // Header
              Container(
                height: MediaQuery.of(context).padding.top + 120,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                ),
                child: Padding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 10,
                    left: 16,
                    right: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: AppColors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, color: AppColors.black, size: 20),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 50),
                          child: Text(
                            'Booking Summary',
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
              ),
              // Main content
              Positioned.fill(
                top: MediaQuery.of(context).padding.top + 100,
                bottom: 80,
                child: SingleChildScrollView(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Vehicle Card
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                              border: Border.all(color: AppColors.border),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Image.asset(vehicle['image'] as String, width: 120, height: 80, fit: BoxFit.contain),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(vehicle['name'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black)),
                                      Text(vehicle['capacity'] as String, style: const TextStyle(fontSize: 12, color: Color(0xFF656565))),
                                    ],
                                  ),
                                ),
                                Text('\$$priceStr', style: const TextStyle(color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                          // Route Details
                          Container(
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
                              border: Border(
                                left: BorderSide(color: AppColors.border),
                                right: BorderSide(color: AppColors.border),
                                bottom: BorderSide(color: AppColors.border),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildInfoColumn('Departure Date', dateStr),
                                      _buildInfoColumn('Departure Time', departureTimeStr),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  // Pickup
                                  Row(
                                    children: [
                                      const Icon(Icons.circle, color: AppColors.success, size: 20),
                                      const SizedBox(width: 12),
                                      Expanded(child: Text(pickup, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
                                      Text(departureTimeStr, style: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 12)),
                                    ],
                                  ),
                                  _buildDashLine(),
                                  // Destination
                                  Row(
                                    children: [
                                      const Icon(Icons.location_pin, color: AppColors.primary, size: 24),
                                      const SizedBox(width: 12),
                                      Expanded(child: Text(destination, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
                                      Text(arrivalTimeStr, style: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 12)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Input Fields
                          CustomTextField(label: 'Email', hintText: 'Enter your email', controller: _emailController),
                          const SizedBox(height: 16),
                          CustomTextField(label: 'Phone No', hintText: 'Enter your phone number', controller: _phoneController),
                          const SizedBox(height: 16),
                          CustomTextField(label: 'Additional Information (Optional)', hintText: 'Flight Number etc.', controller: _additionalController),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Bottom Confirm Button
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: const BoxDecoration(
                    color: AppColors.card,
                    border: Border(top: BorderSide(color: AppColors.border)),
                  ),
                  child: Row(
                    children: [
                      _buildBackButton(context),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            // SYNC UI VALUES TO CUBIT STATE
                            cubit.setUserDetails(
                              email: _emailController.text,
                              phone: _phoneController.text,
                              additionalInfo: _additionalController.text,
                            );

                            Navigator.push(context, MaterialPageRoute(builder: (context) => const PaymentMethodPage()));
                          },
                          child: _buildConfirmButton(priceStr),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- Helper Widgets to keep build clean ---

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF656565), fontSize: 12)),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
      ],
    );
  }

  Widget _buildDashLine() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 9),
        child: SizedBox(
          width: 2,
          height: 20,
          child: CustomPaint(painter: _DashLinePainter(dashHeight: 4, gap: 4, color: AppColors.border)),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return SizedBox(
      width: 100,
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          height: 45,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: AppColors.black, width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.arrow_back, size: 18, color: AppColors.black),
              SizedBox(width: 8),
              Text('Back', style: TextStyle(color: AppColors.black, fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmButton(String priceStr) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          height: 45,
          padding: const EdgeInsets.symmetric(horizontal: 44),
          decoration: BoxDecoration(color: AppColors.black, borderRadius: BorderRadius.circular(50)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Confirm', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(width: 12),
              Text('\$${double.parse(priceStr.replaceAll(',', '.')).toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        Positioned(
          right: 4,
          child: Container(
            height: 35,
            width: 35,
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: AppColors.black)),
            child: const Icon(Icons.chevron_right, size: 22, color: AppColors.black),
          ),
        ),
      ],
    );
  }
}

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
    final double centerX = size.width / 2 - dashWidth / 2;
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
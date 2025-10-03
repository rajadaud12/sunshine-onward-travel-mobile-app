// booking_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sot/core/config/app_colors.dart';
import 'package:sot/core/routes/app_routes.dart';
import 'package:sot/features/booking/presentation/pages/location_selection_page.dart';
import 'package:sot/features/booking/state/booking_cubit.dart';
import 'package:sot/features/booking/state/booking_state.dart';

class BookingBottomSheet extends StatelessWidget {
  final BookingState state;

  const BookingBottomSheet({
    Key? key,
    required this.state,
  }) : super(key: key);

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
        builder: (context, scrollController) => LocationSelectionPage(editIndex: editIndex, googleMapsApiKey: 'AIzaSyCPhfNzOVaHkHU7ewiwJGUvf8CxtYD3Mz8',),
      ),
    );
  }

  Widget _buildLocationContent(BuildContext context) {
    const double fieldHeight = 45;
    const double spacing = 16;
    const double outerIconSize = 28;
    const double innerWhiteSize = 12;
    const double locationIconSize = 28;

    final titleStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: const Color(0xFF080A24),
    ) ??
        const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF080A24),
        );

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Where are you going today?',
            style: titleStyle,
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: (state.locations.length * fieldHeight) + ((state.locations.length - 1) * spacing),
            child: Stack(
              children: [
                Column(
                  children: [
                    for (int i = 0; i < state.locations.length; i++) ...[
                      GestureDetector(
                        onTap: () => _openLocationSelection(context, i),
                        child: Container(
                          height: fieldHeight,
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(color: AppColors.border),
                          ),
                          padding: const EdgeInsets.only(left: 56, right: 16),
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  state.getLocationDisplay(i),
                                  style: TextStyle(
                                      color: state.locations[i] != null
                                          ? AppColors.textSecondary
                                          : AppColors.placeholder,
                                      fontSize: 14
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (i > 0 && i < state.locations.length - 1)
                                IconButton(
                                  icon: const Icon(Icons.close, size: 18),
                                  onPressed: () => context.read<BookingCubit>().removeLocation(i),
                                ),
                            ],
                          ),
                        ),
                      ),
                      if (i < state.locations.length - 1) const SizedBox(height: spacing),
                    ],
                  ],
                ),
                ...List.generate(state.locations.length, (i) {
                  return Positioned(
                    left: 12,
                    top: i * (fieldHeight + spacing) + ((fieldHeight - outerIconSize) / 2),
                    child: _buildLocationIcon(i, state.locations[i] != null),
                  );
                }),
                ...List.generate(state.locations.length - 1, (i) {
                  return Positioned(
                    left: 12 + (outerIconSize / 2) - 1,
                    top: i * (fieldHeight + spacing) + ((fieldHeight - outerIconSize) / 2) + outerIconSize,
                    child: SizedBox(
                      width: 2,
                      height: fieldHeight + spacing - outerIconSize,
                      child: CustomPaint(
                        painter: _DashLinePainter(),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationIcon(int i, bool isSet) {
    final len = state.locations.length;
    Color color = isSet
        ? (i == 0 ? AppColors.success : i == len - 1 ? AppColors.primary : AppColors.waypoint)
        : AppColors.placeholder;

    if (i == 0 || (i > 0 && i < len - 1)) {
      return Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    } else {
      return Icon(
        Icons.location_on,
        color: color,
        size: 28,
      );
    }
  }

  Widget _buildDateTimeContent(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: const Color(0xFF080A24),
    ) ??
        const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF080A24),
        );

    const double activeLineHeight = 56;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Date and Time',
            style: titleStyle,
          ),
          const SizedBox(height: 32),
          const Text('Date of Departure'),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: state.departureDate ?? DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) {
                final currentDt = state.departureDate ?? DateTime.now();
                final newDt = DateTime(
                  date.year,
                  date.month,
                  date.day,
                  currentDt.hour,
                  currentDt.minute,
                );
                context.read<BookingCubit>().setDepartureDateTime(newDt);
              }
            },
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: AppColors.border),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Text(
                    state.departureDate?.toLocal().toString().split(' ')[0] ?? 'Select the date of departure',
                    style: TextStyle(
                      color: state.departureDate == null ? AppColors.placeholder : AppColors.black,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.airplanemode_active,
                    color: AppColors.placeholder,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Time of departure'),
          const SizedBox(height: 16),
          SizedBox(
            height: 150,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    height: activeLineHeight,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: AppColors.border),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _HourWheel(state: state),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(':', style: TextStyle(fontSize: 32)),
                    ),
                    _MinuteWheel(state: state),
                    const SizedBox(width: 20),
                    _PeriodWheel(state: state),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleContent(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: const Color(0xFF080A24),
    ) ??
        const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF080A24),
        );

    final vehicles = [
      {
        'name': 'Saloon',
        'capacity': '2-3 person',
        'price': 7.00,
        'image': 'assets/images/car1.png',
      },
      {
        'name': 'Estate',
        'capacity': '3-4 person',
        'price': 9.00,
        'image': 'assets/images/car2.png',
      },
      {
        'name': 'Executive',
        'capacity': '3-4 person',
        'price': 10.00,
        'image': 'assets/images/car3.png',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(20, 18, 20,0),
          child: Text(
            'Choose your ride',
            style: titleStyle,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: vehicles.length,
          itemBuilder: (context, index) {
            final vehicle = vehicles[index];
            final isSelected = state.selectedVehicle == vehicle['name'];
            return InkWell(
              onTap: () {
                print('Tapped vehicle: ${vehicle['name']}');
                context.read<BookingCubit>().selectVehicle(vehicle['name'] as String);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                // Apply full-width background color here
                color: isSelected ? AppColors.primary : null, // Full width background
                child: Padding(
                  padding: const EdgeInsets.only(top: 12, bottom:12, right: 16), // Move padding here
                  child: Row(
                    children: [
                      Image.asset(
                        vehicle['image'] as String,
                        width: 100,
                        height: 60,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              vehicle['name'] as String,
                              style: TextStyle(
                                color: isSelected ? AppColors.white : AppColors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              vehicle['capacity'] as String,
                              style: TextStyle(
                                color: isSelected ? AppColors.white.withOpacity(0.7) : AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '\$${ (vehicle['price'] as double).toStringAsFixed(2) }',
                        style: TextStyle(
                          color: isSelected ? AppColors.white : AppColors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (isSelected)
                        const Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Icon(
                            Icons.check_circle,
                            color: AppColors.white,
                            size: 24,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  double _getSelectedPrice() {
    switch (state.selectedVehicle) {
      case 'Saloon':
        return 7.00;
      case 'Estate':
        return 9.00;
      case 'Executive':
        return 10.00;
      default:
        return 0.00;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSelectRideStep = state.currentStep == BookingStep.selectRide;
    final canProceed = state.canProceed;
    final selectedPrice = _getSelectedPrice();
    final priceStr = selectedPrice.toStringAsFixed(2).replaceAll('.', ',');

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(50), topRight: Radius.circular(50)),
        color: AppColors.white,
        boxShadow: [
          BoxShadow(color: Color(0x0A000000), blurRadius: 20, offset: Offset(0, -8)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(0, 18, 0, 20),
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),
                if (state.currentStep == BookingStep.location) _buildLocationContent(context),
                if (state.currentStep == BookingStep.dateTime) _buildDateTimeContent(context),
                if (state.currentStep == BookingStep.selectRide) _buildVehicleContent(context),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.card,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            child: Row(
              children: [
                if (state.currentStep != BookingStep.location)
                  SizedBox(
                    width: 140,
                    child: GestureDetector(
                      onTap: () => context.read<BookingCubit>().goToPreviousStep(),
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
                            Text(
                              'Back',
                              style: TextStyle(
                                color: AppColors.black,
                                fontSize: 14,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (state.currentStep != BookingStep.location) const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: canProceed
                        ? () {
                      if (state.currentStep == BookingStep.selectRide) {
                        Navigator.pushNamed(context, AppRoutes.bookingSummary);
                      } else {
                        context.read<BookingCubit>().proceedToNextStep();
                      }
                    }
                        : null,
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        Container(
                          height: 45,
                          padding: const EdgeInsets.symmetric(horizontal: 44),
                          decoration: BoxDecoration(
                            color: canProceed ? AppColors.black : AppColors.placeholder,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                isSelectRideStep ? 'Checkout' : 'Next',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (isSelectRideStep) const SizedBox(width: 24),
                              if (isSelectRideStep)
                                Text(
                                  '\$$priceStr',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Positioned(
                          right: 4,
                          child: Container(
                            height: 35,
                            width: 35,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.black, width: 1),
                            ),
                            child: const Center(
                              child: Icon(Icons.chevron_right, size: 22, color: AppColors.black),
                            ),
                          ),
                        ),
                      ],
                    ),
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

class _HourWheel extends StatelessWidget {
  final BookingState state;

  const _HourWheel({required this.state, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentDt = state.departureDate ?? DateTime.now();
    int hour12 = currentDt.hour % 12;
    hour12 = hour12 == 0 ? 12 : hour12;
    final controller = FixedExtentScrollController(initialItem: hour12 - 1 + 12 * 100);

    return SizedBox(
      width: 60,
      child: ListWheelScrollView.useDelegate(
        controller: controller,
        itemExtent: 50,
        physics: const FixedExtentScrollPhysics(),
        diameterRatio: 1.5,
        squeeze: 0.9,
        onSelectedItemChanged: (int index) {
          int newHour = (index % 12) + 1;
          final isAM = currentDt.hour < 12;
          int militaryHour = newHour;
          if (newHour == 12) {
            militaryHour = isAM ? 0 : 12;
          } else if (!isAM) {
            militaryHour += 12;
          }
          final newDt = DateTime(
            currentDt.year,
            currentDt.month,
            currentDt.day,
            militaryHour,
            currentDt.minute,
          );
          context.read<BookingCubit>().setDepartureDateTime(newDt);
        },
        childDelegate: ListWheelChildLoopingListDelegate(
          children: List.generate(
            12,
                (index) => Center(
              child: Text(
                '${index + 1}'.padLeft(2, '0'),
                style: TextStyle(
                  fontSize: 24,
                  color: (index + 1 == hour12) ? AppColors.primary : AppColors.placeholder,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MinuteWheel extends StatelessWidget {
  final BookingState state;

  const _MinuteWheel({required this.state, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentDt = state.departureDate ?? DateTime.now();
    final minute = currentDt.minute;
    final controller = FixedExtentScrollController(initialItem: minute + 60 * 100);

    return SizedBox(
      width: 60,
      child: ListWheelScrollView.useDelegate(
        controller: controller,
        itemExtent: 50,
        physics: const FixedExtentScrollPhysics(),
        diameterRatio: 1.5,
        squeeze: 0.9,
        onSelectedItemChanged: (int index) {
          final newMinute = index % 60;
          final newDt = DateTime(
            currentDt.year,
            currentDt.month,
            currentDt.day,
            currentDt.hour,
            newMinute,
          );
          context.read<BookingCubit>().setDepartureDateTime(newDt);
        },
        childDelegate: ListWheelChildLoopingListDelegate(
          children: List.generate(
            60,
                (index) => Center(
              child: Text(
                index.toString().padLeft(2, '0'),
                style: TextStyle(
                  fontSize: 24,
                  color: index == minute ? AppColors.primary : AppColors.placeholder,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PeriodWheel extends StatelessWidget {
  final BookingState state;

  const _PeriodWheel({required this.state, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentDt = state.departureDate ?? DateTime.now();
    final isAM = currentDt.hour < 12;
    final controller = FixedExtentScrollController(initialItem: (isAM ? 0 : 1) + 2 * 100);

    return SizedBox(
      width: 60,
      child: ListWheelScrollView.useDelegate(
        controller: controller,
        itemExtent: 50,
        physics: const FixedExtentScrollPhysics(),
        diameterRatio: 1.5,
        squeeze: 0.9,
        onSelectedItemChanged: (int index) {
          final newIsAM = (index % 2) == 0;
          int newHour = currentDt.hour;
          if (newIsAM && newHour >= 12) {
            newHour -= 12;
          } else if (!newIsAM && newHour < 12) {
            newHour += 12;
          }
          final newDt = DateTime(
            currentDt.year,
            currentDt.month,
            currentDt.day,
            newHour,
            currentDt.minute,
          );
          context.read<BookingCubit>().setDepartureDateTime(newDt);
        },
        childDelegate: ListWheelChildLoopingListDelegate(
          children: ['AM', 'PM']
              .map((p) => Center(
            child: Text(
              p,
              style: TextStyle(
                fontSize: 24,
                color: (p == (isAM ? 'AM' : 'PM')) ? AppColors.primary : AppColors.placeholder,
              ),
            ),
          ))
              .toList(),
        ),
      ),
    );
  }
}
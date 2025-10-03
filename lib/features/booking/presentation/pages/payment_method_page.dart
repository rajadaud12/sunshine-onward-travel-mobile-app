import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sot/core/config/app_colors.dart';
import 'package:sot/features/booking/state/booking_cubit.dart';
import 'package:sot/features/booking/state/booking_state.dart';

class PaymentMethodPage extends StatelessWidget {
  const PaymentMethodPage({super.key});

  Map<String, dynamic> _getVehicleDetails(String? selectedVehicle) {
    final vehicles = [
      {'name': 'Saloon', 'price': 7.00},
      {'name': 'Estate', 'price': 9.00},
      {'name': 'Executive', 'price': 10.00},
    ];
    return vehicles.firstWhere((v) => v['name'] == selectedVehicle, orElse: () => vehicles[1]);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookingCubit, BookingState>(
      builder: (context, state) {
        final cubit = context.read<BookingCubit>();
        final vehicle = _getVehicleDetails(state.selectedVehicle);
        final price = vehicle['price'] as double;
        final priceStr = price.toStringAsFixed(2).replaceAll('.', ',');

        return Scaffold(
          body: Stack(
            children: [
              // Adjusted pink header with text slightly shifted right
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
                    mainAxisAlignment: MainAxisAlignment.center, // Keep general centering
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
                          child: const Icon(
                            Icons.close,
                            color: AppColors.black,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 50), // Shift text slightly right
                          child: Text(
                            'Payment Method',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppColors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ) ??
                                const TextStyle(
                                  fontFamily: 'Poppins',
                                  color: AppColors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                            textAlign: TextAlign.center, // Maintain centered appearance
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
                      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: const Text(
                              'Choose Payment Method',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black),
                            ),
                          ),
                          const SizedBox(height: 32),
                          GestureDetector(
                            onTap: () => cubit.selectPaymentMethod('credit_card'),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: AppColors.card,
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: const BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.credit_card, color: Colors.white),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Credit Card', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black)),
                                        Text('Visa or Master Card', style: TextStyle(color: Color(0xFF656565), fontSize: 12)),
                                        Row(
                                          children: [
                                            Icon(Icons.percent, size: 12, color: Color(0xFF656565)),
                                            SizedBox(width: 4),
                                            Text('Get \$1 discount', style: TextStyle(color: Color(0xFF656565), fontSize: 12)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                    child: Radio<String>(
                                      value: 'credit_card',
                                      groupValue: state.selectedPaymentMethod,
                                      onChanged: (value) => cubit.selectPaymentMethod(value!),
                                      activeColor: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => cubit.selectPaymentMethod('paypal'),
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.card,
                                border: Border.all(color: AppColors.border),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 20,vertical: 20),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Center(
                                      child: Text('P', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600)),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  const Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 20),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Paypal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black)),
                                          Text('Pay with your paypal balance', style: TextStyle(color: Color(0xFF656565), fontSize: 12)),
                                          Row(
                                            children: [
                                              Icon(Icons.percent, size: 12, color: Color(0xFF656565)),
                                              SizedBox(width: 4),
                                              Text('Get \$1 discount', style: TextStyle(color: Color(0xFF656565), fontSize: 12)),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Radio<String>(
                                    value: 'paypal',
                                    groupValue: state.selectedPaymentMethod,
                                    onChanged: (value) => cubit.selectPaymentMethod(value!),
                                    activeColor: AppColors.primary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Bottom bar
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    border: const Border(top: BorderSide(color: AppColors.border)),
                  ),
                  child: Row(
                    children: [
                      // SMALL Back button (fixed width)
                      SizedBox(
                        width: 140,
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
                      const SizedBox(width: 12),
                      // BIG Confirm button with overlapping circular icon
                      Expanded(
                        child: GestureDetector(
                          onTap: state.selectedPaymentMethod != null ? () {
                            // booking logic
                          } : null,
                          child: Opacity(
                            opacity: state.selectedPaymentMethod != null ? 1.0 : 0.5,
                            child: Stack(
                              clipBehavior: Clip.none,
                              alignment: Alignment.center,
                              children: [
                                // main black pill
                                Container(
                                  height: 45,
                                  padding: const EdgeInsets.symmetric(horizontal: 44), // leave room for the circular icon visually
                                  decoration: BoxDecoration(
                                    color: AppColors.black,
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'Confirm',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(width: 24),
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

                                // white circular icon overlapping on the right
                                Positioned(
                                  right: 4, // overlap a bit outside the pill for the same visual
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
}
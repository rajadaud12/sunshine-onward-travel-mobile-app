
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_paypal_payment/flutter_paypal_payment.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:sot/core/config/app_colors.dart';
import 'package:sot/features/booking/state/booking_cubit.dart';
import 'package:sot/features/booking/state/booking_state.dart';
import 'package:sot/core/utils/api_service.dart';
import 'dart:convert';

class PaymentMethodPage extends StatelessWidget {
  const PaymentMethodPage({super.key});

  @override
  Widget build(BuildContext context) {
    Stripe.publishableKey = 'pk_test_51SJcy0GgEtC7ssqDGbRxwfTlaagmRNV5IyEaV3op3PrpkStn1gv2m84DhOFgCUW6A9qCVI87ikd90SOtnnnMvEme006Em91jXZ'; // Replace with your key

    return BlocBuilder<BookingCubit, BookingState>(
      builder: (context, state) {
        final cubit = context.read<BookingCubit>();
        final price = state.vehiclePrices[state.selectedVehicle ?? ''] ?? 0.0;
        final priceStr = price.toStringAsFixed(2).replaceAll('.', ',');

        return Scaffold(
          body: Stack(
            children: [

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
                          padding: const EdgeInsets.only(right: 50),
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
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

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
                      SizedBox(
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
                      Expanded(
                        child: GestureDetector(
                          onTap: state.selectedPaymentMethod != null ? () async {
                            if (state.selectedPaymentMethod == 'paypal') {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (BuildContext ctx) => PaypalCheckoutView(
                                  sandboxMode: true,
                                  clientId: "AY_eUsuoTnX9GryYnkWk7HeexkOu6B5vsqt4qVaqKTOr5zHmA27wu-ox11SEwcPES3W6ENrYPAHG6aq5",
                                  secretKey: "EIzCBRA3Axnxz38QgczDLgwf9evQTK8zIqomS5LI2dsYZJXwnEt41jru2wGeuBgI28Hwkr4sG8Ifv8g2",
                                  transactions: [
                                    {
                                      "amount": {
                                        "total": price.toStringAsFixed(2),
                                        "currency": "USD",
                                        "details": {
                                          "subtotal": price.toStringAsFixed(2),
                                          "shipping": '0',
                                          "shipping_discount": 0
                                        }
                                      },
                                      "description": "Payment for ${state.selectedVehicle} ride from ${state.locations.first?.address} to ${state.locations.last?.address}.",
                                      "item_list": {
                                        "items": [
                                          {
                                            "name": "${state.selectedVehicle} Ride",
                                            "quantity": 1,
                                            "price": price.toStringAsFixed(2),
                                            "currency": "USD"
                                          }
                                        ]
                                      }
                                    }
                                  ],
                                  note: "Contact us for any questions on your order.",
                                  onSuccess: (Map params) async {
                                    print("PayPal Success: $params");
                                    await cubit.createBooking();
                                    Navigator.pop(ctx);
                                    Navigator.pop(context);
                                  },
                                  onError: (error) {
                                    print("PayPal Error: $error");
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Payment error: $error")));
                                    Navigator.pop(context);
                                  },
                                  onCancel: () {
                                    print('PayPal Cancelled');

                                  },
                                ),
                              ));
                            } else if (state.selectedPaymentMethod == 'credit_card') {
                              try {
                                final response = await ApiService.post(
                                  '/payment/create-payment-intent',
                                  {
                                    'amount': (price * 100).toInt(),
                                    'currency': 'usd',
                                  },
                                );
                                if (response.statusCode == 200) {
                                  final clientSecret = json.decode(response.body)['clientSecret'];

                                  await Stripe.instance.initPaymentSheet(
                                    paymentSheetParameters: SetupPaymentSheetParameters(
                                      paymentIntentClientSecret: clientSecret,
                                      merchantDisplayName: 'Your Ride App',
                                      style: ThemeMode.light,
                                    ),
                                  );
                                  await Stripe.instance.presentPaymentSheet();

                                  print("Stripe Success");
                                  await cubit.createBooking();
                                  Navigator.pop(context);
                                } else {
                                  throw Exception('Failed to create payment intent: ${response.statusCode}');
                                }
                              } catch (e) {
                                print("Stripe Error: $e");
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Payment error: $e")));
                              }
                            }
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
                                  padding: const EdgeInsets.symmetric(horizontal: 44),
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
                                          fontSize: 12,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        '\$${double.parse(priceStr.replaceAll(',', '.')).toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
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
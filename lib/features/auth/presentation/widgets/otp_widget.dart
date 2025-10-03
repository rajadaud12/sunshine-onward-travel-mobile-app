import 'package:flutter/material.dart';
import 'package:sot/core/config/app_colors.dart';

class OtpWidget extends StatelessWidget {
  final int length;
  final Function(String) onComplete;
  final List<TextEditingController>? controllers; // Optional prop for external clearing

  const OtpWidget({
    super.key,
    this.length = 4,
    required this.onComplete,
    this.controllers,
  });

  @override
  Widget build(BuildContext context) {
    final List<TextEditingController> internalControllers = controllers ?? List.generate(length, (_) => TextEditingController());
    List<FocusNode> focusNodes = List.generate(length, (_) => FocusNode());

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(length, (index) {
        return SizedBox(
          width: 76,
          height: 70,
          child: TextField(
            controller: internalControllers[index],
            focusNode: focusNodes[index],
            autofocus: index == 0,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(30),
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
            onChanged: (value) {
              if (value.length == 1 && index < length - 1) {
                FocusScope.of(context).requestFocus(focusNodes[index + 1]);
              } else if (value.isEmpty && index > 0) {
                FocusScope.of(context).requestFocus(focusNodes[index - 1]);
              }
              String otp = internalControllers.map((c) => c.text).join();
              if (otp.length == length) {
                onComplete(otp);
              }
            },
          ),
        );
      }),
    );
  }
}
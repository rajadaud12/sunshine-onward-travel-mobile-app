import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sot/core/config/app_colors.dart';

class TextFieldButton extends StatelessWidget {
  final String label;
  final String hintText;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final String? value;

  const TextFieldButton({
    super.key,
    required this.label,
    required this.hintText,
    this.suffixIcon,
    this.onTap,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    // Design: height 45, rounded capsule, border, subtle background
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
            fontSize: 14,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 45, // fixed as requested
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                // subtle elevation to match Figma
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value ?? hintText,
                    style: TextStyle(
                      color: value == null ? AppColors.placeholder : AppColors.black,
                      fontSize: 14,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
                if (suffixIcon != null) suffixIcon!,
              ],
            ),
          ),
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:sot/core/config/app_colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;
  final double height;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color = AppColors.primary,
    this.height = 64.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32.0),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: color == AppColors.primary ? AppColors.white : AppColors.white,
            fontSize: height == 64.0 ? 16.0 : 14.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
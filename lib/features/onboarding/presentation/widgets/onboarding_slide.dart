import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sot/core/config/app_colors.dart';

/// Single slide widget:
/// - Title/description keep horizontal padding
/// - SVG uses full device width (no horizontal gutters)
/// - SVG height is constrained to fraction of remaining space to avoid clipping
class OnboardingSlide extends StatelessWidget {
  final String assetName;
  final String title;
  final String description;

  // Tunables: adjust these to fine-tune appearance
  static const double titleHorizontalPadding = 21.0;
  static const double topSpacing = 48.0;
  static const double interTitleSpacing = 10.0;
  static const double svgScale = 1.06;
  static const double svgHeightRatio = 1;

  const OnboardingSlide({
    super.key,
    required this.assetName,
    required this.title,
    required this.description,
  });

  TextSpan _titleTextSpan(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final black = AppColors.black;

    final base = Theme.of(context).textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.w600,
    ) ??
        const TextStyle(fontSize: 28, fontWeight: FontWeight.w600);

    final parts = title.trim().split(' ');
    if (parts.length == 1) return TextSpan(text: title, style: base.copyWith(color: black));
    final last = parts.removeLast();
    final first = parts.join(' ') + ' ';
    return TextSpan(children: [
      TextSpan(text: first, style: base.copyWith(color: black)),
      TextSpan(text: last, style: base.copyWith(color: primary)),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final textSecondary = AppColors.textSecondary;
    final screenWidth = MediaQuery.of(context).size.width;
    final svgWidth = screenWidth * svgScale;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Title block uses intrinsic height; remaining space is used for the SVG.
        // We'll cap the SVG height to a ratio of the remaining space so it won't be clipped.
        final remainingHeight = constraints.maxHeight;
        final svgHeight = (remainingHeight * svgHeightRatio).clamp(120.0, remainingHeight);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title + description (left/right padding)
            Padding(
              padding:  EdgeInsets.symmetric(horizontal: titleHorizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: topSpacing),
                  RichText(text: _titleTextSpan(context)),
                  const SizedBox(height: interTitleSpacing),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: textSecondary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            // Expanded area for centered SVG. Because it's in Expanded, the "remaining"
            // height is correctly provided by the PageView/Column layout; we then
            // size the SVG to a safe height to prevent top clipping.
            Expanded(
              child: Center(
                child: SizedBox(
                  width: svgWidth,
                  height: svgHeight,
                  child: SvgPicture.asset(
                    assetName,
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                    // If an SVG has internal whitespace, you can adjust with Transform.translate
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

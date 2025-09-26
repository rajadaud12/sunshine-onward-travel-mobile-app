import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sot/core/config/app_colors.dart';
import 'package:sot/core/routes/app_routes.dart';
import 'package:sot/features/onboarding/state/onboarding_cubit.dart';
import 'package:sot/features/onboarding/state/onboarding_state.dart';
import '../widgets/onboarding_slide.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late final PageController _pageController;

  final slides = const [
    OnboardingSlide(
      assetName: "assets/images/onboarding1.svg",
      title: "Hassle-Free Airport Rides",
      description: "Smooth, reliable rides to and from the airport—no stress, no delays.",
    ),
    OnboardingSlide(
      assetName: "assets/images/onboarding2.svg",
      title: "Choose Your Pickup and Destination",
      description: "Set your pickup and drop-off in just a few taps.",
    ),
    OnboardingSlide(
      assetName: "assets/images/onboarding3.svg",
      title: "Find the Perfect Car for Your Trip",
      description: "Pick the ride that fits your style and comfort.",
    ),
    OnboardingSlide(
      assetName: "assets/images/onboarding4.svg",
      title: "Your Driver Arrives Right on Time",
      description: "Expect a punctual, ready-to-go driver every time.",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _leftIndicatorColumn(OnboardingState state) {
    final black = AppColors.black;
    final placeholder = AppColors.placeholder;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(slides.length, (index) {
            final active = state.currentPage == index;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: active ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: active ? black : placeholder,
                borderRadius: BorderRadius.circular(20),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.welcome);
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Skip',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.left,
          ),
        ),
      ],
    );
  }

  Widget _nextButtonWithProgress(OnboardingState state) {
    final placeholder = AppColors.placeholder;
    final primary = Theme.of(context).colorScheme.primary;
    final black = AppColors.black;

    final progress = (slides.length > 1)
        ? (state.currentPage / (slides.length - 1))
        : 1.0;

    const outerSize = 58.0;
    const innerSize = 42.0;

    return GestureDetector(
      onTap: () {
        if (state.currentPage < slides.length - 1) {
          _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
        } else {
          Navigator.pushNamed(context, AppRoutes.welcome);
        }
      },
      child: SizedBox(
        width: outerSize,
        height: outerSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: progress),
              duration: const Duration(milliseconds: 350),
              builder: (context, animatedValue, child) {
                return SizedBox(
                  width: outerSize,
                  height: outerSize,
                  child: CircularProgressIndicator(
                    value: animatedValue,
                    strokeWidth: 3,
                    backgroundColor: placeholder.withOpacity(0.6),
                    valueColor: AlwaysStoppedAnimation<Color>(black),
                  ),
                );
              },
            ),
            Container(
              width: innerSize,
              height: innerSize,
              decoration: BoxDecoration(
                color: black,
                shape: BoxShape.circle,
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: primary),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Force page background to white (explicit).
    return BlocProvider(
      create: (_) => OnboardingCubit(),
      child: BlocBuilder<OnboardingCubit, OnboardingState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.white,
            body: SafeArea(
              child: Column(
                children: [
                  // PageView (takes all space above bottom controls)
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: slides.length,
                      onPageChanged: (index) => context.read<OnboardingCubit>().updatePage(index),
                      itemBuilder: (context, index) => slides[index],
                    ),
                  ),

                  // Bottom controls (dots + skip / next)
                  Container(
                    margin: const EdgeInsets.fromLTRB(0, 12, 0, 20),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _leftIndicatorColumn(state),
                        _nextButtonWithProgress(state),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
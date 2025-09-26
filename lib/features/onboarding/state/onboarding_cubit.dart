import 'package:flutter_bloc/flutter_bloc.dart';
import 'onboarding_state.dart';

/// Controls onboarding page index
class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit() : super(const OnboardingState());

  void updatePage(int index) {
    emit(state.copyWith(currentPage: index));
  }

  void nextPage() {
    emit(state.copyWith(currentPage: state.currentPage + 1));
  }
}

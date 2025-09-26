// booking_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sot/features/booking/state/booking_state.dart';

class BookingCubit extends Cubit<BookingState> {
  BookingCubit() : super(const BookingState());

  void setStep(BookingStep step) {
    if (step == BookingStep.location && state.locations.isEmpty) {
      emit(state.copyWith(locations: [null, null], currentStep: step));
    } else {
      emit(state.copyWith(currentStep: step));
    }
  }

  void setLocation(int index, BookingLocation loc) {
    if (index < 0 || index >= state.locations.length) return;
    final newLocations = List<BookingLocation?>.from(state.locations);
    newLocations[index] = loc;
    emit(state.copyWith(locations: newLocations));
  }

  void addWaypoint(BookingLocation loc) {
    if (state.locations.length < 2) return;
    final newLocations = List<BookingLocation?>.from(state.locations);
    newLocations.insert(newLocations.length - 1, loc);
    emit(state.copyWith(locations: newLocations));
  }

  void removeLocation(int index) {
    if (index <= 0 || index >= state.locations.length - 1) return;
    final newLocations = List<BookingLocation?>.from(state.locations);
    newLocations.removeAt(index);
    emit(state.copyWith(locations: newLocations));
  }

  void setDepartureDateTime(DateTime dt) {
    emit(state.copyWith(departureDate: dt));
  }

  void selectVehicle(String vehicle) {
    print('Selecting vehicle: $vehicle');
    emit(state.copyWith(selectedVehicle: vehicle));
  }

  void proceedToNextStep() {
    switch (state.currentStep) {
      case BookingStep.location:
        if (state.canProceed) {
          setStep(BookingStep.dateTime);
        }
        break;
      case BookingStep.dateTime:
        if (state.canProceed) {
          setStep(BookingStep.selectRide);
        }
        break;
      case BookingStep.selectRide:
        if (state.canProceed) {
          setStep(BookingStep.payment);
        }
        break;
      case BookingStep.payment:
        setStep(BookingStep.confirmation);
        break;
      case BookingStep.confirmation:
      // Handle booking completion
        break;
      default:
        setStep(BookingStep.location);
    }
  }

  void goToPreviousStep() {
    switch (state.currentStep) {
      case BookingStep.dateTime:
        setStep(BookingStep.location);
        break;
      case BookingStep.selectRide:
        setStep(BookingStep.dateTime);
        break;
      case BookingStep.payment:
        setStep(BookingStep.selectRide);
        break;
      case BookingStep.confirmation:
        setStep(BookingStep.payment);
        break;
      default:
      // Already at first step
        break;
    }
  }

  void reset() {
    emit(const BookingState());
  }

  void selectPaymentMethod(String method) {
    emit(state.copyWith(selectedPaymentMethod: method));
  }
}
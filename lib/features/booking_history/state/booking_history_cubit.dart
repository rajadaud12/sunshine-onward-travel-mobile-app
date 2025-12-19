import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sot/core/utils/api_service.dart';
import 'package:sot/features/booking_history/state/booking_history_state.dart';

class BookingHistoryCubit extends Cubit<BookingHistoryState> {
  BookingHistoryCubit() : super(const BookingHistoryState()) {
    loadBookings();
  }

  Future<void> loadBookings() async {
    if (state.isLoading) return;
    emit(state.copyWith(isLoading: true, error: null));

    try {
      // Call the backend route that fetches user-specific bookings
      final response = await ApiService.get('/bookings');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final List<Booking> allBookings = data.map((item) => Booking.fromJson(item)).toList();

        // Sort by date (newest first)
        allBookings.sort((a, b) => b.departureTime.compareTo(a.departureTime));

        // Separate Active (Pending/Accepted) vs History (Completed/Cancelled)
        final active = allBookings.where((b) =>
        b.status.toLowerCase() == 'pending' ||
            b.status.toLowerCase() == 'accepted' ||
            b.status.toLowerCase() == 'driver_assigned'
        ).toList();

        final history = allBookings.where((b) =>
        b.status.toLowerCase() == 'completed' ||
            b.status.toLowerCase() == 'cancelled'
        ).toList();

        emit(state.copyWith(
          activeBookings: active,
          fullHistoryBookings: history,
          historyBookings: history, // Will be re-filtered immediately below
          isLoading: false,
        ));

        // Re-apply current filter
        changeFilter(state.historyFilter);
      } else {
        emit(state.copyWith(
            isLoading: false,
            error: 'Server Error: ${response.statusCode}'
        ));
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: 'Connection Error: $e'));
    }
  }

  void changeFilter(String filter) {
    var filtered = _filterHistory(filter, state.fullHistoryBookings);
    // Ensure sorted
    filtered.sort((a, b) => b.departureTime.compareTo(a.departureTime));
    emit(state.copyWith(historyFilter: filter, historyBookings: filtered));
  }

  List<Booking> _filterHistory(String filter, List<Booking> history) {
    final now = DateTime.now();
    int year = now.year;
    int month = now.month;
    switch (filter) {
      case 'This Month':
        return history.where((b) => b.departureTime.year == year && b.departureTime.month == month).toList();
      case 'Last Month':
        month = month - 1;
        if (month == 0) {
          month = 12;
          year--;
        }
        return history.where((b) => b.departureTime.year == year && b.departureTime.month == month).toList();
      case 'This Year':
        return history.where((b) => b.departureTime.year == now.year).toList();
      default:
        return history;
    }
  }
}
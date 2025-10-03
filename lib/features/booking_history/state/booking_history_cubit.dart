import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sot/features/booking_history/state/booking_history_state.dart';

class BookingHistoryCubit extends Cubit<BookingHistoryState> {
  BookingHistoryCubit() : super(const BookingHistoryState()) {
    loadBookings();
  }

  void loadBookings() {
    final now = DateTime.now();
    final todayMidnight = DateTime(now.year, now.month, now.day);
    final active = [
      Booking(
        pickup: 'State Park',
        destination: 'Heathrow Airport',
        departureTime: todayMidnight.add(const Duration(hours: 0)),
        arrivalTime: todayMidnight.add(const Duration(hours: 0)).add(const Duration(hours: 7, minutes: 48)),
        isCompleted: false,
      ),
    ];
    var history = [
      Booking(
        pickup: 'State Park',
        destination: 'Heathrow Airport',
        departureTime: todayMidnight.subtract(const Duration(days: 1)).add(const Duration(hours: 0)),
        arrivalTime: todayMidnight.subtract(const Duration(days: 1)).add(const Duration(hours: 0)).add(const Duration(hours: 7, minutes: 48)),
        isCompleted: true,
      ),
      Booking(
        pickup: 'State Park',
        destination: 'Heathrow Airport',
        departureTime: todayMidnight.subtract(const Duration(days: 2)).add(const Duration(hours: 0)),
        arrivalTime: todayMidnight.subtract(const Duration(days: 2)).add(const Duration(hours: 0)).add(const Duration(hours: 7, minutes: 48)),
        isCompleted: true,
      ),
    ];
    // Sort history by departure time descending
    history.sort((a, b) => b.departureTime.compareTo(a.departureTime));
    print("✅ Active bookings loaded: ${active.length}");
    emit(state.copyWith(activeBookings: active, fullHistoryBookings: history, historyBookings: history));
    changeFilter(state.historyFilter);
  }

  void changeFilter(String filter) {
    var filtered = _filterHistory(filter, state.fullHistoryBookings);
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
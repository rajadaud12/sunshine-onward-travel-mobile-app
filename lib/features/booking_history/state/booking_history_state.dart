import 'package:equatable/equatable.dart';

class Booking extends Equatable {
  final String pickup;
  final String destination;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final bool isCompleted;

  const Booking({
    required this.pickup,
    required this.destination,
    required this.departureTime,
    required this.arrivalTime,
    this.isCompleted = false,
  });

  @override
  List<Object> get props => [pickup, destination, departureTime, arrivalTime, isCompleted];
}

class BookingHistoryState extends Equatable {
  final List<Booking> activeBookings;
  final List<Booking> fullHistoryBookings;
  final List<Booking> historyBookings;
  final String historyFilter;

  const BookingHistoryState({
    this.activeBookings = const [],
    this.fullHistoryBookings = const [],
    this.historyBookings = const [],
    this.historyFilter = 'This Month',
  });

  @override
  List<Object> get props => [activeBookings, fullHistoryBookings, historyBookings, historyFilter];

  BookingHistoryState copyWith({
    List<Booking>? activeBookings,
    List<Booking>? fullHistoryBookings,
    List<Booking>? historyBookings,
    String? historyFilter,
  }) {
    return BookingHistoryState(
      activeBookings: activeBookings ?? this.activeBookings,
      fullHistoryBookings: fullHistoryBookings ?? this.fullHistoryBookings,
      historyBookings: historyBookings ?? this.historyBookings,
      historyFilter: historyFilter ?? this.historyFilter,
    );
  }
}
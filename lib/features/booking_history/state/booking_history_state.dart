import 'package:equatable/equatable.dart';

class Booking extends Equatable {
  final String id;
  final String pickup;
  final String destination;
  final DateTime departureTime;
  final String carCategory;
  final double cost;
  final String status;

  const Booking({
    required this.id,
    required this.pickup,
    required this.destination,
    required this.departureTime,
    required this.carCategory,
    required this.cost,
    required this.status,
  });

  // Maps backend Firestore data to Dart object
  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] ?? '',
      // Backend field: "pickupLocation"
      pickup: json['pickupLocation'] ?? 'Unknown Pickup',
      // Backend field: "destination"
      destination: json['destination'] ?? 'Unknown Destination',
      // Backend field: "departureDate" (ISO String)
      departureTime: json['departureDate'] != null
          ? DateTime.tryParse(json['departureDate']) ?? DateTime.now()
          : DateTime.now(),
      // Backend field: "carCategory"
      carCategory: json['carCategory'] ?? 'Standard',
      // Backend field: "cost"
      cost: (json['cost'] as num?)?.toDouble() ?? 0.0,
      // Backend field: "status"
      status: json['status'] ?? 'pending',
    );
  }

  bool get isCompleted => status == 'completed';

  @override
  List<Object> get props => [id, pickup, destination, departureTime, carCategory, cost, status];
}

class BookingHistoryState extends Equatable {
  final List<Booking> activeBookings;
  final List<Booking> fullHistoryBookings;
  final List<Booking> historyBookings;
  final String historyFilter;
  final bool isLoading;
  final String? error;

  const BookingHistoryState({
    this.activeBookings = const [],
    this.fullHistoryBookings = const [],
    this.historyBookings = const [],
    this.historyFilter = 'This Month',
    this.isLoading = false,
    this.error,
  });

  @override
  List<Object?> get props => [
    activeBookings,
    fullHistoryBookings,
    historyBookings,
    historyFilter,
    isLoading,
    error
  ];

  BookingHistoryState copyWith({
    List<Booking>? activeBookings,
    List<Booking>? fullHistoryBookings,
    List<Booking>? historyBookings,
    String? historyFilter,
    bool? isLoading,
    String? error,
  }) {
    return BookingHistoryState(
      activeBookings: activeBookings ?? this.activeBookings,
      fullHistoryBookings: fullHistoryBookings ?? this.fullHistoryBookings,
      historyBookings: historyBookings ?? this.historyBookings,
      historyFilter: historyFilter ?? this.historyFilter,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
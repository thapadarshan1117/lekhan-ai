class CleanerBooking {
  final String id;
  final String customerName;
  final String customerPhone;
  final String serviceName;
  final List<String> addOns;
  final String timeSlot;
  final String duration;
  final String address;
  final String status;
  final int price;
  final DateTime bookingDate;
  final DateTime serviceDate;
  final String paymentStatus;
  final String specialInstructions;

  CleanerBooking({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.serviceName,
    required this.addOns,
    required this.timeSlot,
    required this.duration,
    required this.address,
    required this.status,
    required this.price,
    required this.bookingDate,
    required this.serviceDate,
    required this.paymentStatus,
    required this.specialInstructions,
  });

  factory CleanerBooking.fromJson(Map<String, dynamic> json) {
    return CleanerBooking(
      id: json['id'] ?? '',
      customerName: json['customer_name'] ?? '',
      customerPhone: json['customer_phone'] ?? '',
      serviceName: json['service_name'] ?? '',
      addOns: List<String>.from(json['add_ons'] ?? []),
      timeSlot: json['time_slot'] ?? '',
      duration: json['duration'] ?? '',
      address: json['address'] ?? '',
      status: json['status'] ?? '',
      price: json['price'] ?? 0,
      bookingDate: DateTime.parse(json['booking_date'] ?? DateTime.now().toIso8601String()),
      serviceDate: DateTime.parse(json['service_date'] ?? DateTime.now().toIso8601String()),
      paymentStatus: json['payment_status'] ?? '',
      specialInstructions: json['special_instructions'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'service_name': serviceName,
      'add_ons': addOns,
      'time_slot': timeSlot,
      'duration': duration,
      'address': address,
      'status': status,
      'price': price,
      'booking_date': bookingDate.toIso8601String(),
      'service_date': serviceDate.toIso8601String(),
      'payment_status': paymentStatus,
      'special_instructions': specialInstructions,
    };
  }

  CleanerBooking copyWith({
    String? id,
    String? customerName,
    String? customerPhone,
    String? serviceName,
    List<String>? addOns,
    String? timeSlot,
    String? duration,
    String? address,
    String? status,
    int? price,
    DateTime? bookingDate,
    DateTime? serviceDate,
    String? paymentStatus,
    String? specialInstructions,
  }) {
    return CleanerBooking(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      serviceName: serviceName ?? this.serviceName,
      addOns: addOns ?? this.addOns,
      timeSlot: timeSlot ?? this.timeSlot,
      duration: duration ?? this.duration,
      address: address ?? this.address,
      status: status ?? this.status,
      price: price ?? this.price,
      bookingDate: bookingDate ?? this.bookingDate,
      serviceDate: serviceDate ?? this.serviceDate,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      specialInstructions: specialInstructions ?? this.specialInstructions,
    );
  }

  @override
  String toString() {
    return 'CleanerBooking(id: $id, customerName: $customerName, serviceName: $serviceName, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CleanerBooking && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
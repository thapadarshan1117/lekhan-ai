import 'dart:ui';

enum BookingStatus {
  booked,
  enRoute,
  inProgress,
  completed,
  cancelled,
  disputed,
  scheduled,
}

enum ServiceType {
  standardCleaning,
  deepCleaning,
  postConstruction,
  carCleaning,
  officeCleaning,
}

enum PaymentStatus {
  pending,
  paid,
  refunded,
  disputed,
}

class Booking {
  final String id;
  final String customerId;
  final String cleanerId;
  final CleanerProfile cleaner;
  final ServiceType serviceType;
  final String serviceDuration;
  final DateTime scheduledDateTime;
  final String addressId;
  final SavedAddress address;
  final BookingStatus status;
  final double estimatedAmount;
  final double? finalAmount;
  final PaymentStatus paymentStatus;
  final String? specialInstructions;
  final DateTime createdAt;
  final DateTime? completedAt;
  final BookingReview? review;
  final List<String> progressTimeline;
  final String? invoiceUrl;
  final String? trackingId;

  const Booking({
    required this.id,
    required this.customerId,
    required this.cleanerId,
    required this.cleaner,
    required this.serviceType,
    required this.serviceDuration,
    required this.scheduledDateTime,
    required this.addressId,
    required this.address,
    required this.status,
    required this.estimatedAmount,
    this.finalAmount,
    required this.paymentStatus,
    this.specialInstructions,
    required this.createdAt,
    this.completedAt,
    this.review,
    required this.progressTimeline,
    this.invoiceUrl,
    this.trackingId,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] ?? '',
      customerId: json['customer_id'] ?? '',
      cleanerId: json['cleaner_id'] ?? '',
      cleaner: CleanerProfile.fromJson(json['cleaner'] ?? {}),
      serviceType: ServiceType.values.firstWhere(
        (e) => e.name == json['service_type'],
        orElse: () => ServiceType.standardCleaning,
      ),
      serviceDuration: json['service_duration'] ?? '',
      scheduledDateTime: DateTime.parse(json['scheduled_date_time'] ?? DateTime.now().toIso8601String()),
      addressId: json['address_id'] ?? '',
      address: SavedAddress.fromJson(json['address'] ?? {}),
      status: BookingStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => BookingStatus.booked,
      ),
      estimatedAmount: (json['estimated_amount'] ?? 0.0).toDouble(),
      finalAmount: json['final_amount']?.toDouble(),
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.name == json['payment_status'],
        orElse: () => PaymentStatus.pending,
      ),
      specialInstructions: json['special_instructions'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null,
      review: json['review'] != null ? BookingReview.fromJson(json['review']) : null,
      progressTimeline: List<String>.from(json['progress_timeline'] ?? []),
      invoiceUrl: json['invoice_url'],
      trackingId: json['tracking_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'cleaner_id': cleanerId,
      'cleaner': cleaner.toJson(),
      'service_type': serviceType.name,
      'service_duration': serviceDuration,
      'scheduled_date_time': scheduledDateTime.toIso8601String(),
      'address_id': addressId,
      'address': address.toJson(),
      'status': status.name,
      'estimated_amount': estimatedAmount,
      'final_amount': finalAmount,
      'payment_status': paymentStatus.name,
      'special_instructions': specialInstructions,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'review': review?.toJson(),
      'progress_timeline': progressTimeline,
      'invoice_url': invoiceUrl,
      'tracking_id': trackingId,
    };
  }

  String get serviceTypeDisplayName {
    switch (serviceType) {
      case ServiceType.standardCleaning:
        return 'Standard Cleaning';
      case ServiceType.deepCleaning:
        return 'Deep Cleaning';
      case ServiceType.postConstruction:
        return 'Post-Construction Cleaning';
      case ServiceType.carCleaning:
        return 'Car Cleaning';
      case ServiceType.officeCleaning:
        return 'Office Cleaning';
    }
  }

  String get statusDisplayName {
    switch (status) {
      case BookingStatus.booked:
        return 'Booked';
      case BookingStatus.enRoute:
        return 'En Route';
      case BookingStatus.inProgress:
        return 'In Progress';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
      case BookingStatus.disputed:
        return 'Disputed';
      case BookingStatus.scheduled:
        return 'Scheduled';
    }
  }

  Color get statusColor {
    switch (status) {
      case BookingStatus.booked:
        return const Color(0xFFFBBF24); // Yellow
      case BookingStatus.enRoute:
        return const Color(0xFF10B981); // Green
      case BookingStatus.inProgress:
        return const Color(0xFF3B82F6); // Blue
      case BookingStatus.completed:
        return const Color(0xFF8B5CF6); // Purple
      case BookingStatus.cancelled:
        return const Color(0xFFEF4444); // Red
      case BookingStatus.disputed:
        return const Color(0xFFEF4444); // Red
      case BookingStatus.scheduled:
        return const Color(0xFF6366F1); // Indigo
    }
  }

  bool get canCancel => status == BookingStatus.booked || status == BookingStatus.scheduled;
  bool get canTrack => status == BookingStatus.enRoute || status == BookingStatus.inProgress;
  bool get canApprove => status == BookingStatus.completed && review == null;
  bool get canRebook => status == BookingStatus.completed || status == BookingStatus.cancelled;
  bool get canReschedule => status == BookingStatus.scheduled;
  bool get canDispute => status == BookingStatus.completed;
}

class BookingReview {
  final String id;
  final String bookingId;
  final int rating;
  final String? comment;
  final List<String> photos;
  final DateTime createdAt;

  const BookingReview({
    required this.id,
    required this.bookingId,
    required this.rating,
    this.comment,
    required this.photos,
    required this.createdAt,
  });

  factory BookingReview.fromJson(Map<String, dynamic> json) {
    return BookingReview(
      id: json['id'] ?? '',
      bookingId: json['booking_id'] ?? '',
      rating: json['rating'] ?? 0,
      comment: json['comment'],
      photos: List<String>.from(json['photos'] ?? []),
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_id': bookingId,
      'rating': rating,
      'comment': comment,
      'photos': photos,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

// Import these from existing models
class CleanerProfile {
  final String id;
  final String name;
  final String? profilePicture;
  final double rating;
  final int reviewCount;
  final String? phoneNumber;

  const CleanerProfile({
    required this.id,
    required this.name,
    this.profilePicture,
    required this.rating,
    required this.reviewCount,
    this.phoneNumber,
  });

  factory CleanerProfile.fromJson(Map<String, dynamic> json) {
    return CleanerProfile(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      profilePicture: json['profile_picture'],
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewCount: json['review_count'] ?? 0,
      phoneNumber: json['phone_number'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'profile_picture': profilePicture,
      'rating': rating,
      'review_count': reviewCount,
      'phone_number': phoneNumber,
    };
  }
}

// Import this from existing models
class SavedAddress {
  final String id;
  final String name;
  final String fullAddress;
  final double latitude;
  final double longitude;
  final String? apartment;
  final String? landmark;
  final bool isDefault;
  final DateTime createdAt;

  const SavedAddress({
    required this.id,
    required this.name,
    required this.fullAddress,
    required this.latitude,
    required this.longitude,
    this.apartment,
    this.landmark,
    this.isDefault = false,
    required this.createdAt,
  });

  factory SavedAddress.fromJson(Map<String, dynamic> json) {
    return SavedAddress(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      fullAddress: json['full_address'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      apartment: json['apartment'],
      landmark: json['landmark'],
      isDefault: json['is_default'] ?? false,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'full_address': fullAddress,
      'latitude': latitude,
      'longitude': longitude,
      'apartment': apartment,
      'landmark': landmark,
      'is_default': isDefault,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
class CustomerReview {
  final String id;
  final String customerName;
  final String? customerAvatar;
  final String reviewText;
  final double rating;
  final String location;
  final DateTime createdAt;
  final String? serviceType;
  final bool isVerified;
  final bool isFeatured;

  const CustomerReview({
    required this.id,
    required this.customerName,
    this.customerAvatar,
    required this.reviewText,
    required this.rating,
    required this.location,
    required this.createdAt,
    this.serviceType,
    this.isVerified = false,
    this.isFeatured = false,
  });

  factory CustomerReview.fromJson(Map<String, dynamic> json) {
    return CustomerReview(
      id: json['id'] ?? '',
      customerName: json['customer_name'] ?? '',
      customerAvatar: json['customer_avatar'],
      reviewText: json['review_text'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      location: json['location'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      serviceType: json['service_type'],
      isVerified: json['is_verified'] ?? false,
      isFeatured: json['is_featured'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_name': customerName,
      'customer_avatar': customerAvatar,
      'review_text': reviewText,
      'rating': rating,
      'location': location,
      'created_at': createdAt.toIso8601String(),
      'service_type': serviceType,
      'is_verified': isVerified,
      'is_featured': isFeatured,
    };
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inMinutes}m ago';
    }
  }
}
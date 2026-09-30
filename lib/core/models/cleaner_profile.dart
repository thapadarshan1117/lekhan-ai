class CleanerProfile {
  final String id;
  final String name;
  final String? profileImageUrl;
  final double rating;
  final int reviewCount;
  final double distance; // in kilometers
  final int hourlyRate; // in local currency
  final List<String> services;
  final bool isVerified;
  final bool isAvailable;
  final bool isTopRated;
  final String? bio;
  final int experienceYears;
  final List<String> certifications;
  final String? phoneNumber;
  final Map<String, dynamic>? location;

  const CleanerProfile({
    required this.id,
    required this.name,
    this.profileImageUrl,
    required this.rating,
    required this.reviewCount,
    required this.distance,
    required this.hourlyRate,
    required this.services,
    this.isVerified = false,
    this.isAvailable = true,
    this.isTopRated = false,
    this.bio,
    this.experienceYears = 0,
    this.certifications = const [],
    this.phoneNumber,
    this.location,
  });

  factory CleanerProfile.fromJson(Map<String, dynamic> json) {
    return CleanerProfile(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      profileImageUrl: json['profile_image_url'],
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewCount: json['review_count'] ?? 0,
      distance: (json['distance'] ?? 0.0).toDouble(),
      hourlyRate: json['hourly_rate'] ?? 0,
      services: List<String>.from(json['services'] ?? []),
      isVerified: json['is_verified'] ?? false,
      isAvailable: json['is_available'] ?? true,
      isTopRated: json['is_top_rated'] ?? false,
      bio: json['bio'],
      experienceYears: json['experience_years'] ?? 0,
      certifications: List<String>.from(json['certifications'] ?? []),
      phoneNumber: json['phone_number'],
      location: json['location'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'profile_image_url': profileImageUrl,
      'rating': rating,
      'review_count': reviewCount,
      'distance': distance,
      'hourly_rate': hourlyRate,
      'services': services,
      'is_verified': isVerified,
      'is_available': isAvailable,
      'is_top_rated': isTopRated,
      'bio': bio,
      'experience_years': experienceYears,
      'certifications': certifications,
      'phone_number': phoneNumber,
      'location': location,
    };
  }

  String get formattedRate => 'AED $hourlyRate';
  String get formattedDistance => '${distance.toStringAsFixed(1)} km';
  String get formattedRating => rating.toStringAsFixed(1);
}
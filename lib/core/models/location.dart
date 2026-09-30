class Location {
  final String id;
  final String address;
  final String? label; // Home, Work, Other
  final double latitude;
  final double longitude;
  final String? buildingInfo;
  final String? instructions;
  final bool isPrimary;

  const Location({
    required this.id,
    required this.address,
    this.label,
    required this.latitude,
    required this.longitude,
    this.buildingInfo,
    this.instructions,
    this.isPrimary = false,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'] ?? '',
      address: json['address'] ?? '',
      label: json['label'],
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      buildingInfo: json['building_info'],
      instructions: json['instructions'],
      isPrimary: json['is_primary'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'address': address,
      'label': label,
      'latitude': latitude,
      'longitude': longitude,
      'building_info': buildingInfo,
      'instructions': instructions,
      'is_primary': isPrimary,
    };
  }
}
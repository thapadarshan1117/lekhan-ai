class PromoBanner {
  final String id;
  final String title;
  final String subtitle;
  final String code;
  final String description;
  final String? imageUrl;
  final String? linkUrl;
  final bool isActive;
  final DateTime? expiryDate;

  const PromoBanner({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.code,
    required this.description,
    this.imageUrl,
    this.linkUrl,
    this.isActive = true,
    this.expiryDate,
  });

  factory PromoBanner.fromJson(Map<String, dynamic> json) {
    return PromoBanner(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      code: json['code'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['image_url'],
      linkUrl: json['link_url'],
      isActive: json['is_active'] ?? true,
      expiryDate: json['expiry_date'] != null 
          ? DateTime.parse(json['expiry_date']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'code': code,
      'description': description,
      'image_url': imageUrl,
      'link_url': linkUrl,
      'is_active': isActive,
      'expiry_date': expiryDate?.toIso8601String(),
    };
  }

  bool get isExpired {
    if (expiryDate == null) return false;
    return DateTime.now().isAfter(expiryDate!);
  }
}
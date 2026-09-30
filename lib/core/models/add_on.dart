class AddOn {
  final String id;
  final String name;
  final String description;
  final double price;
  final String pricingType; // 'fixed', 'per_hour', 'per_sqm'
  final String? iconData;
  final bool isAvailable;
  final String category; // 'cleaning', 'maintenance', 'organization'

  const AddOn({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.pricingType,
    this.iconData,
    this.isAvailable = true,
    required this.category,
  });

  factory AddOn.fromJson(Map<String, dynamic> json) {
    return AddOn(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      pricingType: json['pricing_type'] ?? 'fixed',
      iconData: json['icon_data'],
      isAvailable: json['is_available'] ?? true,
      category: json['category'] ?? 'cleaning',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'pricing_type': pricingType,
      'icon_data': iconData,
      'is_available': isAvailable,
      'category': category,
    };
  }

  String get formattedPrice {
    switch (pricingType) {
      case 'per_hour':
        return 'NPR ${price.toStringAsFixed(0)}/hr';
      case 'per_sqm':
        return 'NPR ${price.toStringAsFixed(0)}/sqm';
      default:
        return 'NPR ${price.toStringAsFixed(0)}';
    }
  }
}
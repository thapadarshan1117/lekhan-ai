class ServiceCategory {
  final String id;
  final String title;
  final String description;
  final String iconData; // Icon name or asset path
  final String color; // Color hex code
  final String startingPrice;
  final bool isPopular;
  final bool isAvailable;

  const ServiceCategory({
    required this.id,
    required this.title,
    required this.description,
    required this.iconData,
    required this.color,
    required this.startingPrice,
    this.isPopular = false,
    this.isAvailable = true,
  });

  factory ServiceCategory.fromJson(Map<String, dynamic> json) {
    return ServiceCategory(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      iconData: json['icon_data'] ?? '',
      color: json['color'] ?? '#12E1BF',
      startingPrice: json['starting_price'] ?? '',
      isPopular: json['is_popular'] ?? false,
      isAvailable: json['is_available'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon_data': iconData,
      'color': color,
      'starting_price': startingPrice,
      'is_popular': isPopular,
      'is_available': isAvailable,
    };
  }
}
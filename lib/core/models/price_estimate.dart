class PriceEstimate {
  final double basePrice;
  final List<AddOnPrice> addOnPrices;
  final double tax;
  final double platformFee;
  final double discount;
  final double walletCredit;
  final double total;
  final String currency;

  const PriceEstimate({
    required this.basePrice,
    required this.addOnPrices,
    required this.tax,
    required this.platformFee,
    this.discount = 0.0,
    this.walletCredit = 0.0,
    required this.total,
    this.currency = 'NPR',
  });

  factory PriceEstimate.fromJson(Map<String, dynamic> json) {
    return PriceEstimate(
      basePrice: (json['base_price'] ?? 0.0).toDouble(),
      addOnPrices: (json['addons'] as List<dynamic>?)
          ?.map((addon) => AddOnPrice.fromJson(addon))
          .toList() ?? [],
      tax: (json['tax'] ?? 0.0).toDouble(),
      platformFee: (json['platform_fee'] ?? 0.0).toDouble(),
      discount: (json['discount'] ?? 0.0).toDouble(),
      walletCredit: (json['wallet_credit'] ?? 0.0).toDouble(),
      total: (json['total'] ?? 0.0).toDouble(),
      currency: json['currency'] ?? 'NPR',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'base_price': basePrice,
      'addons': addOnPrices.map((addon) => addon.toJson()).toList(),
      'tax': tax,
      'platform_fee': platformFee,
      'discount': discount,
      'wallet_credit': walletCredit,
      'total': total,
      'currency': currency,
    };
  }

  double get subtotal => basePrice + addOnPrices.fold(0.0, (sum, addon) => sum + addon.price);
  double get totalBeforeFees => subtotal - discount;
  double get finalTotal => totalBeforeFees + tax + platformFee - walletCredit;
}

class AddOnPrice {
  final String id;
  final String name;
  final double price;
  final int quantity;

  const AddOnPrice({
    required this.id,
    required this.name,
    required this.price,
    this.quantity = 1,
  });

  factory AddOnPrice.fromJson(Map<String, dynamic> json) {
    return AddOnPrice(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      quantity: json['quantity'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
    };
  }
}
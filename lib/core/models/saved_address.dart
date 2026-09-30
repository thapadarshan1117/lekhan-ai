import 'package:latlong2/latlong.dart';

enum AddressType {
  home,
  office,
  warehouse,
  shop,
  factory,
  other,
}

extension AddressTypeExtension on AddressType {
  String get displayName {
    switch (this) {
      case AddressType.home:
        return 'Home';
      case AddressType.office:
        return 'Office';
      case AddressType.warehouse:
        return 'Warehouse';
      case AddressType.shop:
        return 'Shop';
      case AddressType.factory:
        return 'Factory';
      case AddressType.other:
        return 'Other';
    }
  }
}

class SavedAddress {
  final String id;
  final String name;
  final String address;
  final String? street;
  final String? area;
  final String? city;
  final String? state;
  final String? pinCode;
  final String? landmark;
  final String latitude;
  final String longitude;
  final AddressType type;
  final bool isDefault;
  final String? contactName;
  final String? contactPhone;
  final DateTime? lastVisited;
  final DateTime createdAt;

  SavedAddress({
    required this.id,
    required this.name,
    required this.address,
    this.street,
    this.area,
    this.city,
    this.state,
    this.pinCode,
    this.landmark,
    required this.latitude,
    required this.longitude,
    this.type = AddressType.other,
    this.isDefault = false,
    this.contactName,
    this.contactPhone,
    this.lastVisited,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  LatLng get location => LatLng(double.parse(latitude), double.parse(longitude));

  String get displayAddress {
    final parts = <String>[];
    if (street != null && street!.isNotEmpty) parts.add(street!);
    if (area != null && area!.isNotEmpty) parts.add(area!);
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (state != null && state!.isNotEmpty) parts.add(state!);
    if (pinCode != null && pinCode!.isNotEmpty) parts.add(pinCode!);
    return parts.isNotEmpty ? parts.join(', ') : address;
  }

  String get shortAddress {
    final parts = <String>[];
    if (area != null && area!.isNotEmpty) parts.add(area!);
    if (city != null && city!.isNotEmpty) parts.add(city!);
    return parts.isNotEmpty ? parts.join(', ') : address;
  }

  String get formattedLastVisit {
    if (lastVisited == null) return 'Never visited';
    final difference = DateTime.now().difference(lastVisited!);
    if (difference.inDays == 0) return 'Today';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays} days ago';
    return '${(difference.inDays / 7).floor()} weeks ago';
  }

  SavedAddress copyWith({
    String? id,
    String? name,
    String? address,
    String? street,
    String? area,
    String? city,
    String? state,
    String? pinCode,
    String? landmark,
    String? latitude,
    String? longitude,
    AddressType? type,
    bool? isDefault,
    String? contactName,
    String? contactPhone,
    DateTime? lastVisited,
    DateTime? createdAt,
  }) {
    return SavedAddress(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      street: street ?? this.street,
      area: area ?? this.area,
      city: city ?? this.city,
      state: state ?? this.state,
      pinCode: pinCode ?? this.pinCode,
      landmark: landmark ?? this.landmark,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      type: type ?? this.type,
      isDefault: isDefault ?? this.isDefault,
      contactName: contactName ?? this.contactName,
      contactPhone: contactPhone ?? this.contactPhone,
      lastVisited: lastVisited ?? this.lastVisited,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'street': street,
      'area': area,
      'city': city,
      'state': state,
      'pinCode': pinCode,
      'landmark': landmark,
      'latitude': latitude,
      'longitude': longitude,
      'type': type.name,
      'isDefault': isDefault,
      'contactName': contactName,
      'contactPhone': contactPhone,
      'lastVisited': lastVisited?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory SavedAddress.fromJson(Map<String, dynamic> json) {
    return SavedAddress(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      street: json['street'],
      area: json['area'],
      city: json['city'],
      state: json['state'],
      pinCode: json['pinCode'],
      landmark: json['landmark'],
      latitude: json['latitude'].toString(),
      longitude: json['longitude'].toString(),
      type: AddressType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AddressType.other,
      ),
      isDefault: json['isDefault'] ?? false,
      contactName: json['contactName'],
      contactPhone: json['contactPhone'],
      lastVisited: json['lastVisited'] != null
          ? DateTime.parse(json['lastVisited'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}
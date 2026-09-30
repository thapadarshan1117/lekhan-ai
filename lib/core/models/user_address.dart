import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class UserAddress {
  final String id;
  final String label;
  final String fullAddress;
  final String area;
  final String city;
  final bool isDefault;
  final IconData icon;
  final String coordinates;
  final String apartmentNumber;
  final String building;
  final String instructions;
  final String contactName;
  final String contactPhone;
  final double latitude;
  final double longitude;

  const UserAddress({
    required this.id,
    required this.label,
    required this.fullAddress,
    required this.area,
    required this.city,
    required this.isDefault,
    required this.icon,
    required this.coordinates,
    required this.apartmentNumber,
    required this.building,
    required this.instructions,
    required this.contactName,
    required this.contactPhone,
    required this.latitude,
    required this.longitude,
  });

  // Sample addresses for Kathmandu locations
  static List<UserAddress> sampleAddresses = [
    const UserAddress(
      id: '1',
      label: 'Home',
      fullAddress: 'Tinkune, Kathmandu 44600, Nepal',
      area: 'Tinkune',
      city: 'Kathmandu',
      isDefault: true,
      icon: Iconsax.home,
      coordinates: '27.6778° N, 85.3471° E',
      apartmentNumber: 'House 12',
      building: 'Tinkune Residential Complex',
      instructions: 'Near Tinkune Petrol Pump, main road',
      contactName: 'Krishna Sharma',
      contactPhone: '+977 98-12345678',
      latitude: 27.6778,
      longitude: 85.3471,
    ),
    const UserAddress(
      id: '2',
      label: 'Office',
      fullAddress: 'Baneshwor, Kathmandu 44600, Nepal',
      area: 'Baneshwor',
      city: 'Kathmandu',
      isDefault: false,
      icon: Iconsax.buildings,
      coordinates: '27.6915° N, 85.3443° E',
      apartmentNumber: 'Floor 3, Office 301',
      building: 'Baneshwor Business Center',
      instructions: 'Near Baneshwor Chowk, blue building',
      contactName: 'Krishna Sharma',
      contactPhone: '+977 98-12345678',
      latitude: 27.6915,
      longitude: 85.3443,
    ),
    const UserAddress(
      id: '3',
      label: "Friend's Place",
      fullAddress: 'Milan Chowk, Baneshwor, Kathmandu 44600, Nepal',
      area: 'Milan Chowk, Baneshwor',
      city: 'Kathmandu',
      isDefault: false,
      icon: Iconsax.heart,
      coordinates: '27.6925° N, 85.3456° E',
      apartmentNumber: 'Flat 2B',
      building: 'Milan Residency',
      instructions: 'Near Milan Chowk, opposite to pharmacy',
      contactName: 'Rajesh Thapa',
      contactPhone: '+977 98-87654321',
      latitude: 27.6925,
      longitude: 85.3456,
    ),
  ];

  // JSON serialization
  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'fullAddress': fullAddress,
        'area': area,
        'city': city,
        'isDefault': isDefault,
        'coordinates': coordinates,
        'apartmentNumber': apartmentNumber,
        'building': building,
        'instructions': instructions,
        'contactName': contactName,
        'contactPhone': contactPhone,
        'latitude': latitude,
        'longitude': longitude,
      };

  factory UserAddress.fromJson(Map<String, dynamic> json) => UserAddress(
        id: json['id'],
        label: json['label'],
        fullAddress: json['fullAddress'],
        area: json['area'],
        city: json['city'],
        isDefault: json['isDefault'],
        icon: _getIconFromLabel(json['label']),
        coordinates: json['coordinates'],
        apartmentNumber: json['apartmentNumber'],
        building: json['building'],
        instructions: json['instructions'],
        contactName: json['contactName'],
        contactPhone: json['contactPhone'],
        latitude: json['latitude'].toDouble(),
        longitude: json['longitude'].toDouble(),
      );

  static IconData _getIconFromLabel(String label) {
    switch (label.toLowerCase()) {
      case 'home':
        return Iconsax.home;
      case 'office':
      case 'work':
        return Iconsax.buildings;
      default:
        return Iconsax.location;
    }
  }
}
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../models/saved_address.dart';

class LocationService extends ChangeNotifier {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  List<SavedAddress> _savedAddresses = [];
  List<SavedAddress> _recentLocations = [];
  SavedAddress? _currentAddress;
  bool _isLoading = false;

  List<SavedAddress> get savedAddresses => _savedAddresses;
  List<SavedAddress> get recentLocations => _recentLocations;
  SavedAddress? get currentAddress => _currentAddress;
  bool get isLoading => _isLoading;

  // Initialize with demo data
  void initialize() {
    _savedAddresses = [
      SavedAddress(
        id: '1',
        name: 'Head Office',
        address: 'Durbar Marg, Kathmandu',
        street: 'Durbar Marg',
        area: 'Central Business District',
        city: 'Kathmandu',
        state: 'Bagmati',
        pinCode: '44600',
        landmark: 'Near Hotel Yak & Yeti',
        latitude: 27.7142.toString(),
        longitude: 85.3145.toString(),
        type: AddressType.office,
        isDefault: true,
        contactName: 'Reception',
        contactPhone: '+977-1-4225836',
      ),
      SavedAddress(
        id: '2',
        name: 'Warehouse - Balaju',
        address: 'Balaju Industrial Area',
        street: 'Industrial Road',
        area: 'Balaju',
        city: 'Kathmandu',
        state: 'Bagmati',
        pinCode: '44611',
        latitude: 27.7328.toString(),
        longitude: 85.3001.toString(),
        type: AddressType.warehouse,
        contactName: 'Store Manager',
        contactPhone: '+977-9841234567',
      ),
      SavedAddress(
        id: '3',
        name: 'Branch Office - Pokhara',
        address: 'Lakeside, Pokhara',
        street: 'Lakeside Road',
        area: 'Lakeside',
        city: 'Pokhara',
        state: 'Gandaki',
        pinCode: '33700',
        landmark: 'Near Fewa Lake',
        latitude: 28.2096.toString(),
        longitude: 83.9856.toString(),
        type: AddressType.office,
        contactName: 'Branch Manager',
        contactPhone: '+977-9856789012',
      ),
    ];

    _recentLocations = [
      SavedAddress(
        id: 'r1',
        name: 'Himalayan Traders',
        address: 'Thamel, Kathmandu',
        area: 'Thamel',
        city: 'Kathmandu',
        latitude: 27.7172.toString(),
        longitude: 85.3240.toString(),
        type: AddressType.shop,
        lastVisited: DateTime.now().subtract(const Duration(hours: 2)),
        contactName: 'Ram Sharma',
        contactPhone: '+977-9841234567',
      ),
      SavedAddress(
        id: 'r2',
        name: 'Everest Electronics',
        address: 'New Road, Kathmandu',
        area: 'New Road',
        city: 'Kathmandu',
        latitude: 27.7019.toString()  ,
        longitude: 85.3147.toString(),
        type: AddressType.shop,
        lastVisited: DateTime.now().subtract(const Duration(days: 1)),
        contactName: 'Krishna Prasad',
        contactPhone: '+977-9823456789',
      ),
      SavedAddress(
        id: 'r3',
        name: 'Valley Distributors',
        address: 'Baneshwor, Kathmandu',
        area: 'Baneshwor',
        city: 'Kathmandu',
        latitude: 27.6915.toString(),
        longitude: 85.3443.toString(),
        type: AddressType.warehouse,
        lastVisited: DateTime.now().subtract(const Duration(days: 3)),
        contactName: 'Sita Thapa',
        contactPhone: '+977-9857654321',
      ),
    ];

    notifyListeners();
  }

  // Get current location
  Future<SavedAddress?> getCurrentLocation() async {
    _isLoading = true;
    notifyListeners();

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions permanently denied');
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      // Reverse geocode
      final address = await reverseGeocode(
        LatLng(position.latitude, position.longitude),
      );

      _currentAddress = address;
      _isLoading = false;
      notifyListeners();

      return address;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Reverse geocode coordinates to address
  Future<SavedAddress> reverseGeocode(LatLng location) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?'
        'format=json&'
        'lat=${location.latitude}&'
        'lon=${location.longitude}&'
        'zoom=18&'
        'addressdetails=1&'
        'accept-language=en',
      );

      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'SalesCRM/1.0',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch address');
      }

      final data = json.decode(response.body);
      final addressData = data['address'] as Map<String, dynamic>?;

      String? street = addressData?['road'] ?? addressData?['street'];
      String? area = addressData?['suburb'] ??
          addressData?['neighbourhood'] ??
          addressData?['village'];
      String? city = addressData?['city'] ??
          addressData?['town'] ??
          addressData?['municipality'];
      String? state = addressData?['state'] ?? addressData?['province'];
      String? pinCode = addressData?['postcode'];

      return SavedAddress(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: 'Current Location',
        address: data['display_name'] ?? 'Unknown location',
        street: street,
        area: area,
        city: city,
        state: state,
        pinCode: pinCode,
        latitude: location.latitude.toString(),
        longitude: location.longitude.toString(),
        type: AddressType.other,
      );
    } catch (e) {
      // Return basic address on error
      return SavedAddress(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: 'Current Location',
        address: 'Lat: ${location.latitude.toStringAsFixed(6)}, '
            'Lng: ${location.longitude.toStringAsFixed(6)}',
        latitude: location.latitude.toString(),
        longitude: location.longitude.toString(),
        type: AddressType.other,
      );
    }
  }

  // Search addresses using OpenStreetMap Nominatim
  Future<List<SavedAddress>> searchAddresses(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?'
        'format=json&'
        'q=${Uri.encodeComponent(query)}&'
        'limit=10&'
        'addressdetails=1&'
        'countrycodes=np&'
        'accept-language=en',
      );

      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'SalesCRM/1.0',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Search failed');
      }

      final List<dynamic> results = json.decode(response.body);

      return results.map((item) {
        final addressData = item['address'] as Map<String, dynamic>?;

        return SavedAddress(
          id: item['place_id'].toString(),
          name: item['display_name'].toString().split(',').first,
          address: item['display_name'] ?? '',
          street: addressData?['road'] ?? addressData?['street'],
          area: addressData?['suburb'] ??
              addressData?['neighbourhood'] ??
              addressData?['village'],
          city: addressData?['city'] ??
              addressData?['town'] ??
              addressData?['municipality'],
          state: addressData?['state'] ?? addressData?['province'],
          pinCode: addressData?['postcode'],
          latitude: item['lat'].toString(),
          longitude: item['lon'].toString(),
          type: AddressType.other,
        );
      }).toList();
    } catch (e) {
      debugPrint('Search error: $e');
      return [];
    }
  }

  // Add to recent locations
  void addToRecentLocations(SavedAddress address) {
    // Remove if already exists
    _recentLocations.removeWhere((a) => a.id == address.id);

    // Add to beginning
    _recentLocations.insert(
      0,
      address.copyWith(lastVisited: DateTime.now()),
    );

    // Keep only last 10
    if (_recentLocations.length > 10) {
      _recentLocations = _recentLocations.take(10).toList();
    }

    notifyListeners();
  }

  // Save address
  void saveAddress(SavedAddress address) {
    final index = _savedAddresses.indexWhere((a) => a.id == address.id);
    if (index >= 0) {
      _savedAddresses[index] = address;
    } else {
      _savedAddresses.add(address);
    }
    notifyListeners();
  }

  // Delete address
  void deleteAddress(String id) {
    _savedAddresses.removeWhere((a) => a.id == id);
    notifyListeners();
  }

  // Set default address
  void setDefaultAddress(String id) {
    for (int i = 0; i < _savedAddresses.length; i++) {
      _savedAddresses[i] = _savedAddresses[i].copyWith(
        isDefault: _savedAddresses[i].id == id,
      );
    }
    notifyListeners();
  }

  // Set current address
  void setCurrentAddress(SavedAddress address) {
    _currentAddress = address;
    notifyListeners();
  }
}

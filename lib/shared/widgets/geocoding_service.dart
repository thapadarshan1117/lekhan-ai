import 'dart:convert';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class AddressResult {
  final String? street;
  final String? subLocality;
  final String? locality; // City
  final String? subAdministrativeArea; // District
  final String? administrativeArea; // State/Province
  final String? postalCode;
  final String? country;
  final String? countryCode;
  final String formattedAddress;

  AddressResult({
    this.street,
    this.subLocality,
    this.locality,
    this.subAdministrativeArea,
    this.administrativeArea,
    this.postalCode,
    this.country,
    this.countryCode,
    required this.formattedAddress,
  });

  // Get short address (street + area)
  String get shortAddress {
    final parts = <String>[];
    if (street != null && street!.isNotEmpty) parts.add(street!);
    if (subLocality != null && subLocality!.isNotEmpty) parts.add(subLocality!);
    if (locality != null && locality!.isNotEmpty) parts.add(locality!);
    return parts.isEmpty ? formattedAddress : parts.join(', ');
  }

  // Get city with state
  String get cityState {
    final parts = <String>[];
    if (locality != null && locality!.isNotEmpty) parts.add(locality!);
    if (administrativeArea != null && administrativeArea!.isNotEmpty) {
      parts.add(administrativeArea!);
    }
    return parts.join(', ');
  }

  @override
  String toString() => formattedAddress;
}

class GeocodingService {
  // Singleton pattern
  static final GeocodingService _instance = GeocodingService._internal();
  factory GeocodingService() => _instance;
  GeocodingService._internal();

  /// Get address from coordinates using platform geocoding
  Future<AddressResult?> getAddressFromCoordinates(LatLng location) async {
    try {
      // Try platform geocoding first
      final result = await _getPlatformGeocoding(location);
      if (result != null) return result;

      // Fallback to OpenStreetMap Nominatim
      return await _getOpenStreetMapGeocoding(location);
    } catch (e) {
      print('Geocoding error: $e');
      // Try fallback
      try {
        return await _getOpenStreetMapGeocoding(location);
      } catch (e2) {
        print('Fallback geocoding error: $e2');
        return null;
      }
    }
  }

  /// Platform-specific geocoding (uses Google on Android, Apple on iOS)
  Future<AddressResult?> _getPlatformGeocoding(LatLng location) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (placemarks.isEmpty) return null;

      final place = placemarks.first;

      // Build formatted address
      final addressParts = <String>[];
      if (place.street != null && place.street!.isNotEmpty) {
        addressParts.add(place.street!);
      }
      if (place.subLocality != null && place.subLocality!.isNotEmpty) {
        addressParts.add(place.subLocality!);
      }
      if (place.locality != null && place.locality!.isNotEmpty) {
        addressParts.add(place.locality!);
      }
      if (place.administrativeArea != null &&
          place.administrativeArea!.isNotEmpty) {
        addressParts.add(place.administrativeArea!);
      }
      if (place.postalCode != null && place.postalCode!.isNotEmpty) {
        addressParts.add(place.postalCode!);
      }
      if (place.country != null && place.country!.isNotEmpty) {
        addressParts.add(place.country!);
      }

      return AddressResult(
        street: place.street,
        subLocality: place.subLocality,
        locality: place.locality,
        subAdministrativeArea: place.subAdministrativeArea,
        administrativeArea: place.administrativeArea,
        postalCode: place.postalCode,
        country: place.country,
        countryCode: place.isoCountryCode,
        formattedAddress: addressParts.join(', '),
      );
    } catch (e) {
      print('Platform geocoding error: $e');
      return null;
    }
  }

  /// OpenStreetMap Nominatim reverse geocoding (free, no API key needed)
  Future<AddressResult?> _getOpenStreetMapGeocoding(LatLng location) async {
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
          'User-Agent': 'CRMApp/1.0', // Required by Nominatim
          'Accept': 'application/json',
          'Accept-Language': 'en',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch address: ${response.statusCode}');
      }

      final data = json.decode(response.body);

      if (data['error'] != null) {
        throw Exception(data['error']);
      }

      final address = data['address'] as Map<String, dynamic>?;

      if (address == null) {
        return AddressResult(
          formattedAddress: data['display_name'] ?? 'Unknown location',
        );
      }

      // Extract address components
      String? street =
          address['road'] ??
          address['pedestrian'] ??
          address['footway'] ??
          address['street'];

      String? houseNumber = address['house_number'];
      if (houseNumber != null && street != null) {
        street = '$houseNumber $street';
      }

      String? subLocality =
          address['suburb'] ??
          address['neighbourhood'] ??
          address['quarter'] ??
          address['village'];

      String? locality =
          address['city'] ??
          address['town'] ??
          address['municipality'] ??
          address['village'];

      String? subAdministrativeArea = address['county'] ?? address['district'];

      String? administrativeArea =
          address['state'] ?? address['province'] ?? address['region'];

      String? postalCode = address['postcode'];

      String? country = address['country'];
      String? countryCode = address['country_code']?.toUpperCase();

      return AddressResult(
        street: street,
        subLocality: subLocality,
        locality: locality,
        subAdministrativeArea: subAdministrativeArea,
        administrativeArea: administrativeArea,
        postalCode: postalCode,
        country: country,
        countryCode: countryCode,
        formattedAddress: data['display_name'] ?? 'Unknown location',
      );
    } catch (e) {
      print('OpenStreetMap geocoding error: $e');
      return null;
    }
  }

  /// Search for places by query
  Future<List<SearchResult>> searchPlaces(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?'
        'format=json&'
        'q=${Uri.encodeComponent(query)}&'
        'limit=10&'
        'addressdetails=1&'
        'accept-language=en',
      );

      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'CRMApp/1.0',
          'Accept': 'application/json',
          'Accept-Language': 'en',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Search failed: ${response.statusCode}');
      }

      final List<dynamic> results = json.decode(response.body);

      return results.map((item) {
        return SearchResult(
          displayName: item['display_name'] ?? '',
          latitude: double.parse(item['lat']),
          longitude: double.parse(item['lon']),
          type: item['type'] ?? '',
          importance: (item['importance'] ?? 0).toDouble(),
        );
      }).toList();
    } catch (e) {
      print('Search error: $e');
      return [];
    }
  }

  /// Get current location with address
  Future<LocationData?> getCurrentLocationWithAddress() async {
    try {
      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permission denied by user');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('Location permission permanently denied');
        return null;
      }

      // Get current position with timeout
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      print('Position obtained: ${position.latitude}, ${position.longitude}');

      // Try to get address with timeout
      AddressResult? addressResult;
      try {
        addressResult = await getAddressFromCoordinates(
          LatLng(position.latitude, position.longitude),
        ).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            print('Address fetch timeout');
            return null;
          },
        );
      } catch (e) {
        print('Failed to get address, will use coordinates: $e');
      }

      // Use formatted address, or fall back to coordinate-based location
      String? address = addressResult?.formattedAddress;
      if (address == null || address.isEmpty) {
        // Fallback: create address from coordinates
        address = '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
        print('Using coordinate-based address fallback: $address');
      }

      return LocationData(
        address: address,
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (e) {
      print('Error getting current location: $e');
      return null;
    }
  }
}

class SearchResult {
  final String displayName;
  final double latitude;
  final double longitude;
  final String type;
  final double importance;

  SearchResult({
    required this.displayName,
    required this.latitude,
    required this.longitude,
    required this.type,
    required this.importance,
  });

  LatLng get location => LatLng(latitude, longitude);
}

class LocationData {
  final String? address;
  final double latitude;
  final double longitude;

  LocationData({
    required this.address,
    required this.latitude,
    required this.longitude,
  });
}

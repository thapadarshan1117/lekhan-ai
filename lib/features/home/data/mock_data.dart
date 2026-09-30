import 'package:flutter/material.dart';
import 'models/service_category_model.dart';
import 'models/pro_listing_model.dart';
import 'models/spotlight_banner_model.dart';

const List<String> recentSearches = ['Plumber', 'Electricians', 'AC Repair'];

const List<ServiceCategory> categories = [
  ServiceCategory(
    nameEn: 'Cleaning',
    nameNp: 'सरसफाई',
    imagePath: 'assets/categories/cleaning.png',
  ),
  ServiceCategory(
    nameEn: 'Electrician',
    nameNp: 'इलेक्ट्रिशियन',
    imagePath: 'assets/categories/electrician.png',
  ),
  ServiceCategory(
    nameEn: 'Carpenter',
    nameNp: 'सिकर्मी',
    imagePath: 'assets/categories/carpenter.png',
  ),
  ServiceCategory(
    nameEn: 'Plumbing',
    nameNp: 'जडान',
    imagePath: 'assets/categories/plumbing.png',
  ),
  ServiceCategory(
    nameEn: 'AC Repair',
    nameNp: 'सिकर्मी',
    imagePath: 'assets/categories/ac_repair.png',
  ),
  ServiceCategory(
    nameEn: 'Tank Clean',
    nameNp: 'सरसफाई',
    imagePath: 'assets/categories/tank_clean.png',
  ),
  ServiceCategory(
    nameEn: 'Gardening',
    nameNp: 'सरसफाई',
    imagePath: 'assets/categories/gardening.png',
  ),
  ServiceCategory(
    nameEn: 'Beauty Service',
    nameNp: 'उपकरण मर्मत',
    imagePath: 'assets/categories/beauty_service.png',
  ),
  ServiceCategory(
    nameEn: 'Appliance Care',
    nameNp: 'सिकर्मी',
    imagePath: 'assets/categories/appliance_care.png',
  ),
  ServiceCategory(
    nameEn: 'Painting',
    nameNp: 'इलेक्ट्रिशियन',
    imagePath: 'assets/categories/painting.png',
  ),
  ServiceCategory(
    nameEn: 'Pest Control',
    nameNp: 'सरसफाई',
    imagePath: 'assets/categories/pest_control.png',
  ),
  ServiceCategory(
    nameEn: 'Sofa Cleaning',
    nameNp: 'रंगरोगन',
    imagePath: 'assets/categories/sofa_cleaning.png',
  ),
];

const List<ProListing> topRatedPros = [
  ProListing(
    name: 'Sunil Sharma',
    role: 'Expert Electrician',
    imageUrl:
        'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=200',
    jobsCount: 800,
    yearsExp: 4,
    rating: 5.0,
    pricePerHour: 1500,
  ),
  ProListing(
    name: 'Sunil Sharma',
    role: 'Expert Electrician',
    imageUrl:
        'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=200',
    jobsCount: 200,
    yearsExp: 1,
    rating: 4.9,
    pricePerHour: 400,
  ),
  ProListing(
    name: 'Sunil Sharma',
    role: 'Expert Electrician',
    imageUrl:
        'https://images.unsplash.com/photo-1607472829268-3c1a92c39d31?w=200',
    jobsCount: 1200,
    yearsExp: 2,
    rating: 3.8,
    pricePerHour: 450,
  ),
  ProListing(
    name: 'Sunil Sharma',
    role: 'Expert Electrician',
    imageUrl:
        'https://images.unsplash.com/photo-1621905252472-943afaa20e20?w=200',
    jobsCount: 120,
    yearsExp: 4,
    rating: 5.0,
    pricePerHour: 820,
  ),
];

const List<SpotlightBanner> spotlightBanners = [
  SpotlightBanner(
    title: 'Home Spa Day?',
    subtitle: 'Professional cleaning and sanitization for your peaceful weekend.',
    ctaLabel: 'Claim 20% Off',
    imageUrl:
        'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=600',
    overlayColor: Color(0xCC7A4A22),
  ),
  SpotlightBanner(
    title: 'Home Repair?',
    subtitle: 'Book a trusted pro for your home today.',
    ctaLabel: 'Claim 20% Off',
    imageUrl:
        'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=600',
    overlayColor: Color(0xCC1E3A8A),
  ),
];

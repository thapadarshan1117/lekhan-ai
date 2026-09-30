import 'package:flutter/material.dart';

class SpotlightBanner {
  final String title;
  final String subtitle;
  final String ctaLabel;
  final String imageUrl;
  final Color overlayColor;

  const SpotlightBanner({
    required this.title,
    required this.subtitle,
    required this.ctaLabel,
    required this.imageUrl,
    required this.overlayColor,
  });
}

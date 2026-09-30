import 'package:flutter/material.dart';
import 'package:lekhan_ai/features/home/data/mock_data.dart';
import 'spotlight_card.dart';

class SpotlightCarousel extends StatelessWidget {
  const SpotlightCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: spotlightBanners.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final banner = spotlightBanners[index];
          return SpotlightCard(banner: banner);
        },
      ),
    );
  }
}

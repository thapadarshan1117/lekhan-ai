import 'package:flutter/material.dart';
import 'package:lekhan_ai/features/home/data/mock_data.dart';
import 'pro_card.dart';

class TopRatedProsList extends StatelessWidget {
  const TopRatedProsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final pro in topRatedPros) ...[
          ProCard(pro: pro),
          if (pro != topRatedPros.last) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

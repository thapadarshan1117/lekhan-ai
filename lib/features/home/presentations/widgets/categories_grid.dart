import 'package:flutter/material.dart';
import 'package:lekhan_ai/features/home/data/mock_data.dart';
import 'category_tile.dart';

class CategoriesGrid extends StatelessWidget {
  const CategoriesGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
    
      builder: (context, constraints) {
        const crossAxisCount = 4;
        const spacing = 12.0;
        final itemWidth =
            (constraints.maxWidth - spacing * (crossAxisCount - 1)) /
                crossAxisCount;

        return Wrap(
          spacing: spacing,
          runSpacing: 24,
          children: [
            for (final category in categories)
              SizedBox(
                width: itemWidth,
                child: CategoryTile(category: category),
              ),
          ],
        );
      },
    );
  }
}
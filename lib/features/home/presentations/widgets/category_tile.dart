import 'package:lekhan_ai/features/home/data/models/service_category_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CategoryTile extends StatelessWidget {
  final ServiceCategory category;

  const CategoryTile({
    required this.category,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () {
        context.pushNamed(
          'categoryPros',
          pathParameters: {'categoryName': category.nameEn},
          extra: {
            'category': category,
          },
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: 36,
            height: 36,
            child: Image.asset(
              category.imagePath,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            category.nameEn,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          Text(
            category.nameNp,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
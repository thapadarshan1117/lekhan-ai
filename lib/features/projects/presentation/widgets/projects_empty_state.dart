import 'package:flutter/material.dart';
import 'package:lekhan_ai/core/theme/app_color.dart';

/// Shown when the list has nothing in it.
///
/// Two different situations, two different messages: an empty account is normal,
/// an empty cache while the load failed is not.
class ProjectsEmptyState extends StatelessWidget {
  const ProjectsEmptyState({super.key, this.offline = false});

  final bool offline;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                offline ? Icons.cloud_off_outlined : Icons.library_books_outlined,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              offline ? 'Nothing available offline' : 'No projects yet',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              offline
                  ? 'Pull down to try again once you have a connection.'
                  : 'Create your first ghost-writing project and it will be '
                      'saved on this device straight away.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                height: 1.4,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

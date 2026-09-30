import 'package:flutter/material.dart';

class SnackbarUtils {
  static void internetConnectionSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 4,
        duration: const Duration(days: 1),
        action: SnackBarAction(
          label: 'Dismiss',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
        margin: const EdgeInsets.only(bottom: 30, left: 20, right: 20),
        content: Row(
          children: [
            const Icon(Icons.wifi_off_outlined),
            const SizedBox(width: 10),
            Text(
              'No internet connection!',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

import 'package:lekhan_ai/core/theme/app_color.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

class ErrorPage extends StatelessWidget {
  final String title;
  final String message;
  final String buttonText;
  final String? returnRoute;
  final VoidCallback? onButtonPressed;
  final bool showHomeButton;

  const ErrorPage({
    super.key,
    this.title = 'Oops! Page Not Found',
    this.message =
        'The page you\'re looking for doesn\'t exist or may have been moved. Let\'s get you back on track.',
    this.buttonText = 'Retry',
    this.returnRoute,
    this.onButtonPressed,
    this.showHomeButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Full-page Lottie animation as the background layer
          Positioned.fill(
            child: Lottie.asset(
              'assets/lottie/404.json',
              fit: BoxFit.cover,
              repeat: true,
            ),
          ),

          // Foreground content, anchored to the bottom over the animation
          SafeArea(
            child: Column(
              children: [
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Error title
                      Text(
                        title,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 12),

                      // Error message
                      Text(
                        message,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 24),

                      // Retry button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: onButtonPressed ??
                              () {
                                if (returnRoute != null) {
                                  context.go(returnRoute!);
                                } else if (context.canPop()) {
                                  context.pop();
                                } else {
                                  context.go('/projects');
                                }
                              },
                          icon: const Icon(Icons.refresh_rounded, size: 20),
                          label: Text(
                            buttonText,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),

                      if (showHomeButton) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton(
                            onPressed: () => context.go('/home'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.primary),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Go to Home',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
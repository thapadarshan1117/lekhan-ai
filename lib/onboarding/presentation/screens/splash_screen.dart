import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lekhan_ai/onboarding/presentation/bloc/splash_bloc/splash_bloc.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SplashBloc()..add(const SplashEvent.checkStatus()),
      child: BlocConsumer<SplashBloc, SplashState>(
        listener: (context, state) {
          state.whenOrNull(
            authenticated: () {
              debugPrint("Navigating to projects");
              GoRouter.of(context).go('/projects');
            },
            unauthenticated: () {
              debugPrint("Navigating to login");
              GoRouter.of(context).go('/login');
            },
            needsOnboarding: () {
              debugPrint("Navigating to tour sign in");
              GoRouter.of(context).go('/tour-signin');
            },
            firstLaunch: () {
              debugPrint(
                "Navigating to tour sign in after fresh install",
              );
              GoRouter.of(context).go('/tour-signin');
            },
          );
        },
        builder: (context, state) {
          return const _SplashScreenContent();
        },
      ),
    );
  }
}

class _SplashScreenContent extends StatefulWidget {
  const _SplashScreenContent();

  @override
  State<_SplashScreenContent> createState() =>
      _SplashScreenContentState();
}

class _SplashScreenContentState
    extends State<_SplashScreenContent> {
  final int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenHeight = constraints.maxHeight;
          final screenWidth = constraints.maxWidth;

          // -------------------------------------------------------
          // FEATURES CARD POSITION
          //
          // The card itself starts at approximately 66% of the
          // screen height, which is the beginning of the bottom
          // third of the screen.
          // -------------------------------------------------------
          final featureTop = screenHeight * 0.66;

          // Responsive logo size.
          final logoSize = (screenWidth * 0.45).clamp(
            140.0,
            180.0,
          );

          // Responsive top spacing.
          final topSpacing = (screenHeight * 0.07).clamp(
            40.0,
            60.0,
          );

          return Stack(
            children: [
              // ===================================================
              // BACKGROUND IMAGE
              // ===================================================
              Positioned.fill(
                child: Image.asset(
                  'assets/images/main.jpg',
                  fit: BoxFit.cover,
                ),
              ),

              // ===================================================
              // DARK OVERLAY
              // ===================================================
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.3),
                ),
              ),

              // ===================================================
              // TOP CONTENT
              // ===================================================
              Positioned(
                top: topSpacing,
                left: 20,
                right: 20,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // -------------------------------
                    // LOGO
                    // -------------------------------
                    Image.asset(
                      'assets/icons/logo.png',
                      width: logoSize,
                      height: logoSize,
                    )
                        .animate()
                        .fadeIn(
                          duration: 600.ms,
                          curve: Curves.easeOutCubic,
                        )
                        .scale(
                          begin: const Offset(0.9, 0.9),
                          end: const Offset(1.0, 1.0),
                          duration: 600.ms,
                          curve: Curves.easeOutCubic,
                        ),

                    const SizedBox(height: 4),

                    // -------------------------------
                    // NEPALI TAGLINE
                    // -------------------------------
                    Text(
                      'घरमे सेवा, अब कहीँ क्लिकमे।',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                        .animate()
                        .fadeIn(
                          delay: 300.ms,
                          duration: 600.ms,
                          curve: Curves.easeOutCubic,
                        ),
                  ],
                ),
              ),

              // ===================================================
              // BOTTOM CONTENT
              //
              // IMPORTANT:
              // This entire section starts at 66% of the screen,
              // but the FEATURE CARD is the first child, so its
              // position is predictable on different screens.
              // ===================================================
              Positioned(
                top: featureTop,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ==========================================
                      // FEATURES CARD
                      // ==========================================
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 18,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(
                            alpha: 0.5,
                          ),
                          borderRadius:
                              BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(
                              alpha: 0.2,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: _FeatureItem(
                                icon:
                                    Icons.verified_user_rounded,
                                label: 'Trusted\nExperts',
                                textTheme: textTheme,
                              ),
                            ),

                            Expanded(
                              child: _FeatureItem(
                                icon: Icons.schedule_rounded,
                                label: 'On-Time\nServices',
                                textTheme: textTheme,
                              ),
                            ),

                            Expanded(
                              child: _FeatureItem(
                                icon: Icons.star_rounded,
                                label: 'Quality\nAssured',
                                textTheme: textTheme,
                              ),
                            ),

                            Expanded(
                              child: _FeatureItem(
                                icon:
                                    Icons.headset_mic_rounded,
                                label: '24/7\nSupport',
                                textTheme: textTheme,
                              ),
                            ),
                          ],
                        ),
                      )
                          .animate()
                          .fadeIn(
                            delay: 600.ms,
                            duration: 600.ms,
                            curve: Curves.easeOutCubic,
                          )
                          .slideY(
                            begin: 0.3,
                            end: 0,
                            duration: 600.ms,
                            curve: Curves.easeOutCubic,
                          ),

                      const SizedBox(height: 18),

                      // ==========================================
                      // GET STARTED BUTTON
                      // ==========================================
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            context.go('/login');
                          },
                          icon: const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                          ),
                          label: Text(
                            'Get Started',
                            style:
                                textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                colorScheme.secondary,
                            elevation: 0,
                            shadowColor:
                                Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(28),
                            ),
                          ),
                        ),
                      )
                          .animate()
                          .fadeIn(
                            delay: 800.ms,
                            duration: 600.ms,
                            curve: Curves.easeOutCubic,
                          )
                          .slideY(
                            begin: 0.3,
                            end: 0,
                            duration: 600.ms,
                            curve: Curves.easeOutCubic,
                          ),

                      const SizedBox(height: 12),

                      // ==========================================
                      // BOTTOM TAGLINE
                      // ==========================================
                      Text(
                        '🛡️ Safe, Reliable, Just for You.',
                        textAlign: TextAlign.center,
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(
                            alpha: 0.8,
                          ),
                          fontWeight: FontWeight.w500,
                        ),
                      )
                          .animate()
                          .fadeIn(
                            delay: 900.ms,
                            duration: 600.ms,
                            curve: Curves.easeOutCubic,
                          ),

                      const SizedBox(height: 12),

                      // ==========================================
                      // PAGINATION DOTS
                      // ==========================================
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          _PaginationDot(
                            isActive: _currentPage == 0,
                            colorScheme: colorScheme,
                          ),
                          const SizedBox(width: 8),

                          _PaginationDot(
                            isActive: _currentPage == 1,
                            colorScheme: colorScheme,
                          ),
                          const SizedBox(width: 8),

                          _PaginationDot(
                            isActive: _currentPage == 2,
                            colorScheme: colorScheme,
                          ),
                        ],
                      )
                          .animate()
                          .fadeIn(
                            delay: 1000.ms,
                            duration: 600.ms,
                            curve: Curves.easeOutCubic,
                          ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ===============================================================
// FEATURE ITEM
// ===============================================================

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final TextTheme textTheme;

  const _FeatureItem({
    required this.icon,
    required this.label,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 28,
        ),

        const SizedBox(height: 8),

        Text(
          label,
          textAlign: TextAlign.center,
          style: textTheme.bodySmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}

// ===============================================================
// PAGINATION DOT
// ===============================================================

class _PaginationDot extends StatelessWidget {
  final bool isActive;
  final ColorScheme colorScheme;

  const _PaginationDot({
    required this.isActive,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isActive ? 20 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive
            ? colorScheme.secondary
            : Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
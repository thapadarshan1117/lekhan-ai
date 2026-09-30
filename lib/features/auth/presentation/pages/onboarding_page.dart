import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import 'package:lekhan_ai/l10n/app_localizations.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final List<OnboardingContent> pages = [
      OnboardingContent(
        image: 'assets/images/onboarding_crm_1.svg',
        title: 'Welcome to Pokhara CRM',
        subtitle: 'Manage Relationships Smarter',
        description:
            'All your customers, leads, and interactions organized in one powerful platform.',
      ),
      OnboardingContent(
        image: 'assets/images/onboarding_crm_2.svg',
        title: 'Track Leads & Opportunities',
        subtitle: 'Never Miss a Follow-Up',
        description:
            'Capture leads, track activities, and move deals forward with a clear sales pipeline.',
      ),
      OnboardingContent(
        image: 'assets/images/onboarding_crm_3.svg',
        title: 'Grow with Confidence',
        subtitle: 'Insights That Drive Results',
        description:
            'Make data-driven decisions with real-time insights, reports, and team visibility.',
      ),
    ];

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Stack(
          children: [
            // Background gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    theme.colorScheme.surface,
                    theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
                    theme.colorScheme.surface,
                  ],
                  stops: const [0.0, 0.3, 1.0],
                ),
              ),
            ),
            Column(
              children: [
                // Progress indicator
                Padding(
                  padding: const EdgeInsets.only(top: 60, left: 24, right: 24),
                  child: _buildProgressIndicator(pages.length),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                      _animationController.reset();
                      _animationController.forward();
                    },
                    itemCount: pages.length,
                    itemBuilder: (context, index) {
                      return FadeTransition(
                        opacity: _fadeAnimation,
                        child: _buildPage(pages[index]),
                      );
                    },
                  ),
                ),
                _buildBottomControls(l10n, pages.length),
                const SizedBox(height: 22),
              ],
            ),
            // Skip button
            Positioned(
              top: 16,
              right: 16,
              child: TextButton(
                onPressed: () => context.go('/login'),
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  'Skip Intro',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.outline,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(int totalPages) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < totalPages; i++)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            height: 6,
            width: _currentPage == i ? 24 : 6,
            decoration: BoxDecoration(
              color: _currentPage == i
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context)
                      .colorScheme
                      .outline
                      .withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
      ],
    );
  }

  Widget _buildPage(OnboardingContent content) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
      child: Column(
        children: [
          // Image section
          Expanded(
            flex: 4,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color:
                      theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: SvgPicture.asset(
                  content.image,
                  height: MediaQuery.of(context).size.height * 0.25,
                  width: MediaQuery.of(context).size.width * 0.7,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          // Content section
          Expanded(
            flex: 3,
            child: Column(
              children: [
                // Title
                Text(
                  content.title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 8),

                // Subtitle (if exists)
                if (content.subtitle != null)
                  Text(
                    content.subtitle!,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                const SizedBox(height: 8),

                // Description
                Text(
                  content.description,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls(AppLocalizations l10n, int totalPages) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          // Main action button
          SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton(
              onPressed: _onNextPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                elevation: 2,
                shadowColor: theme.colorScheme.primary.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _currentPage == totalPages - 1 ? 'Get Started' : l10n.next,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                  if (_currentPage < totalPages - 1) ...[
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 20,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ],
                ],
              ),
            ),
          ),

          if (_currentPage == totalPages - 1) ...[
            const SizedBox(height: 12),
            Text(
              'By continuing, you agree to our Terms & Privacy Policy.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _onNextPressed() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      // Mark onboarding as completed and navigate to login
      _markOnboardingCompleted();
      context.go('/login');
    }
  }

  void _markOnboardingCompleted() {
    // This would typically save to shared preferences
    // SharedPreferences.getInstance().then((prefs) {
    //   prefs.setBool('onboarding_completed', true);
    // });
  }
}

class OnboardingContent {
  final String image;
  final String title;
  final String? subtitle;
  final String description;
  final List<OnboardingHighlight> highlights;

  OnboardingContent({
    required this.image,
    required this.title,
    this.subtitle,
    required this.description,
    this.highlights = const [],
  });
}

class OnboardingHighlight {
  final String icon;
  final String text;

  OnboardingHighlight({
    required this.icon,
    required this.text,
  });
}

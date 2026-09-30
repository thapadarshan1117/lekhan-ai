
import 'package:lekhan_ai/features/profile/pages/help_center_page.dart';
import 'package:lekhan_ai/features/profile/pages/terms_and_policy_page.dart';
import 'package:lekhan_ai/features/home/presentations/pages/home_page.dart';
import 'package:lekhan_ai/features/home/data/models/service_category_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lekhan_ai/core/config/dependency_injection/di_config.dart';
import 'package:lekhan_ai/core/config/navigation/app_scaffold_with_navbar.dart';
import 'package:lekhan_ai/core/error/error_page.dart';
import 'package:lekhan_ai/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:lekhan_ai/features/auth/presentation/pages/login_page.dart';
import 'package:lekhan_ai/features/auth/presentation/pages/otp_verification_page.dart';
import 'package:lekhan_ai/features/auth/presentation/pages/signup_page.dart';
import 'package:lekhan_ai/features/auth/presentation/pages/new_password.dart';
import 'package:lekhan_ai/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:lekhan_ai/features/notifications/presentation/pages/notification_screen.dart';
import 'package:lekhan_ai/features/profile/pages/profile_page.dart';
import 'package:lekhan_ai/features/profile/pages/edit_profile_page.dart';
import 'package:lekhan_ai/features/profile/pages/favorites_page.dart';
import 'package:lekhan_ai/features/profile/pages/address_page.dart';
import 'package:lekhan_ai/onboarding/presentation/screens/splash_screen.dart';


class RouterManager {
  static GoRouter? _router;
  static bool _isInitialized = false;

  static GoRouter get router {
    if (!_isInitialized) {
      debugPrint('🏗️ Initializing router');
      _router = _createRouter();
      _isInitialized = true;
    }
    _router ??= _createRouter();
    return _router!;
  }

  static GoRouter _createRouter() {
    debugPrint('🏗️ Creating router');

    return GoRouter(
      initialLocation: '/',
      debugLogDiagnostics: true,
      errorBuilder: (context, state) => const ErrorPage(),
      routes: <RouteBase>[
        // Splash Screen
        GoRoute(
          path: '/',
          builder: (context, state) => SplashScreen(),
        ),

        // Authentication Routes
        ..._authRoutes,


        // Bottom Navigation Shell
        _navigationShell,

        // Detail Pages (No Bottom Nav) - These are shown without navbar
        ..._detailRoutes,
      ],
    );
  }

  // ============================================
  // AUTHENTICATION ROUTES
  // ============================================
  static List<RouteBase> get _authRoutes => [
    GoRoute(path: '/login', builder: (context, state) => LoginPage()),
    GoRoute(path: '/signup', builder: (context, state) => SignUpPage()),
    GoRoute(
      path: '/otp-verification',
      builder: (context, state) {
        final raw = state.extra;
        final extras = raw is Map ? Map<String, dynamic>.from(raw) : null;
        final email = extras?['email'] as String? ?? '';
        final userData = extras?['userData'] is Map
            ? Map<String, dynamic>.from(extras!['userData'] as Map)
            : <String, dynamic>{};
        final isForgot = extras?['isForgot'] as bool? ?? false;
        final hash = extras?['hash'] as String? ?? '';
        return OTPVerificationPage(
          email: email,
          userData: userData,
          isForgot: isForgot,
          hash: hash,
        );
      },
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) {
        final email = state.extra as String? ?? '';
        return TeacherForgotPasswordPage(
          email: email.isNotEmpty ? email : null,
        );
      },
    ),
    GoRoute(
      path: '/reset-password',
      builder: (context, state) {
        final raw = state.extra;
        final extras = raw is Map ? Map<String, dynamic>.from(raw) : null;
        final email = extras?['email'] as String? ?? '';
        final resetToken = extras?['resetToken'] as String? ?? '';
        return NewPassword(email: email, resetToken: resetToken);
      },
    ),
    GoRoute(
      path: "/notification",
      pageBuilder: (context, state) => MaterialPage(
        child: BlocProvider(
          create: (context) => sl<NotificationBloc>(),
          child: NotificationScreen(),
        ),
      ),
    ),
  ];

  // ============================================
  // ROUTE NAMES (use these instead of building path strings)
  // ============================================
  // Booking flow is intentionally FLAT. Every step is a top-level route and
  // all data travels through `extra`, so navigation is a simple
  // `context.pushNamed(AppRoute.addIssue, extra: {...})` and the URLs stay short.
  static const String rCategoryPros = '/category-pros/:categoryName';
  static const String rWorkerDetail = '/worker/:workerName';
  static const String rCategoryDetail = '/category-detail';
  static const String rAddIssue = '/add-issue';
  static const String rMediaUpload = '/media-upload';
  static const String rAddress = '/address';
  static const String rAddNewAddress = '/address/add-new';
  static const String rAddAddressInformation = '/address/add-information';
  static const String rPayment = '/payment';
  static const String rBookingDetail = '/booking-detail';
  static const String rBookingTabDetail = '/booking-tab-detail';
  static const String rRateAndReview = '/rate-and-review';
  static const String rHelpCenter = '/help-center';
  static const String rEditProfile = '/edit-profile';


  // ============================================
  // DETAIL ROUTES (No Bottom Nav) - all flat, data passed via `extra`
  // ============================================
  static List<RouteBase> get _detailRoutes => [
    // Booking Detail Route
 

    // Category detail - REMOVED (now nested in Home tab)



    // Favorites Page
    GoRoute(
      path: '/favorites',
      name: 'favorites',
      builder: (context, state) => const FavoritesPage(),
    ),
      GoRoute(
      path: '/help-center',
      name: 'helpCenter',
      builder: (context, state) => const HelpCenterPage(),
    ),
         GoRoute(
      path: '/terms-policy',
      name: 'termsAndPolicy',
      builder: (context, state) {
        final section = state.extra as String? ?? 'privacy';
        return TermsAndPolicyPage(
          sections: _getSectionContent(section),
        );
      },
    ),

    // Address Page
    GoRoute(
      path: '/addresses',
      name: 'addresses',
      builder: (context, state) => const AddressPage(),
    ),

    // Edit Profile Page
    GoRoute(
      path: rEditProfile,
      name: 'editProfile',
      builder: (context, state) {
        final extras = state.extra as Map<String, dynamic>?;
        return EditProfilePage(
          initialName: extras?['name'] as String?,
          initialEmail: extras?['email'] as String?,
          initialPhone: extras?['phone'] as String?,
          initialAddress: extras?['address'] as String?,
        );
      },
    ),
  ];


  // ============================================
  // BOTTOM NAVIGATION SHELL
  // ============================================
  static StatefulShellRoute get _navigationShell =>
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppScaffoldWithNavbar(appNavigationShell: navigationShell);
        },
        branches: <StatefulShellBranch>[
          // Home Tab
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(path: '/home', builder: (context, state) => HomeScreen()),
            ],
          ),

          // Search Tab
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/search',
                builder: (context, state) => Container(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/ai-chat',
                builder: (context, state) => Container(),
                
              ),
            ],
          ),

          // Packages Tab
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/booking',
                builder: (context, state) => Container(),
              ),
            ],
          ),

          // Profile Tab
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      );

  // ============================================
  // POLICY SECTIONS
  // ============================================
  static List<PolicySection> _getSectionContent(String section) {
    switch (section.toLowerCase()) {
      case 'terms':
        return _termsOfServiceSections;
      case 'privacy':
      default:
        return _privacySections;
    }
  }

  static List<PolicySection> get _privacySections => [
    const PolicySection(
      title: 'Information We Collect',
      body: 'We collect information you provide directly, such as when you create an account, post content, or contact us. This may include your name, email address, phone number, profile information, and payment details.',
    ),
    const PolicySection(
      title: 'How We Use Your Information',
      body: 'We use the information we collect to provide, maintain, and improve our services, process transactions, send transactional communications, and personalize your experience on our platform.',
    ),
    const PolicySection(
      title: 'Information Sharing',
      body: 'We do not sell, trade, or share your personal information with third parties except as necessary to provide our services or as required by law. Service providers who assist us are bound by confidentiality agreements.',
    ),
    const PolicySection(
      title: 'Data Security',
      body: 'We implement appropriate technical and organizational measures to protect your personal information. However, no method of transmission over the internet is 100% secure.',
    ),
    const PolicySection(
      title: 'Your Rights',
      body: 'You have the right to access, correct, and delete your personal information. You can manage your account settings and communication preferences at any time.',
    ),
  ];

  static List<PolicySection> get _termsOfServiceSections => [
    const PolicySection(
      title: 'Acceptance of Terms',
      body: 'By accessing and using this platform, you accept and agree to be bound by the terms and provision of this agreement. If you do not agree to abide by the above, please do not use this service.',
    ),
    const PolicySection(
      title: 'Use License',
      body: 'Permission is granted to temporarily download one copy of the materials (information or software) on the platform for personal, non-commercial transitory viewing only. This is the grant of a license, not a transfer of title.',
    ),
    const PolicySection(
      title: 'Disclaimer',
      body: 'The materials on the platform are provided on an "as is" basis. We make no warranties, expressed or implied, and hereby disclaim and negate all other warranties including, without limitation, implied warranties or conditions of merchantability, fitness for a particular purpose.',
    ),
    const PolicySection(
      title: 'Limitations',
      body: 'In no event shall the platform or its suppliers be liable for any damages (including, without limitation, damages for loss of data or profit, or due to business interruption) arising out of the use or inability to use the materials.',
    ),
    const PolicySection(
      title: 'Accuracy of Materials',
      body: 'The materials appearing on the platform could include technical, typographical, or photographic errors. We do not warrant that any of the materials on the platform are accurate, complete, or current.',
    ),
  ];

  // ============================================
  // NAVIGATION HELPERS
  // ============================================
  static void navigateToHome() {
    try {
      debugPrint('🏠 Navigating to home: /home');
      router.go('/home');
    } catch (e) {
      debugPrint('❌ Error navigating to home: $e');
    }
  }

  static void dispose() {
    _router?.dispose();
    _router = null;
    _isInitialized = false;
  }

  static String get debugInfo =>
      '''
RouterManager Debug Info:
- Router Initialized: $_isInitialized
- Router Created: ${_router != null}
''';
}

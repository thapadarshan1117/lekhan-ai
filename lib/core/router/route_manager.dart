import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lekhan_ai/core/error/error_page.dart';
import 'package:lekhan_ai/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:lekhan_ai/features/auth/presentation/pages/login_page.dart';
import 'package:lekhan_ai/features/auth/presentation/pages/otp_verification_page.dart';
import 'package:lekhan_ai/features/auth/presentation/pages/signup_page.dart';
import 'package:lekhan_ai/features/auth/presentation/pages/new_password.dart';
import 'package:lekhan_ai/features/projects/domain/entities/project.dart';
import 'package:lekhan_ai/features/projects/presentation/pages/projects_page.dart';
import 'package:lekhan_ai/features/projects/presentation/pages/project_detail_page.dart';
import 'package:lekhan_ai/features/projects/presentation/pages/project_form_page.dart';
import 'package:lekhan_ai/features/books/presentation/pages/book_detail_page.dart';
import 'package:lekhan_ai/features/books/presentation/pages/book_form_page.dart';
import 'package:lekhan_ai/features/chapters/presentation/pages/chapter_detail_page.dart';
import 'package:lekhan_ai/features/chapters/presentation/pages/chapter_form_page.dart';
import 'package:lekhan_ai/features/source_content/domain/entities/chapter_source.dart';
import 'package:lekhan_ai/features/source_content/presentation/pages/image_viewer_page.dart';
import 'package:lekhan_ai/features/source_content/presentation/pages/audio_player_page.dart';
import 'package:lekhan_ai/features/source_content/presentation/pages/video_player_page.dart';
import 'package:lekhan_ai/features/source_content/presentation/pages/pdf_viewer_page.dart';
import 'package:lekhan_ai/features/source_content/presentation/pages/document_viewer_page.dart';
import 'package:lekhan_ai/features/sync/presentation/pages/sync_centre_page.dart';
import 'package:lekhan_ai/onboarding/presentation/screens/splash_screen.dart';

class RouterManager {
  static GoRouter? _router;
  static bool _isInitialized = false;

  static GoRouter get router {
    if (!_isInitialized) {
      debugPrint('🏗️ Initializing Standalone Application Router');
      _router = _createRouter();
      _isInitialized = true;
    }
    _router ??= _createRouter();
    return _router!;
  }

  /// Standalone Application Router
  /// No bottom navbar - linear navigation flow through projects → books → chapters
  static GoRouter _createRouter() {
    debugPrint('🏗️ Creating standalone app router');

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

        // Authentication Routes (pre-app)
        ..._authRoutes,

        // Main Application Routes (No Shell/Bottom Nav)
        // Linear navigation: Projects → Books → Chapters
        
        // Projects List (Main)
        GoRoute(
          path: '/projects',
          name: 'projects',
          builder: (context, state) => const ProjectsPage(),
        ),

        // Project Form (Create/Edit)
        GoRoute(
          path: '/projects/new',
          name: 'projectForm',
          builder: (context, state) {
            final initial = state.extra as Project?;
            return ProjectFormPage(initial: initial);
          },
        ),

        // Project Detail
        GoRoute(
          path: '/projects/:id',
          name: 'projectDetail',
          builder: (context, state) {
            final projectId = state.pathParameters['id']!;
            final initial = state.extra as Project?;
            return ProjectDetailPage(projectId: projectId, initial: initial);
          },
        ),

        // Book Detail
        GoRoute(
          path: '/books/:id',
          name: 'bookDetail',
          builder: (context, state) {
            final bookId = state.pathParameters['id']!;
            return BookDetailPage(bookId: bookId);
          },
        ),

        // Book Form (Create/Edit)
        GoRoute(
          path: '/books/new',
          name: 'bookForm',
          builder: (context, state) {
            final projectId = state.uri.queryParameters['projectId'] ?? '';
            return BookFormPage(projectId: projectId);
          },
        ),

        // Chapter Detail
        GoRoute(
          path: '/chapters/:id',
          name: 'chapterDetail',
          builder: (context, state) {
            final chapterId = state.pathParameters['id']!;
            return ChapterDetailPage(chapterId: chapterId);
          },
        ),

        // Chapter Form (Create/Edit)
        GoRoute(
          path: '/chapters/new',
          name: 'chapterForm',
          builder: (context, state) {
            final bookId = state.uri.queryParameters['bookId'];
            final number = int.tryParse(state.uri.queryParameters['number'] ?? '1') ?? 1;
            return ChapterFormPage(
              bookId: bookId ?? '',
              suggestedNumber: number,
            );
          },
        ),

        // Media Viewers
        GoRoute(
          path: '/viewer/image',
          name: 'imageViewer',
          builder: (context, state) {
            final source = state.extra as ChapterSource;
            return ImageViewerPage(source: source);
          },
        ),

        GoRoute(
          path: '/viewer/audio',
          name: 'audioPlayer',
          builder: (context, state) {
            final source = state.extra as ChapterSource;
            return AudioPlayerPage(source: source);
          },
        ),

        GoRoute(
          path: '/viewer/video',
          name: 'videoPlayer',
          builder: (context, state) {
            final source = state.extra as ChapterSource;
            return VideoPlayerPage(source: source);
          },
        ),

        GoRoute(
          path: '/viewer/pdf',
          name: 'pdfViewer',
          builder: (context, state) {
            final source = state.extra as ChapterSource;
            return PdfViewerPage(source: source);
          },
        ),

        GoRoute(
          path: '/viewer/document',
          name: 'documentViewer',
          builder: (context, state) {
            final source = state.extra as ChapterSource;
            return DocumentViewerPage(source: source);
          },
        ),

        // Sync Centre
        GoRoute(
          path: '/sync-centre',
          name: 'syncCentre',
          builder: (context, state) => const SyncCentrePage(),
        ),
      ],
    );
  }

  // ============================================
  // AUTHENTICATION ROUTES
  // ============================================
  static List<RouteBase> get _authRoutes => [
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => LoginPage(),
    ),
    GoRoute(
      path: '/signup',
      name: 'signup',
      builder: (context, state) => SignUpPage(),
    ),
    GoRoute(
      path: '/otp-verification',
      name: 'otpVerification',
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
      name: 'forgotPassword',
      builder: (context, state) {
        final email = state.extra as String? ?? '';
        return TeacherForgotPasswordPage(
          email: email.isNotEmpty ? email : null,
        );
      },
    ),
    GoRoute(
      path: '/reset-password',
      name: 'resetPassword',
      builder: (context, state) {
        final raw = state.extra;
        final extras = raw is Map ? Map<String, dynamic>.from(raw) : null;
        final email = extras?['email'] as String? ?? '';
        final resetToken = extras?['resetToken'] as String? ?? '';
        return NewPassword(email: email, resetToken: resetToken);
      },
    ),
  ];

  // ============================================
  // NAVIGATION HELPERS
  // ============================================
  
  /// Navigate to projects list (home)
  static void navigateToProjects() {
    try {
      debugPrint('📚 Navigating to projects');
      router.go('/projects');
    } catch (e) {
      debugPrint('❌ Error navigating to projects: $e');
    }
  }

  /// Navigate to book detail
  static void navigateToBook(String bookId) {
    try {
      debugPrint('📖 Navigating to book: $bookId');
      router.go('/books/$bookId');
    } catch (e) {
      debugPrint('❌ Error navigating to book: $e');
    }
  }

  /// Navigate to chapter detail
  static void navigateToChapter(String chapterId) {
    try {
      debugPrint('📄 Navigating to chapter: $chapterId');
      router.go('/chapters/$chapterId');
    } catch (e) {
      debugPrint('❌ Error navigating to chapter: $e');
    }
  }

  static void dispose() {
    _router?.dispose();
    _router = null;
    _isInitialized = false;
  }

  static String get debugInfo =>
      '''
RouterManager Debug Info (Standalone App):
- Router Initialized: $_isInitialized
- Router Created: ${_router != null}
- Navigation: Projects → Books → Chapters (Linear)
- No bottom navbar - full screen content
''';
}

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class TourAngSignInPage extends StatelessWidget {
  const TourAngSignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 10),

                Text(
                  'Yatri Fly',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: const Color(0xFFC84B4B),
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Explore the world at your own pace',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF9E9E9E),
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.2,
                  ),
                ),

                const SizedBox(height: 20),

                // Hero Section with Shapes and Content
                SizedBox(
                  height: 480,
                  child: Stack(
                    children: [
                      // Red blob with person image
                      Positioned(
                        left: 0,
                        top: 0,
                        child: Container(
                          width: 180,
                          height: 340,
                          decoration: BoxDecoration(
                            color: const Color(0xFFC84B4B),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(90),
                              topRight: Radius.circular(90),
                              bottomLeft: Radius.circular(90),
                              bottomRight: Radius.circular(20),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(90),
                              topRight: Radius.circular(90),
                              bottomLeft: Radius.circular(90),
                              bottomRight: Radius.circular(20),
                            ),
                            child: Stack(
                              children: [
                                // Background Gradient
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        const Color(
                                          0xFFC84B4B,
                                        ).withOpacity(0.3),
                                        const Color(
                                          0xFFC84B4B,
                                        ).withOpacity(0.1),
                                      ],
                                    ),
                                  ),
                                ),

                                // Full Image
                                Positioned.fill(
                                  child: Image.asset(
                                    'assets/images/guide.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Yellow/Peach circle - "Your Local Touring guide"
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFC977),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Your Local',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: const Color(0xFF2D2D2D),
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                  Text(
                                    'Touring',
                                    textAlign: TextAlign.center,

                                    style: Theme.of(context).textTheme.bodyLarge
                                        ?.copyWith(
                                          color: const Color(0xFF2D2D2D),
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                  Text(
                                    'guide',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.bodyLarge
                                        ?.copyWith(
                                          color: const Color(0xFF2D2D2D),
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Star decoration
                      Positioned(
                        right: 20,
                        top: 100,
                        child: Transform.rotate(
                          angle: 0.2,
                          child: Icon(
                            Icons.auto_awesome,
                            color: const Color(0xFFC84B4B),
                            size: 32,
                          ),
                        ),
                      ),

                      // Purple rounded rectangle with phone mockup
                      Positioned(
                        right: 20,
                        top: 180,
                        child: Container(
                          width: 200,
                          height: 260,
                          decoration: BoxDecoration(
                            color: const Color(0xFFB8A5E0),
                            borderRadius: BorderRadius.circular(130),
                          ),
                          child: Center(
                            child: Container(
                              width: 140,
                              height: 200,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Phone mockup header
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '9:41',
                                          style: GoogleFonts.outfit(
                                            fontSize: 8,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.signal_cellular_4_bar,
                                              size: 8,
                                            ),
                                            SizedBox(width: 2),
                                            Icon(Icons.wifi, size: 8),
                                            SizedBox(width: 2),
                                            Icon(Icons.battery_full, size: 8),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    // Placeholder content
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Top Image
                                          Container(
                                            height: 60,
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              image: const DecorationImage(
                                                image: AssetImage(
                                                  'assets/images/swimmin.jpg',
                                                ),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),

                                          const SizedBox(height: 6),

                                          Text(
                                            'Discover new places and hidden gems, all in one app.',
                                            style: GoogleFonts.outfit(
                                              fontSize: 6,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black,
                                              height: 1.3,
                                            ),
                                            maxLines: 2,
                                          ),

                                          const SizedBox(height: 4),

                                          // Bottom White Container with Same Image
                                          Container(
                                            height: 40,
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              image: const DecorationImage(
                                                image: AssetImage(
                                                  'assets/images/vacation.jpg',
                                                ),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),

                                          const SizedBox(height: 6),

                                          Container(
                                            height: 20,
                                            width: 80,
                                            decoration: BoxDecoration(
                                              color: Colors.black,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Center(
                                              child: Text(
                                                'Start Touring',
                                                style: GoogleFonts.outfit(
                                                  fontSize: 5,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // 10M+ Badge
                      Positioned(
                        left: 20,
                        bottom: 40,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(
                                '10M+',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      color: const Color(0xFF2D2D2D),
                                      fontWeight: FontWeight.w800,
                                      height: 1,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Guided Touring',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: const Color(0xFF2D2D2D),
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              Text(
                                'Destinations',
                                style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF2D2D2D),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Pink flower decoration
                      Positioned(
                        left: 140,
                        bottom: 20,
                        child: Icon(
                          Icons.local_florist,
                          color: const Color(0xFFFF9999),
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ),

                // Sign in with Phone Number Button
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () => context.go('/login'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC84B4B),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Sign in with Phone Number',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Sign in with Apple Button
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE8E8E8),
                      foregroundColor: const Color(0xFF2D2D2D),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.apple, size: 24),
                    label: Text(
                      'Sign in with Apple',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF2D2D2D),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Don't have an account? Sign Up
                RichText(
                  text: TextSpan(
                    text: "Don't have an account? ",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF9E9E9E),
                      fontWeight: FontWeight.w500,
                    ),
                    children: [
                      TextSpan(
                        text: 'Sign Up',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF2D2D2D),
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => context.push('/signup'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Terms and Privacy Policy
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text:
                        'By creating an account or signing in, you agree to\nour ',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: const Color(0xFF9E9E9E),
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                    ),
                    children: [
                      TextSpan(
                        text: 'Terms of Service',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2D2D2D),
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            // Handle terms navigation
                          },
                      ),
                      TextSpan(
                        text: ' and ',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF9E9E9E),
                        ),
                      ),
                      TextSpan(
                        text: 'Privacy Policy.',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2D2D2D),
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            // Handle privacy policy navigation
                          },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

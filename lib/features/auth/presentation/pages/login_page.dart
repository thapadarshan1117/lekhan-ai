import 'package:flutter/gestures.dart';
import 'package:lekhan_ai/core/utils/snack_bars.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lekhan_ai/core/widgets/input_field.dart';
import 'package:lekhan_ai/core/utils/validation_utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lekhan_ai/features/auth/presentation/bloc/auth_bloc/auth_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _rememberMe = false;

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        AuthEvent.login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        state.whenOrNull(
          success: (message, data) {
            SnackBars.showSuccessSnackBar(context, message);
            context.go('/home');
          },
          failure: (exception) {
            SnackBars.showErrorSnackBar(context, exception.message);
          },
        );
      },
      builder: (context, state) {
        final isLoading = state.maybeWhen(
          loading: () => true,
          orElse: () => false,
        );

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back button
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: IconButton(
                          onPressed: () => context.go('/'),
                          icon: const Icon(
                            Iconsax.arrow_left_2,
                            size: 20,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),

                      // Header Section
                      Center(
                        child: Column(
                          children: [
                            // Logo
                            SizedBox(
                              width: 200,
                              child: Image.asset(
                                'assets/icons/logo.png',
                                fit: BoxFit.scaleDown,
                              ),
                            ),

                            Text(
                              'घरमै सेवा, अब केही क्लिकमै।',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF0F172A),
                                  ),
                            ),

                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Email Field
                      Text(
                        'Email Address',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF0F172A),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InputField(
                        controller: _emailController,
                        hintText: 'Enter your email',
                        isPassword: false,
                        prefixIcon: Icon(
                          Iconsax.sms,
                          color: const Color(0xFF64748B),
                          size: 20,
                        ),
                        validator: ValidationUtils.validateEmail,
                        keyboardType: TextInputType.emailAddress,
                      ),

                      const SizedBox(height: 8),

                      // Password Field
                      Text(
                        'Password',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF0F172A),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InputField(
                        controller: _passwordController,
                        hintText: 'Enter your password',

                        isPassword: true,
                        isPasswordVisible: _isPasswordVisible,
                        onTogglePasswordVisibility: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                        prefixIcon: Icon(
                          Iconsax.lock,
                          color: const Color(0xFF64748B),
                          size: 20,
                        ),
                        // validator: ValidationUtils.validatePassword,
                      ),

                      const SizedBox(height: 8),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                height: 14,
                                width: 14,
                                child: Checkbox(
                                  value: _rememberMe,
                                  onChanged: (value) {
                                    setState(() {
                                      _rememberMe = value ?? false;
                                    });
                                  },
                                  activeColor: Theme.of(
                                    context,
                                  ).colorScheme.secondary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Remember me',
                                style: GoogleFonts.urbanist(
                                  fontSize: 14,
                                  color: const Color(0xFF64748B),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: () => context.push(
                              '/forgot-password',
                              extra: _emailController.text.trim(),
                            ),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Forgot Password?',
                              style: GoogleFonts.urbanist(
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.secondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.secondary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            disabledBackgroundColor: Theme.of(
                              context,
                            ).colorScheme.secondary.withValues(alpha: 0.6),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  'Sign In',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: const Color(0xFFE8E8E8),
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'OR',
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF9E9E9E),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: const Color(0xFFE8E8E8),
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // // Sign in with Apple Button
                      // SizedBox(
                      //   width: double.infinity,
                      //   height: 40,
                      //   child: ElevatedButton.icon(
                      //     onPressed: () {},
                      //     style: ElevatedButton.styleFrom(
                      //       backgroundColor: const Color(0xFFE8E8E8),
                      //       foregroundColor: const Color(0xFF2D2D2D),
                      //       elevation: 0,
                      //       shape: RoundedRectangleBorder(
                      //         borderRadius: BorderRadius.circular(12),
                      //       ),
                      //     ),
                      //     icon: const Icon(Icons.apple, size: 24),
                      //     label: Text(
                      //       'Sign in with Apple',
                      //       style: Theme.of(context).textTheme.bodyMedium
                      //           ?.copyWith(
                      //             color: const Color(0xFF2D2D2D),
                      //             fontWeight: FontWeight.w600,
                      //             letterSpacing: 0.2,
                      //           ),
                      //     ),
                      //   ),
                      // ),

                      const SizedBox(height: 14),

                      // Don't have an account? Sign Up
                      Center(
                        child: RichText(
                          text: TextSpan(
                            text: "Don't have an account? ",
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: const Color(0xFF9E9E9E),
                                  fontWeight: FontWeight.w500,
                                ),
                            children: [
                              TextSpan(
                                text: 'Sign Up',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: const Color(0xFF2D2D2D),
                                      fontWeight: FontWeight.w700,
                                      decoration: TextDecoration.underline,
                                    ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    context.go('/signup');
                                  },
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Terms and Privacy Policy
                      Center(
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            text: 'By signing in, you agree to our ',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
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
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

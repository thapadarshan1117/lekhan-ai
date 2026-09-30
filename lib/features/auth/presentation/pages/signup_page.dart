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

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _acceptTerms = false;

  void _handleSignUp() {
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptTerms) {
      SnackBars.showErrorSnackBar(
        context,
        'Please accept the Terms of Service and Privacy Policy',
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      SnackBars.showErrorSnackBar(context, 'Passwords do not match');
      return;
    }

    context.read<AuthBloc>().add(
          AuthEvent.register(
            fullName: _nameController.text.trim(),
            userType: 'CUSTOMER',
            email: _emailController.text.trim(),
            phone: _phoneController.text.trim(),
            password: _passwordController.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        state.whenOrNull(
          registerSuccess: (message, email, hash) {
            SnackBars.showSuccessSnackBar(context, message);
            context.push('/otp-verification', extra: {
              'email': email,
              'userData': {},
              'isForgot': false,
              'hash': hash,
            });
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
                            SizedBox(
                              width: 220,
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

                      // Full Name Field
                      Text(
                        'Full Name',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF0F172A),
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 8),
                      InputField(
                        controller: _nameController,
                        hintText: 'Enter your full name',
                        isPassword: false,
                        prefixIcon: const Icon(
                          Iconsax.user,
                          color: Color(0xFF64748B),
                          size: 20,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your name';
                          }
                          if (value.trim().length < 2) {
                            return 'Name must be at least 2 characters';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.name,
                      ),

                      const SizedBox(height: 8),

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
                        prefixIcon: const Icon(
                          Iconsax.sms,
                          color: Color(0xFF64748B),
                          size: 20,
                        ),
                        validator: ValidationUtils.validateEmail,
                        keyboardType: TextInputType.emailAddress,
                      ),

                      const SizedBox(height: 8),

                      // Phone Field
                      Text(
                        'Phone Number',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF0F172A),
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 8),
                      InputField(
                        controller: _phoneController,
                        hintText: 'Enter your phone number',
                        isPassword: false,
                        prefixIcon: const Icon(
                          Iconsax.call,
                          color: Color(0xFF64748B),
                          size: 20,
                        ),
                        validator: ValidationUtils.validatePhone,
                        keyboardType: TextInputType.phone,
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
                        prefixIcon: const Icon(
                          Iconsax.lock,
                          color: Color(0xFF64748B),
                          size: 20,
                        ),
                        validator: ValidationUtils.validatePassword,
                      ),

                      const SizedBox(height: 8),

                      // Confirm Password Field
                      Text(
                        'Confirm Password',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF0F172A),
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 8),
                      InputField(
                        controller: _confirmPasswordController,
                        hintText: 'Re-enter your password',
                        isPassword: true,
                        isPasswordVisible: _isConfirmPasswordVisible,
                        onTogglePasswordVisibility: () {
                          setState(() {
                            _isConfirmPasswordVisible =
                                !_isConfirmPasswordVisible;
                          });
                        },
                        prefixIcon: const Icon(
                          Iconsax.lock,
                          color: Color(0xFF64748B),
                          size: 20,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 8),

                      // Terms and Conditions Checkbox
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 14,
                            width: 14,
                            child: Checkbox(
                              value: _acceptTerms,
                              onChanged: (value) {
                                setState(() {
                                  _acceptTerms = value ?? false;
                                });
                              },
                              activeColor:
                                  Theme.of(context).colorScheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                text: 'I agree to the ',
                                style: GoogleFonts.urbanist(
                                  fontSize: 14,
                                  color: const Color(0xFF64748B),
                                  fontWeight: FontWeight.w500,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Terms of Service',
                                    style: GoogleFonts.urbanist(
                                      fontSize: 14,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary,
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {},
                                  ),
                                  TextSpan(
                                    text: ' and ',
                                    style: GoogleFonts.urbanist(
                                      fontSize: 14,
                                      color: const Color(0xFF64748B),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Privacy Policy',
                                    style: GoogleFonts.urbanist(
                                      fontSize: 14,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary,
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {},
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Sign Up Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _handleSignUp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.secondary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            disabledBackgroundColor: Theme.of(context)
                                .colorScheme
                                .secondary
                                .withValues(alpha: 0.6),
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
                                  'Sign Up',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Already have an account?
                      Center(
                        child: RichText(
                          text: TextSpan(
                            text: "Already have an account? ",
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: const Color(0xFF9E9E9E),
                                      fontWeight: FontWeight.w500,
                                    ),
                            children: [
                              TextSpan(
                                text: 'Sign In',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: const Color(0xFF2D2D2D),
                                      fontWeight: FontWeight.w700,
                                      decoration: TextDecoration.underline,
                                    ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    context.go('/login');
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
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}

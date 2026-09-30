import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:lekhan_ai/core/utils/snack_bars.dart';
import 'package:lekhan_ai/core/widgets/body_description_text.dart';
import 'package:lekhan_ai/core/widgets/input_field.dart';
import 'package:lekhan_ai/features/auth/presentation/bloc/auth_bloc/auth_bloc.dart';

class TeacherForgotPasswordPage extends StatefulWidget {
  const TeacherForgotPasswordPage({super.key, this.email});

  final String? email;

  @override
  State<TeacherForgotPasswordPage> createState() =>
      _TeacherForgotPasswordPageState();
}

class _TeacherForgotPasswordPageState extends State<TeacherForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.email ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        state.maybeWhen(
          orElse: () {},
          failure: (exception) =>
              SnackBars.showErrorSnackBar(context, exception.message),
          otpForgotResendSuccess: (rawMessage) {
            // format: "message|otpHash"
            final parts = rawMessage.split('|');
            final message = parts.first;
            final hash = parts.length > 1 ? parts.sublist(1).join('|') : '';
            SnackBars.showSuccessSnackBar(context, message);

            context.push(
              '/otp-verification',
              extra: {
                'email': _emailController.text,
                'userData': {},
                'isForgot': true,
                'hash': hash,
              },
            );
          },
        );
      },
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: IconButton(
                        onPressed: () => context.pop(),
                        icon: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.7),
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: theme.colorScheme.surface,
                          padding: const EdgeInsets.all(12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: theme.colorScheme.outline
                                  .withValues(alpha: 0.1),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Header section
                    Center(
                      child: Column(
                        children: [
                          Container(
                              height: 110,
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              child: Image.asset('assets/icons/logo.png')),
                          Text(
                            'घरमै सेवा, अब केही क्लिकमै।',
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Info card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.blue.shade200,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 20,
                            color: Colors.blue.shade600,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              'We\'ll send a verification code to your email address',
                              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Email field
                    BodyDescriptionText(
                      text: 'Email Address',
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),

                    const SizedBox(height: 14),
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary
                                .withValues(alpha: 0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: InputField(
                        controller: _emailController,
                        hintText: 'Enter your email address',
                        isPassword: false,
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color:
                              theme.colorScheme.primary.withValues(alpha: 0.7),
                          size: 20,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email address is required';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(value)) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Send code button
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        final isLoading = state.maybeWhen(
                          loading: () => true,
                          orElse: () => false,
                        );

                        return SizedBox(
                          width: double.infinity,
                          height: 45,
                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    if (_formKey.currentState!.validate()) {
                                      context.read<AuthBloc>().add(
                                            AuthEvent.forgotPassword(
                                              email: _emailController.text,
                                            ),
                                          );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.secondary,
                              foregroundColor: theme.colorScheme.onSecondary,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              disabledBackgroundColor: theme.colorScheme.secondary
                                  .withValues(alpha: 0.6),
                            ),
                            child: isLoading
                                ? SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: theme.colorScheme.onPrimary,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.email_outlined,
                                        size: 18,
                                        color: theme.colorScheme.onPrimary,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        'Send Verification Code',
                                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                          color: theme.colorScheme.onPrimary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // Back to login link
                    Center(
                      child: TextButton(
                        onPressed: () => context.go('/login'),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Remember your password? ',
                                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.7),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              TextSpan(
                                text: 'Sign In',
                                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
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
      ),
    );
  }
}
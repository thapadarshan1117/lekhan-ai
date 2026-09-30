import 'package:lekhan_ai/core/utils/snack_bars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:pinput/pinput.dart';
import 'dart:async';
import 'package:lekhan_ai/core/theme/app_color.dart';
import 'package:lekhan_ai/features/auth/presentation/bloc/auth_bloc/auth_bloc.dart';

class OTPVerificationPage extends StatefulWidget {
  final String email;
  final Map<String, dynamic> userData;

  /// Set to true when verifying a forgot-password OTP
  final bool isForgot;

  /// The otpHash returned from register / forgot-password response
  final String hash;

  const OTPVerificationPage({
    super.key,
    required this.email,
    required this.userData,
    this.isForgot = false,
    this.hash = '',
  });

  @override
  State<OTPVerificationPage> createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends State<OTPVerificationPage> {
  final _otpController = TextEditingController();
  final _focusNode = FocusNode();
  int _countdown = 60;
  Timer? _timer;
  String _enteredOTP = '';

  @override
  void initState() {
    super.initState();
    _startCountdown();
    _focusNode.requestFocus();
  }

  void _startCountdown() {
    _countdown = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_countdown == 0) {
        timer.cancel();
      } else {
        setState(() {
          _countdown--;
        });
      }
    });
  }

  void _verifyOTP() {
    if (_enteredOTP.length != 6) {
      SnackBars.showErrorSnackBar(
        context,
        'Please enter the complete 6-digit OTP',
      );
      return;
    }
    context.read<AuthBloc>().add(
      AuthEvent.verifyOtp(
        otp: _enteredOTP,
        email: widget.email,
        isForgot: widget.isForgot,
        hash: widget.hash,
      ),
    );
  }

  void _resendOTP() {
    context.read<AuthBloc>().add(
      AuthEvent.resendOtp(email: widget.email, isForgot: widget.isForgot),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final defaultPinTheme = PinTheme(
      width: 50,
      height: 50,
      textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF0F172A),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8ECF4)),
        color: Colors.white,
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
        border: Border.all(color: Theme.of(context).colorScheme.primary),
      ),
    );

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        state.whenOrNull(
          otpVerified: (message, isSetup, data) {
            if (widget.isForgot) {
              // Pass resetToken to reset-password page
              final resetToken = data?['resetToken'] as String? ?? '';
              SnackBars.showSuccessSnackBar(context, message);
              context.push(
                '/reset-password',
                extra: {'email': widget.email, 'resetToken': resetToken},
              );
            } else {
              SnackBars.showSuccessSnackBar(context, message);
              context.go('/login');
            }
          },
          otpVerifyFailed: (message) {
            SnackBars.showErrorSnackBar(context, message);
          },
          otpResendSuccess: (message) {
            SnackBars.showSuccessSnackBar(context, message);
            _startCountdown();
          },
          otpForgotResendSuccess: (message) {
            SnackBars.showSuccessSnackBar(context, message);
            _startCountdown();
          },
          otpResendFailure: (message) {
            SnackBars.showErrorSnackBar(context, message);
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: IconButton(
                        onPressed: () => context.pop(),
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
                          const SizedBox(height: 8),
                          SizedBox(
                            width: size.width * 0.85,
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: Theme.of(context).textTheme.bodyMedium!
                                    .copyWith(
                                      color: const Color(0xFF64748B),
                                      height: 1.5,
                                    ),
                                children: [
                                  const TextSpan(
                                    text:
                                        'We\'ve sent a 6-digit verification code to\n',
                                  ),
                                  TextSpan(
                                    text: widget.email,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(
                                          color: const Color(0xFF0F172A),
                                          fontWeight: FontWeight.w600,
                                          height: 1.5,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // OTP Input
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'Enter Verification Code',
                            style: Theme.of(context).textTheme.bodyMedium!
                                .copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF0F172A),
                                ),
                          ),
                          const SizedBox(height: 20),
                          Pinput(
                            controller: _otpController,
                            focusNode: _focusNode,
                            length: 6,
                            defaultPinTheme: defaultPinTheme,
                            focusedPinTheme: focusedPinTheme,
                            submittedPinTheme: submittedPinTheme,
                            showCursor: true,
                            onChanged: (value) {
                              setState(() {
                                _enteredOTP = value;
                              });
                            },
                            onCompleted: (pin) {
                              setState(() {
                                _enteredOTP = pin;
                              });
                              _verifyOTP();
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Verify Button
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: (isLoading || _enteredOTP.length != 6)
                            ? null
                            : _verifyOTP,
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
                                'Verify Code',
                                style: Theme.of(context).textTheme.bodySmall!
                                    .copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Resend Section
                    Center(
                      child: _countdown > 0
                          ? Text(
                              'Resend code in ${_countdown}s',
                              style: Theme.of(context).textTheme.bodyMedium!
                                  .copyWith(color: const Color(0xFF64748B)),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Didn't receive the code? ",
                                  style: Theme.of(context).textTheme.bodySmall!
                                      .copyWith(color: const Color(0xFF64748B)),
                                ),
                                TextButton(
                                  onPressed: _resendOTP,
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 0,
                                    ),
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    'Resend',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                    ),

                    const SizedBox(height: 40),

                    // Info Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Iconsax.info_circle,
                                size: 12,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Security Note',
                                style: Theme.of(context).textTheme.bodyMedium!
                                    .copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                          Text(
                            'For your security, this code will expire in 10 minutes. Please do not share this code with anyone.',
                            style: Theme.of(context).textTheme.labelSmall!
                                .copyWith(
                                  color: const Color(0xFF64748B),
                                  height: 1.4,
                                ),
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
      },
    );
  }

  @override
  void dispose() {
    _otpController.dispose();
    _focusNode.dispose();
    _timer?.cancel();
    super.dispose();
  }
}

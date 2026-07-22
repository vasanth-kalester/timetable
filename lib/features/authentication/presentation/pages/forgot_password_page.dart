import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  int _currentStep = 0; // 0 = identifier, 1 = OTP, 2 = New Password, 3 = Success
  final _identifierController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _identifierController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  void _nextStep() {
    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _currentStep++;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Password Recovery'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_currentStep == 0) ...[
                  const Text('Reset Password', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Enter your registered Email or College ID to receive a verification OTP.'),
                  const SizedBox(height: 24),
                  AppTextField(
                    label: 'Email / College ID',
                    hint: 'student@eduflow.campus',
                    controller: _identifierController,
                    prefixIcon: Icons.email_outlined,
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    label: 'Send Verification OTP',
                    onPressed: _nextStep,
                    isLoading: _isLoading,
                    isFullWidth: true,
                  ),
                ] else if (_currentStep == 1) ...[
                  const Text('Enter 6-Digit OTP', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('We sent a verification code to your registered device.'),
                  const SizedBox(height: 24),
                  AppTextField(
                    label: 'OTP Code',
                    hint: '123456',
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.pin_outlined,
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    label: 'Verify OTP',
                    onPressed: _nextStep,
                    isLoading: _isLoading,
                    isFullWidth: true,
                  ),
                ] else if (_currentStep == 2) ...[
                  const Text('Set New Password', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Choose a strong password containing at least 6 characters.'),
                  const SizedBox(height: 24),
                  AppTextField(
                    label: 'New Password',
                    hint: '••••••••',
                    controller: _newPasswordController,
                    obscureText: true,
                    prefixIcon: Icons.lock_outline,
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    label: 'Update Password',
                    onPressed: _nextStep,
                    isLoading: _isLoading,
                    isFullWidth: true,
                  ),
                ] else ...[
                  const Center(
                    child: Column(
                      children: [
                        Icon(Icons.check_circle_rounded, size: 64, color: Colors.greenAccent),
                        SizedBox(height: 16),
                        Text('Password Reset Successful!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text('Your session has been updated. Please login with your new password.'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    label: 'Back to Sign In',
                    onPressed: () => context.go('/login'),
                    isFullWidth: true,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

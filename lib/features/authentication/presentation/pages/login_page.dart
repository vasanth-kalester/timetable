import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../application/providers/auth_provider.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _identifierController = TextEditingController(text: 'student@eduflow.campus');
  final _passwordController = TextEditingController(text: 'pass1234');
  bool _obscurePassword = true;
  bool _rememberMe = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin([String? presetIdentifier]) async {
    final identifier = presetIdentifier ?? _identifierController.text.trim();
    final password = _passwordController.text;

    if (identifier.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter identification and password.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final success = await ref.read(authProvider.notifier).login(identifier, password);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      if (success) {
        context.go('/dashboard');
      } else {
        final authState = ref.read(authProvider);
        if (authState is AuthError) {
          setState(() {
            _errorMessage = authState.message;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo & Header
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.hub_rounded, color: Colors.white, size: 36),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Sign In to EduFlow',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Enter Email, Employee ID, or Student Roll No',
                        style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                if (_errorMessage != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade900.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Input Fields
                AppTextField(
                  label: 'Email / Employee ID / Roll Number',
                  hint: 'e.g. 21CS089 or emp@eduflow.campus',
                  controller: _identifierController,
                  prefixIcon: Icons.badge_outlined,
                ),
                const SizedBox(height: 16),

                AppTextField(
                  label: 'Password',
                  hint: '••••••••',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  prefixIcon: Icons.lock_outline_rounded,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 12),

                // Remember Me & Forgot Password Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          onChanged: (val) {
                            setState(() {
                              _rememberMe = val ?? true;
                            });
                          },
                        ),
                        const Text('Remember Me', style: TextStyle(fontSize: 13)),
                      ],
                    ),
                    TextButton(
                      onPressed: () => context.push('/forgot-password'),
                      child: const Text('Forgot Password?', style: TextStyle(fontSize: 13)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Submit Button
                AppButton(
                  label: 'Sign In',
                  onPressed: () => _handleLogin(),
                  isLoading: _isLoading,
                  isFullWidth: true,
                ),
                const SizedBox(height: 28),

                // Quick Demo Preset Roles Section
                const Divider(),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    'QUICK DEMO ROLES SIGN-IN',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    ActionChip(
                      avatar: const Icon(Icons.person_outline, size: 16),
                      label: const Text('Student'),
                      onPressed: () => _handleLogin('21cs089@student.campus'),
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.school_outlined, size: 16),
                      label: const Text('Faculty'),
                      onPressed: () => _handleLogin('faculty@eduflow.campus'),
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.manage_accounts_outlined, size: 16),
                      label: const Text('HOD'),
                      onPressed: () => _handleLogin('hod@eduflow.campus'),
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.star_outline, size: 16),
                      label: const Text('Principal'),
                      onPressed: () => _handleLogin('principal@eduflow.campus'),
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.admin_panel_settings_outlined, size: 16),
                      label: const Text('Admin'),
                      onPressed: () => _handleLogin('admin@eduflow.campus'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

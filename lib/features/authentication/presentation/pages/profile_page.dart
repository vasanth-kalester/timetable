import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../application/providers/auth_provider.dart';
import '../widgets/digital_id_card_widget.dart';
import '../../../../core/widgets/app_button.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = ref.watch(authProvider.notifier).currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('No user logged in.')),
      );
    }

    final permissions = [
      'view_timetable',
      'view_attendance',
      'take_attendance',
      'dept_management',
      'campus_dashboard',
      'generate_reports',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Identity & Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shield_outlined),
            tooltip: 'Security Settings',
            onPressed: () => context.push('/security-settings'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Digital Campus ID Card Component
            DigitalIdCardWidget(user: user),
            const SizedBox(height: 28),

            // Personal Credentials Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Account Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildInfoRow(context, Icons.email_outlined, 'Email Address', user.email),
                    const Divider(height: 24),
                    _buildInfoRow(context, Icons.business_rounded, 'Department', user.department),
                    const Divider(height: 24),
                    _buildInfoRow(context, Icons.phone_outlined, 'Phone', user.phone ?? '+1 (555) 019-2834'),
                    const Divider(height: 24),
                    _buildInfoRow(context, Icons.badge_outlined, 'System Role', user.role.name.toUpperCase()),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // RBAC Permissions Checklist
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Role Permissions Matrix', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: permissions.map((pKey) {
                        final allowed = user.hasPermission(pKey);
                        return Chip(
                          avatar: Icon(
                            allowed ? Icons.check_circle_rounded : Icons.cancel_rounded,
                            size: 16,
                            color: allowed ? Colors.greenAccent : Colors.redAccent,
                          ),
                          label: Text(pKey, style: const TextStyle(fontSize: 12)),
                          backgroundColor: allowed
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Logout Action
            AppButton(
              label: 'Sign Out of EduFlow',
              variant: AppButtonVariant.danger,
              icon: Icons.logout_rounded,
              isFullWidth: true,
              onPressed: () async {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) {
                  context.go('/login');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }
}

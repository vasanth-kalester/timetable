import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../features/authentication/application/providers/auth_provider.dart';
import '../../../../features/validation/presentation/widgets/scheduling_readiness_center.dart';
class PrincipalDashboardPage extends ConsumerWidget {
  const PrincipalDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider.notifier).currentUser;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.hub_rounded, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          const Text('EduFlow OS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ]),
        actions: [
          IconButton(icon: const Icon(Icons.person_outline), onPressed: () => context.push('/profile')),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Welcome Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.colorScheme.primary, theme.colorScheme.primary.withOpacity(0.7)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Welcome, ${user?.fullName ?? 'Principal'} 👋',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 4),
              Text('Principal · SSMIET', style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 14)),
              const SizedBox(height: 12),
              Text('You have full institutional access.', style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 13)),
            ]),
          ),
          ),
          const SizedBox(height: 24),
          
          // Scheduling Readiness Center (Phase 5)
          const SchedulingReadinessCenter(),
          const SizedBox(height: 24),

          // Stats overview
          const Text('Institution Readiness', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: const [
              _StatCard(label: 'Academic Year', value: 'Ready', icon: Icons.calendar_today, color: Colors.green),
              _StatCard(label: 'Depts Ready', value: '12/12', icon: Icons.domain, color: Colors.blue),
              _StatCard(label: 'Validation', value: '98%', icon: Icons.check_circle, color: Colors.purple),
              _StatCard(label: 'Pending', value: '2', icon: Icons.pending_actions, color: Colors.orange),
            ],
          ),
          const SizedBox(height: 24),

          // Quick actions
          const Text('Quick Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10, runSpacing: 10,
            children: [
              _ActionChip(label: 'Institution Settings', icon: Icons.settings_rounded, onTap: () => context.push('/institution-settings')),
              _ActionChip(label: 'Academic Structure', icon: Icons.account_tree_rounded, onTap: () => context.push('/academic-structure')),
              _ActionChip(label: 'Infrastructure', icon: Icons.business_rounded, onTap: () => context.push('/infrastructure')),
              _ActionChip(label: 'Faculty', icon: Icons.people_rounded, onTap: () => context.push('/faculty')),
              _ActionChip(label: 'Timetable', icon: Icons.calendar_month_rounded, onTap: () {}),
              _ActionChip(label: 'Staff Approvals', icon: Icons.how_to_reg_rounded, onTap: () {}),
              _ActionChip(label: 'Analytics', icon: Icons.bar_chart_rounded, onTap: () {}),
              _ActionChip(label: 'My Profile', icon: Icons.person_outline, onTap: () => context.push('/profile')),
            ],
          ),
        ]),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color, size: 24),
        const Spacer(),
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: TextStyle(fontSize: 12, color: color.withOpacity(0.8))),
      ]),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _ActionChip({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 13, color: theme.colorScheme.primary, fontWeight: FontWeight.w500)),
        ]),
      ),
    );
  }
}

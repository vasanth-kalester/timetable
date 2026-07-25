import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../features/authentication/application/providers/auth_provider.dart';

class FacultyDashboardPage extends ConsumerWidget {
  const FacultyDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider.notifier).currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: const Color(0xFF0EA5E9), borderRadius: BorderRadius.circular(8)),
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF0284C7), Color(0xFF0EA5E9)]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Hello, ${user?.fullName ?? 'Faculty'} 👋',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 4),
              const Text('Faculty Member', style: TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 12),
              const Text('View your timetable and assigned subjects below.',
                  style: TextStyle(color: Colors.white60, fontSize: 13)),
            ]),
          ),
          const SizedBox(height: 24),

          const Text('My Overview', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.4,
            children: const [
              _StatCard(label: 'Subjects', value: '3', icon: Icons.book_rounded, color: Color(0xFF0EA5E9)),
              _StatCard(label: 'Hours/Week', value: '18', icon: Icons.access_time_rounded, color: Color(0xFF6366F1)),
              _StatCard(label: 'Classes', value: '5', icon: Icons.group_rounded, color: Color(0xFF10B981)),
              _StatCard(label: 'Leave Balance', value: '12', icon: Icons.beach_access_rounded, color: Color(0xFFF59E0B)),
            ],
          ),
          const SizedBox(height: 24),

          const Text('Quick Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(spacing: 10, runSpacing: 10, children: [
            _ActionChip(label: 'My Timetable', icon: Icons.calendar_today_rounded, color: const Color(0xFF0EA5E9), onTap: () {}),
            _ActionChip(label: 'Take Attendance', icon: Icons.how_to_reg_rounded, color: const Color(0xFF10B981), onTap: () {}),
            _ActionChip(label: 'Apply Leave', icon: Icons.beach_access_rounded, color: const Color(0xFFF59E0B), onTap: () {}),
            _ActionChip(label: 'My Profile', icon: Icons.person_outline, color: const Color(0xFF6366F1), onTap: () => context.push('/profile')),
          ]),
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
  Widget build(BuildContext context) => Container(
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

class _ActionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionChip({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(30),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w500)),
      ]),
    ),
  );
}

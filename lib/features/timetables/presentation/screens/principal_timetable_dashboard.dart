import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'class_subjects_screen.dart';

class PrincipalTimetableDashboard extends ConsumerWidget {
  const PrincipalTimetableDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Mock data
    final optimizationScore = 96.0;
    final conflicts = 0;
    final roomUtilization = 91.0;
    final facultySatisfaction = 94.0;
    final studentSatisfaction = 96.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Institution Timetable Dashboard'),
        actions: [
          FilledButton.tonalIcon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ClassSubjectsScreen()),
              );
            },
            icon: const Icon(Icons.book),
            label: const Text('Class Subjects'),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.publish),
            label: const Text('Publish Timetable'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Academic Year 2026-2027',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Status: Draft (Pending Approval)',
                      style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: Colors.green),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Overall Optimization Score', style: TextStyle(fontSize: 12, color: Colors.green)),
                          Text('${optimizationScore.toInt()}%', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Key Metrics
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildMetricCard('Conflicts', '$conflicts', Icons.warning_amber_rounded, conflicts == 0 ? Colors.green : Colors.red, theme),
                _buildMetricCard('Room Utilization', '${roomUtilization.toInt()}%', Icons.meeting_room, Colors.blue, theme),
                _buildMetricCard('Faculty Satisfaction', '${facultySatisfaction.toInt()}%', Icons.person, Colors.purple, theme),
                _buildMetricCard('Student Satisfaction', '${studentSatisfaction.toInt()}%', Icons.groups, Colors.orange, theme),
              ],
            ),
            
            const SizedBox(height: 40),
            
            // Department Progress
            const Text(
              'Department Generation Status',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
              child: ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildDepartmentRow('Computer Science and Engineering', 'Generated', 98, 0, theme),
                  const Divider(height: 1),
                  _buildDepartmentRow('Information Technology', 'Generated', 95, 0, theme),
                  const Divider(height: 1),
                  _buildDepartmentRow('Artificial Intelligence', 'Generated', 97, 0, theme),
                  const Divider(height: 1),
                  _buildDepartmentRow('Mechanical Engineering', 'Generated', 92, 0, theme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color, ThemeData theme) {
    return Card(
      elevation: 0,
      color: color.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDepartmentRow(String name, String status, int score, int conflicts, ThemeData theme) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text('Status: $status'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Score: $score%', style: TextStyle(color: score > 90 ? Colors.green : Colors.orange, fontWeight: FontWeight.bold)),
              Text('Conflicts: $conflicts', style: TextStyle(color: conflicts == 0 ? Colors.green : Colors.red, fontSize: 12)),
            ],
          ),
          const SizedBox(width: 16),
          FilledButton.tonal(
            onPressed: () {},
            child: const Text('View'),
          ),
        ],
      ),
    );
  }
}

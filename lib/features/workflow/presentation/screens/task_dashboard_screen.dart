import 'package:flutter/material.dart';

class TaskDashboardScreen extends StatelessWidget {
  const TaskDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final tasks = [
      {
        'title': 'Upload Internal Marks',
        'description': 'Upload marks for CS301 Mid-Term.',
        'dueDate': 'Oct 15, 2026',
        'priority': 'High',
        'status': 'pending',
      },
      {
        'title': 'Verify Timetable',
        'description': 'Review the draft timetable for Even Semester.',
        'dueDate': 'Oct 20, 2026',
        'priority': 'Medium',
        'status': 'in_progress',
      },
      {
        'title': 'Assign Lab Coordinator',
        'description': 'Assign a coordinator for the new AI Lab.',
        'dueDate': 'Oct 10, 2026',
        'priority': 'Low',
        'status': 'completed',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Dashboard'),
        actions: [
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add),
            label: const Text('New Task'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: tasks.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final task = tasks[index];
          return _buildTaskCard(task, theme);
        },
      ),
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task, ThemeData theme) {
    final status = task['status'] as String;
    final priority = task['priority'] as String;
    
    Color priorityColor;
    switch (priority) {
      case 'High': priorityColor = Colors.red; break;
      case 'Medium': priorityColor = Colors.orange; break;
      default: priorityColor = Colors.green;
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      status == 'completed' ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: status == 'completed' ? Colors.green : theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      task['title'] as String,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        decoration: status == 'completed' ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: priorityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    priority,
                    style: TextStyle(color: priorityColor, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(left: 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task['description'] as String,
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 8),
                      Text(
                        'Due: ${task['dueDate']}',
                        style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

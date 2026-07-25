import 'package:flutter/material.dart';

class TimetableVersionHistoryScreen extends StatelessWidget {
  const TimetableVersionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Mock versions
    final versions = [
      {
        'version': 4,
        'date': 'Oct 14, 2026 09:30 AM',
        'author': 'Principal Sharma',
        'reason': 'Room Maintenance (Lab 3)',
        'isActive': true,
        'changes': 2,
      },
      {
        'version': 3,
        'date': 'Oct 12, 2026 08:15 AM',
        'author': 'HOD Computer Science',
        'reason': 'Faculty Leave (Dr. Ravi)',
        'isActive': false,
        'changes': 3,
      },
      {
        'version': 2,
        'date': 'Oct 10, 2026 11:00 AM',
        'author': 'Principal Sharma',
        'reason': 'Guest Lecture (AI)',
        'isActive': false,
        'changes': 4,
      },
      {
        'version': 1,
        'date': 'Oct 01, 2026 10:00 AM',
        'author': 'System',
        'reason': 'Initial Publication',
        'isActive': false,
        'changes': 0,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Timetable Version History'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Version Control',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'View previous versions of the timetable and rollback if necessary.',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 32),
            
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: versions.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final version = versions[index];
                return _buildVersionCard(version, theme);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVersionCard(Map<String, dynamic> version, ThemeData theme) {
    final isActive = version['isActive'] as bool;
    
    return Card(
      elevation: isActive ? 4 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isActive ? theme.colorScheme.primary : theme.colorScheme.outlineVariant,
          width: isActive ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Version Badge
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: isActive ? theme.colorScheme.primary : theme.colorScheme.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  'v${version['version']}',
                  style: TextStyle(
                    color: isActive ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 24),
            
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        version['reason'] as String,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      if (isActive) ...[
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Active',
                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 14, color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                        version['date'] as String,
                        style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.person, size: 14, color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                        version['author'] as String,
                        style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13),
                      ),
                    ],
                  ),
                  if (version['changes'] > 0) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.history, size: 14, color: theme.colorScheme.primary),
                        const SizedBox(width: 4),
                        Text(
                          '${version['changes']} changes from previous version',
                          style: TextStyle(color: theme.colorScheme.primary, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            
            // Action
            if (!isActive)
              FilledButton.tonalIcon(
                onPressed: () {},
                icon: const Icon(Icons.restore),
                label: const Text('Rollback to this version'),
              ),
          ],
        ),
      ),
    );
  }
}

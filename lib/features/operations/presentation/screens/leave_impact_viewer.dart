import 'package:flutter/material.dart';

class LeaveImpactViewer extends StatelessWidget {
  final String facultyName;
  final String date;

  const LeaveImpactViewer({
    super.key,
    required this.facultyName,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Mock data
    final affectedSessions = [
      {'code': 'CS301-T1', 'name': 'Operating Systems', 'period': 2, 'room': 'Room 101', 'section': 'CSE-A'},
      {'code': 'CS301-T2', 'name': 'Operating Systems', 'period': 4, 'room': 'Room 102', 'section': 'CSE-B'},
      {'code': 'CS305-L1', 'name': 'OS Lab', 'period': '5-7', 'room': 'Lab 1', 'section': 'CSE-A'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave Impact Analysis'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Icon(Icons.person, size: 32, color: theme.colorScheme.onPrimaryContainer),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      facultyName,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Requested Leave: $date',
                      style: TextStyle(color: theme.colorScheme.error, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 40),
            
            // Impact Summary
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Affected Classes',
                    '${affectedSessions.length}',
                    Icons.class_,
                    Colors.orange,
                    theme,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryCard(
                    'Affected Students',
                    '~180',
                    Icons.groups,
                    Colors.blue,
                    theme,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryCard(
                    'Freed Rooms',
                    '3',
                    Icons.meeting_room,
                    Colors.green,
                    theme,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 40),
            
            const Text(
              'Sessions Requiring Substitutes',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: affectedSessions.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final session = affectedSessions[index];
                  return _buildSessionItem(session, theme);
                },
              ),
            ),
            
            const SizedBox(height: 40),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {},
                  child: const Text('Reject Leave'),
                ),
                const SizedBox(width: 16),
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.check),
                  label: const Text('Approve & Find Substitutes'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color, ThemeData theme) {
    return Card(
      elevation: 0,
      color: color.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 16),
            Text(
              value,
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionItem(Map<String, dynamic> session, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  'Period',
                  style: TextStyle(fontSize: 12, color: theme.colorScheme.onPrimaryContainer),
                ),
                Text(
                  '${session['period']}',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimaryContainer),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${session['code']} - ${session['name']}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.meeting_room, size: 16, color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(session['room'], style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                    const SizedBox(width: 16),
                    Icon(Icons.groups, size: 16, color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(session['section'], style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
              ],
            ),
          ),
          FilledButton.tonal(
            onPressed: () {},
            child: const Text('Find Substitute'),
          ),
        ],
      ),
    );
  }
}

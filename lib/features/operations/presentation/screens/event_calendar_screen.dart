import 'package:flutter/material.dart';

class EventCalendarScreen extends StatelessWidget {
  const EventCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Mock events
    final events = [
      {
        'title': 'AI Guest Lecture',
        'type': 'Guest Lecture',
        'date': 'Oct 15, 2026',
        'time': 'Period 3-4',
        'room': 'Seminar Hall',
        'department': 'Computer Science',
        'impact': 4,
      },
      {
        'title': 'Mid-Term Exams',
        'type': 'Internal Exam',
        'date': 'Oct 20-25, 2026',
        'time': 'All Periods',
        'room': 'All Classrooms',
        'department': 'All',
        'impact': 142,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Calendar'),
        actions: [
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add),
            label: const Text('Schedule Event'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Upcoming Events',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Manage special events and analyze their impact on the regular timetable.',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 32),
            
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: events.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final event = events[index];
                return _buildEventCard(event, theme);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event, ThemeData theme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(Icons.event, color: theme.colorScheme.onPrimaryContainer),
                  const SizedBox(height: 8),
                  Text(
                    event['date'].toString().split(',')[0], // Just show Month Day
                    style: TextStyle(color: theme.colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ],
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
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          event['type'] as String,
                          style: TextStyle(color: theme.colorScheme.onSecondaryContainer, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        event['title'] as String,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 16, color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(event['time'] as String, style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                      const SizedBox(width: 16),
                      Icon(Icons.meeting_room, size: 16, color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(event['room'] as String, style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                      const SizedBox(width: 16),
                      Icon(Icons.business, size: 16, color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(event['department'] as String, style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ],
              ),
            ),
            
            // Impact
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  const Text('Impacted Sessions', style: TextStyle(color: Colors.orange, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(
                    '${event['impact']}',
                    style: const TextStyle(color: Colors.orange, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 16),
            Column(
              children: [
                FilledButton.tonal(
                  onPressed: () {},
                  child: const Text('View Impact'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {},
                  child: const Text('Edit'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class AnnouncementFeedScreen extends StatelessWidget {
  const AnnouncementFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final announcements = [
      {
        'title': 'Internal Exam Schedule Released',
        'content': 'The schedule for the upcoming internal exams has been published. Please check the academic calendar for details.',
        'author': 'Principal Office',
        'date': 'Oct 12, 2026',
        'target': 'Institution',
      },
      {
        'title': 'Guest Lecture on AI',
        'content': 'There will be a guest lecture on Artificial Intelligence by Dr. Smith on Friday at 2 PM in the Main Auditorium.',
        'author': 'HOD - Computer Science',
        'date': 'Oct 10, 2026',
        'target': 'CS Department',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Announcements'),
        actions: [
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add),
            label: const Text('New Announcement'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: announcements.length,
        separatorBuilder: (context, index) => const SizedBox(height: 24),
        itemBuilder: (context, index) {
          final announcement = announcements[index];
          return _buildAnnouncementCard(announcement, theme);
        },
      ),
    );
  }

  Widget _buildAnnouncementCard(Map<String, dynamic> announcement, ThemeData theme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    announcement['target'] as String,
                    style: TextStyle(color: theme.colorScheme.primary, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  announcement['date'] as String,
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              announcement['title'] as String,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              announcement['content'] as String,
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant, height: 1.5),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: theme.colorScheme.secondaryContainer,
                  child: Icon(Icons.person, size: 16, color: theme.colorScheme.onSecondaryContainer),
                ),
                const SizedBox(width: 8),
                Text(
                  announcement['author'] as String,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

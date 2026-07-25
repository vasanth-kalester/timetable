import 'package:flutter/material.dart';

class ApprovalInboxScreen extends StatelessWidget {
  const ApprovalInboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final approvals = [
      {
        'id': 'REQ-001',
        'type': 'Faculty Leave',
        'requester': 'Dr. Sharma',
        'details': 'Medical Leave for 3 days (Oct 15 - Oct 17)',
        'status': 'pending',
        'date': 'Oct 10, 2026',
      },
      {
        'id': 'REQ-002',
        'type': 'Room Change',
        'requester': 'Dr. Gupta',
        'details': 'Move CS301 from Room 101 to Room 105 for Period 3',
        'status': 'pending',
        'date': 'Oct 11, 2026',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Approval Inbox'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: approvals.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final approval = approvals[index];
          return _buildApprovalCard(approval, theme);
        },
      ),
    );
  }

  Widget _buildApprovalCard(Map<String, dynamic> approval, ThemeData theme) {
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    approval['type'] as String,
                    style: TextStyle(color: theme.colorScheme.primary, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  approval['date'] as String,
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: theme.colorScheme.secondaryContainer,
                  child: Icon(Icons.person, color: theme.colorScheme.onSecondaryContainer),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        approval['requester'] as String,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        approval['details'] as String,
                        style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.close),
                  label: const Text('Reject'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
                const SizedBox(width: 16),
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.check),
                  label: const Text('Approve'),
                  style: FilledButton.styleFrom(backgroundColor: Colors.green),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

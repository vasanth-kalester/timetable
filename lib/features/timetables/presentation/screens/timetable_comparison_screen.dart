import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TimetableComparisonScreen extends ConsumerWidget {
  const TimetableComparisonScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Mock data
    final currentScore = 92.0;
    final newScore = 96.0;
    final scoreDiff = newScore - currentScore;

    final changes = [
      {
        'session': 'CS301-T1 (Operating Systems)',
        'old': 'Monday, Period 2, Room 101',
        'new': 'Wednesday, Period 4, Room 102',
        'reason': 'Resolved Faculty Conflict with CS302-T2',
        'type': 'moved',
      },
      {
        'session': 'CS305-L1 (OS Lab)',
        'old': 'Unscheduled (Conflict)',
        'new': 'Friday, Period 5-7, Lab 1',
        'reason': 'Found valid slot after backtracking',
        'type': 'added',
      },
      {
        'session': 'MA201-T1 (Mathematics)',
        'old': 'Tuesday, Period 1, Room 201',
        'new': 'Tuesday, Period 2, Room 201',
        'reason': 'Local Optimization: Avoid First Hour penalty reduced',
        'type': 'optimized',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Timetable Comparison'),
        actions: [
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.check),
            label: const Text('Accept New Version'),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () {},
            child: const Text('Discard'),
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
              'Regeneration Results',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Review the changes before applying the new timetable version.',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 32),
            
            // Score Comparison
            Row(
              children: [
                Expanded(
                  child: _buildScoreCard('Current Version (v1.2)', currentScore, theme),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Icon(Icons.arrow_forward, size: 32, color: Colors.grey),
                ),
                Expanded(
                  child: _buildScoreCard(
                    'New Version (Draft)', 
                    newScore, 
                    theme, 
                    diff: scoreDiff,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 40),
            
            // Changes List
            Row(
              children: [
                const Text(
                  'Detailed Changes',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${changes.length} Sessions Affected',
                    style: TextStyle(color: theme.colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
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
                itemCount: changes.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final change = changes[index];
                  return _buildChangeItem(change, theme);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCard(String title, double score, ThemeData theme, {double? diff}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(title, style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${score.toInt()}%', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
                if (diff != null) ...[
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: diff > 0 ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(diff > 0 ? Icons.arrow_upward : Icons.arrow_downward, size: 16, color: diff > 0 ? Colors.green : Colors.red),
                        const SizedBox(width: 4),
                        Text('${diff.abs().toInt()}%', style: TextStyle(color: diff > 0 ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChangeItem(Map<String, String> change, ThemeData theme) {
    IconData icon;
    Color color;
    
    switch (change['type']) {
      case 'added':
        icon = Icons.add_circle;
        color = Colors.green;
        break;
      case 'moved':
        icon = Icons.swap_horiz;
        color = Colors.blue;
        break;
      case 'optimized':
        icon = Icons.auto_awesome;
        color = Colors.purple;
        break;
      default:
        icon = Icons.info;
        color = Colors.grey;
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(change['session']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(change['old']!, style: TextStyle(color: theme.colorScheme.onSurfaceVariant, decoration: TextDecoration.lineThrough)),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(Icons.arrow_forward, color: Colors.grey),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: color.withOpacity(0.3)),
                        ),
                        child: Text(change['new']!, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.info_outline, size: 14, color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(change['reason']!, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant, fontStyle: FontStyle.italic)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

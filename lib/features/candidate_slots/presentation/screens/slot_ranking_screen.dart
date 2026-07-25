import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SlotRankingScreen extends ConsumerWidget {
  final String sessionId;
  
  const SlotRankingScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Mock data for ranked slots
    final sessionCode = 'CS301-T1';
    final rankedSlots = [
      {
        'rank': 1,
        'day': 'Wednesday',
        'period': 4,
        'room': 'Room 101',
        'penalty': 0,
        'satisfied': ['Faculty Conflict', 'Classroom Conflict', 'Working Day', 'Period Validity', 'Preferred Day Off', 'Avoid First Hour'],
        'violated': [],
      },
      {
        'rank': 2,
        'day': 'Tuesday',
        'period': 3,
        'room': 'Room 102',
        'penalty': 5,
        'satisfied': ['Faculty Conflict', 'Classroom Conflict', 'Working Day', 'Period Validity', 'Preferred Day Off'],
        'violated': [{'name': 'Avoid First Hour', 'penalty': 5}],
      },
      {
        'rank': 3,
        'day': 'Monday',
        'period': 2,
        'room': 'Room 101',
        'penalty': 10,
        'satisfied': ['Faculty Conflict', 'Classroom Conflict', 'Working Day', 'Period Validity', 'Avoid First Hour'],
        'violated': [{'name': 'Spread Workload', 'penalty': 10}],
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Slot Rankings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ranked Candidates: $sessionCode',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Showing the best available slots based on penalty scores.',
                      style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${rankedSlots.length} Valid Options',
                    style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Rankings List
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: rankedSlots.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final slot = rankedSlots[index];
                final isTopRank = slot['rank'] == 1;
                
                return Card(
                  elevation: isTopRank ? 4 : 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isTopRank ? theme.colorScheme.primary : theme.colorScheme.outlineVariant,
                      width: isTopRank ? 2 : 1,
                    ),
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
                                CircleAvatar(
                                  backgroundColor: isTopRank ? theme.colorScheme.primary : theme.colorScheme.surfaceVariant,
                                  foregroundColor: isTopRank ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant,
                                  radius: 16,
                                  child: Text('${slot['rank']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  '${slot['day']}, Period ${slot['period']}',
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surface,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: theme.colorScheme.outlineVariant),
                                  ),
                                  child: Text(
                                    slot['room'] as String,
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: slot['penalty'] == 0 ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Penalty Score: ${slot['penalty']}',
                                style: TextStyle(
                                  color: slot['penalty'] == 0 ? Colors.green : Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 16),
                        
                        // Constraints Summary
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.check_circle, size: 16, color: Colors.green),
                                      const SizedBox(width: 8),
                                      Text('Satisfied Constraints (${(slot['satisfied'] as List).length})', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: (slot['satisfied'] as List).map((c) => Chip(
                                      label: Text(c, style: const TextStyle(fontSize: 10)),
                                      padding: EdgeInsets.zero,
                                      visualDensity: VisualDensity.compact,
                                    )).toList(),
                                  ),
                                ],
                              ),
                            ),
                            if ((slot['violated'] as List).isNotEmpty) ...[
                              const SizedBox(width: 24),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.warning_amber_rounded, size: 16, color: Colors.orange),
                                        const SizedBox(width: 8),
                                        Text('Violated Soft Constraints (${(slot['violated'] as List).length})', style: const TextStyle(fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: (slot['violated'] as List).map((v) => Padding(
                                        padding: const EdgeInsets.only(bottom: 4),
                                        child: Row(
                                          children: [
                                            Text('• ${v['name']}', style: const TextStyle(fontSize: 12)),
                                            const SizedBox(width: 8),
                                            Text('+${v['penalty']}', style: const TextStyle(fontSize: 12, color: Colors.orange, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                      )).toList(),
                                    ),
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
              },
            ),
          ],
        ),
      ),
    );
  }
}

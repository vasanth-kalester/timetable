import 'package:flutter/material.dart';

class SubstituteRecommendationScreen extends StatelessWidget {
  final String sessionCode;
  final String sessionName;
  final String originalFaculty;
  final String date;
  final int period;

  const SubstituteRecommendationScreen({
    super.key,
    required this.sessionCode,
    required this.sessionName,
    required this.originalFaculty,
    required this.date,
    required this.period,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Mock recommendations
    final recommendations = [
      {
        'name': 'Dr. Kumar',
        'department': 'Computer Science',
        'score': 98,
        'reason': 'Same subject expertise, available, low workload today.',
      },
      {
        'name': 'Dr. Priya',
        'department': 'Computer Science',
        'score': 91,
        'reason': 'Same department, available.',
      },
      {
        'name': 'Dr. Arjun',
        'department': 'Information Technology',
        'score': 86,
        'reason': 'Cross-department qualified, available.',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Substitute Recommendations'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Session Details Card
            Card(
              elevation: 0,
              color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Period',
                            style: TextStyle(color: theme.colorScheme.onPrimary, fontSize: 12),
                          ),
                          Text(
                            '$period',
                            style: TextStyle(color: theme.colorScheme.onPrimary, fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$sessionCode - $sessionName',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.calendar_today, size: 16, color: theme.colorScheme.onSurfaceVariant),
                              const SizedBox(width: 8),
                              Text(date, style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                              const SizedBox(width: 24),
                              Icon(Icons.person_off, size: 16, color: theme.colorScheme.error),
                              const SizedBox(width: 8),
                              Text('Original: $originalFaculty', style: TextStyle(color: theme.colorScheme.error, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            const Text(
              'Recommended Substitutes',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Based on subject expertise, department, workload, and availability.',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recommendations.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final rec = recommendations[index];
                final isTopMatch = index == 0;
                
                return _buildRecommendationCard(rec, isTopMatch, theme);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationCard(Map<String, dynamic> rec, bool isTopMatch, ThemeData theme) {
    final score = rec['score'] as int;
    final color = score >= 95 ? Colors.green : (score >= 90 ? Colors.blue : Colors.orange);

    return Card(
      elevation: isTopMatch ? 4 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isTopMatch ? color : theme.colorScheme.outlineVariant,
          width: isTopMatch ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Score Badge
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$score%',
                      style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      'Match',
                      style: TextStyle(color: color, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 20),
            
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        rec['name'] as String,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      if (isTopMatch) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Best Match',
                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    rec['department'] as String,
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.check_circle_outline, size: 14, color: color),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          rec['reason'] as String,
                          style: TextStyle(color: color, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Action
            const SizedBox(width: 16),
            FilledButton(
              onPressed: () {},
              style: FilledButton.styleFrom(
                backgroundColor: isTopMatch ? color : theme.colorScheme.primary,
              ),
              child: const Text('Assign'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SessionDashboard extends ConsumerWidget {
  const SessionDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Mock data for the dashboard
    final totalSessions = 1250;
    final readinessScore = 95.0;
    
    final typeStats = {
      'Theory': 800,
      'Lab': 300,
      'Tutorial': 100,
      'Project': 50,
    };
    
    final statusStats = {
      'Ready': 1187,
      'Pending': 50,
      'Validation Error': 13,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Session Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Stats
            Row(
              children: [
                Expanded(
                  child: _buildMainStatCard(
                    'Total Sessions',
                    totalSessions.toString(),
                    Icons.view_timeline,
                    theme.colorScheme.primary,
                    theme,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMainStatCard(
                    'Scheduling Readiness',
                    '${readinessScore.toInt()}%',
                    Icons.auto_awesome,
                    readinessScore > 90 ? Colors.green : Colors.orange,
                    theme,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Two Column Layout
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column: Session Types
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sessions by Type',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: typeStats.entries.map((e) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildTypeRow(e.key, e.value, totalSessions, theme),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 24),
                
                // Right Column: Session Status
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Status Overview',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: statusStats.entries.map((e) {
                              Color color;
                              if (e.key == 'Ready') color = Colors.green;
                              else if (e.key == 'Pending') color = Colors.orange;
                              else color = Colors.red;
                              
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _buildStatusRow(e.key, e.value, color, theme),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Actions
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildActionCard(
                  'Browse Sessions',
                  'View and filter all generated sessions',
                  Icons.search,
                  theme,
                  onTap: () {},
                ),
                _buildActionCard(
                  'Rebuild Sessions',
                  'Regenerate sessions from academic plan',
                  Icons.build_circle_outlined,
                  theme,
                  onTap: () {},
                ),
                _buildActionCard(
                  'Validation Report',
                  'View detailed validation results',
                  Icons.fact_check_outlined,
                  theme,
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainStatCard(String title, String value, IconData icon, Color color, ThemeData theme) {
    return Card(
      elevation: 0,
      color: color.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withOpacity(0.3)),
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
              style: TextStyle(fontSize: 16, color: color.withOpacity(0.8), fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeRow(String label, int value, int total, ThemeData theme) {
    final percentage = value / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            Text(
              value.toString(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: percentage,
          backgroundColor: theme.colorScheme.surfaceVariant,
          color: theme.colorScheme.primary,
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
        ),
      ],
    );
  }

  Widget _buildStatusRow(String label, int value, Color color, ThemeData theme) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        ),
        Text(
          value.toString(),
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  Widget _buildActionCard(String title, String subtitle, IconData icon, ThemeData theme, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 250,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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

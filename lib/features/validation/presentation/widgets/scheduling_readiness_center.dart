import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SchedulingReadinessCenter extends ConsumerWidget {
  const SchedulingReadinessCenter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    // In a real implementation, this would be fetched from a provider
    final readinessScore = 85.0;
    final isReady = readinessScore == 100.0;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Scheduling Readiness Center',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Phase 5: Validation & Session Building',
                      style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isReady ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isReady ? Icons.check_circle : Icons.warning_amber_rounded,
                        size: 16,
                        color: isReady ? Colors.green : Colors.orange,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isReady ? 'Ready for Scheduling' : 'Action Required',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isReady ? Colors.green : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Overall Score
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Overall Readiness Score',
                        style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${readinessScore.toInt()}%',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: isReady ? Colors.green : theme.colorScheme.primary,
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: readinessScore / 100,
                        backgroundColor: theme.colorScheme.surfaceVariant,
                        color: isReady ? Colors.green : theme.colorScheme.primary,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 32),
                
                // Quick Stats
                Expanded(
                  child: Column(
                    children: [
                      _buildMiniStat('Sessions Generated', '0', Icons.view_timeline, theme),
                      const SizedBox(height: 12),
                      _buildMiniStat('Blocking Issues', '2', Icons.error_outline, theme, isError: true),
                      const SizedBox(height: 12),
                      _buildMiniStat('Warnings', '5', Icons.warning_amber, theme, isWarning: true),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            
            // Detailed Breakdown
            const Text(
              'Readiness Breakdown',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            _buildReadinessItem(
              'Institution Policies',
              100,
              'All policies configured',
              Icons.account_balance,
              theme,
              onTap: () => context.push('/institution-settings'),
            ),
            _buildReadinessItem(
              'Department Configuration',
              90,
              '1 department missing HOD',
              Icons.domain,
              theme,
              onTap: () => context.push('/academic-structure'),
            ),
            _buildReadinessItem(
              'Faculty Availability',
              60,
              '15 faculty missing profiles',
              Icons.people,
              theme,
              isWarning: true,
              onTap: () => context.push('/faculty'),
            ),
            _buildReadinessItem(
              'Infrastructure',
              100,
              'All classrooms assigned',
              Icons.business,
              theme,
              onTap: () => context.push('/infrastructure'),
            ),
            
            const SizedBox(height: 24),
            
            // Actions
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      // Trigger validation
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Run Validation Engine'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: isReady ? () {
                      // Generate sessions
                    } : null,
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Generate Sessions'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, IconData icon, ThemeData theme, {bool isError = false, bool isWarning = false}) {
    Color color = theme.colorScheme.onSurfaceVariant;
    if (isError && value != '0') color = Colors.red;
    if (isWarning && value != '0') color = Colors.orange;
    
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant)),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildReadinessItem(String title, double score, String subtitle, IconData icon, ThemeData theme, {bool isWarning = false, VoidCallback? onTap}) {
    final isComplete = score == 100;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isWarning ? Colors.orange : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${score.toInt()}%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isComplete ? Colors.green : (isWarning ? Colors.orange : theme.colorScheme.primary),
                  ),
                ),
                const SizedBox(height: 4),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

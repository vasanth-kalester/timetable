import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ValidationReportScreen extends ConsumerWidget {
  const ValidationReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Mock data for the report
    final overallReadiness = 85.0;
    final status = 'warnings'; // passed, failed, warnings
    
    final results = [
      {
        'category': 'Institution',
        'status': 'passed',
        'message': 'Institution is ready for scheduling',
        'severity': 'info',
      },
      {
        'category': 'Department',
        'status': 'passed',
        'message': 'All active departments are ready',
        'severity': 'info',
      },
      {
        'category': 'Section',
        'status': 'warning',
        'message': 'Section B has no home classroom assigned',
        'severity': 'warning',
        'suggestion': 'Assign a home classroom to the section',
      },
      {
        'category': 'Faculty',
        'status': 'error',
        'message': 'Faculty Dr. Smith has no scheduling profile',
        'severity': 'error',
        'suggestion': 'Create a scheduling profile for the faculty',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Validation Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded),
            tooltip: 'Download PDF Report',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Downloading Validation Report...')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Validation Summary',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Generated on ${DateTime.now().toString().split('.')[0]}',
                              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                        _buildStatusBadge(status, theme),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: _buildScoreIndicator('Overall Readiness', overallReadiness, theme),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            children: [
                              _buildStatRow('Total Checks', '${results.length}', theme),
                              const SizedBox(height: 12),
                              _buildStatRow('Passed', '${results.where((r) => r['status'] == 'passed').length}', theme, color: Colors.green),
                              const SizedBox(height: 12),
                              _buildStatRow('Warnings', '${results.where((r) => r['status'] == 'warning').length}', theme, color: Colors.orange),
                              const SizedBox(height: 12),
                              _buildStatRow('Errors', '${results.where((r) => r['status'] == 'error').length}', theme, color: Colors.red),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            const Text(
              'Detailed Results',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Results List
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: results.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final result = results[index];
                return _buildResultCard(result, theme);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status, ThemeData theme) {
    Color color;
    IconData icon;
    String label;
    
    switch (status) {
      case 'passed':
        color = Colors.green;
        icon = Icons.check_circle;
        label = 'Passed';
        break;
      case 'warnings':
        color = Colors.orange;
        icon = Icons.warning_amber_rounded;
        label = 'Passed with Warnings';
        break;
      case 'failed':
      default:
        color = Colors.red;
        icon = Icons.error_outline;
        label = 'Failed';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreIndicator(String label, double score, ThemeData theme) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 120,
              width: 120,
              child: CircularProgressIndicator(
                value: score / 100,
                strokeWidth: 12,
                backgroundColor: theme.colorScheme.surfaceVariant,
                color: score == 100 ? Colors.green : theme.colorScheme.primary,
                strokeCap: StrokeCap.round,
              ),
            ),
            Text(
              '${score.toInt()}%',
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          label,
          style: TextStyle(fontSize: 16, color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value, ThemeData theme, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color ?? theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildResultCard(Map<String, String> result, ThemeData theme) {
    Color color;
    IconData icon;
    
    switch (result['severity']) {
      case 'info':
        color = Colors.blue;
        icon = Icons.info_outline;
        break;
      case 'warning':
        color = Colors.orange;
        icon = Icons.warning_amber_rounded;
        break;
      case 'error':
      case 'critical':
        color = Colors.red;
        icon = Icons.error_outline;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help_outline;
    }
    
    return Card(
      elevation: 0,
      color: color.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: theme.colorScheme.outlineVariant),
                        ),
                        child: Text(
                          result['category']!,
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        result['severity']!.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    result['message']!,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                  if (result['suggestion'] != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.lightbulb_outline, size: 16, color: Colors.amber[700]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              result['suggestion']!,
                              style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class ExecutiveDashboardScreen extends StatelessWidget {
  const ExecutiveDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Executive Dashboard'),
        actions: [
          IconButton(
            icon: const Badge(
              label: Text('2'),
              child: Icon(Icons.warning_amber_rounded),
            ),
            tooltip: 'Executive Alerts',
            onPressed: () {},
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Institution Overview',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download),
                  label: const Text('Export Report'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Top Level Health Score
            _buildHealthScoreCard(theme),
            const SizedBox(height: 24),
            
            // KPI Grid
            const Text('Key Performance Indicators', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildKPICard('Avg Classroom Util', '78.5%', '+2.1%', Icons.meeting_room, Colors.blue, theme),
                _buildKPICard('Avg Faculty Workload', '82.0%', '-1.5%', Icons.person, Colors.purple, theme),
                _buildKPICard('Timetable Completion', '100%', '0%', Icons.check_circle, Colors.green, theme),
                _buildKPICard('Idle Infrastructure', '5.0%', '-0.5%', Icons.domain_disabled, Colors.orange, theme),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Two Column Layout for Benchmarking and Alerts
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: _buildDepartmentBenchmarking(theme),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 1,
                  child: _buildActiveAlerts(theme),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthScoreCard(ThemeData theme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.3)),
      ),
      color: theme.colorScheme.primaryContainer.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Institution Health Score',
                  style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '88.5',
                      style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8.0, left: 4.0),
                      child: Text('/ 100', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('Based on academic, administrative, and infrastructure metrics.'),
              ],
            ),
            Icon(Icons.health_and_safety, size: 80, color: theme.colorScheme.primary.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildKPICard(String title, String value, String trend, IconData icon, Color color, ThemeData theme) {
    final isPositiveTrend = trend.startsWith('+');
    final trendColor = isPositiveTrend ? Colors.green : (trend == '0%' ? Colors.grey : Colors.red);
    final trendIcon = isPositiveTrend ? Icons.arrow_upward : (trend == '0%' ? Icons.remove : Icons.arrow_downward);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                Row(
                  children: [
                    Icon(trendIcon, size: 16, color: trendColor),
                    const SizedBox(width: 4),
                    Text(trend, style: TextStyle(color: trendColor, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  title,
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDepartmentBenchmarking(ThemeData theme) {
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
                const Text('Department Benchmarking', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(onPressed: () {}, child: const Text('View Full Report')),
              ],
            ),
            const SizedBox(height: 16),
            // Mock Chart Placeholder
            Container(
              height: 250,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.colorScheme.outlineVariant, style: BorderStyle.solid),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bar_chart, size: 64, color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5)),
                    const SizedBox(height: 16),
                    Text(
                      'Department Comparison Chart (Workload vs Utilization)',
                      style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveAlerts(ThemeData theme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.red.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.red),
                const SizedBox(width: 8),
                const Text('Active Alerts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
              ],
            ),
            const SizedBox(height: 24),
            _buildAlertItem('Faculty workload in CS department exceeds AICTE limits.', 'High', theme),
            const Divider(height: 32),
            _buildAlertItem('Engineering Block classroom utilization is above 95%.', 'Medium', theme),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertItem(String message, String severity, ThemeData theme) {
    final color = severity == 'High' ? Colors.red : Colors.orange;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 4),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text(
                'Severity: $severity',
                style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

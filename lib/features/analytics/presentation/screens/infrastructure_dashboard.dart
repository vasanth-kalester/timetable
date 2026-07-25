import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InfrastructureDashboard extends ConsumerWidget {
  const InfrastructureDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Mock data for the dashboard
    final totalRooms = 45;
    final avgRoomUtilization = 78.5;
    final totalFaculty = 120;
    final avgFacultyWorkload = 82.0;
    final overallQualityScore = 92;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Infrastructure Intelligence'),
        actions: [
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.download),
            label: const Text('Export Report'),
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
              'Campus Overview',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            
            // Top Metrics
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'Room Utilization',
                    '${avgRoomUtilization.toStringAsFixed(1)}%',
                    'Out of $totalRooms rooms',
                    Icons.meeting_room,
                    Colors.blue,
                    theme,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricCard(
                    'Faculty Workload',
                    '${avgFacultyWorkload.toStringAsFixed(1)}%',
                    'Across $totalFaculty faculty',
                    Icons.person,
                    Colors.purple,
                    theme,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricCard(
                    'Timetable Quality',
                    '$overallQualityScore/100',
                    'Based on idle times',
                    Icons.star,
                    Colors.amber,
                    theme,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 40),
            
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column: Utilization Charts & Warnings
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Utilization by Building',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: theme.colorScheme.outlineVariant),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              _buildBuildingBar('Engineering Block', 85, theme),
                              const SizedBox(height: 16),
                              _buildBuildingBar('Science Block', 72, theme),
                              const SizedBox(height: 16),
                              _buildBuildingBar('Arts Block', 60, theme),
                              const SizedBox(height: 16),
                              _buildBuildingBar('Main Lab Complex', 92, theme, isWarning: true),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      const Text(
                        'Infrastructure Warnings',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      _buildWarningCard(
                        'Lab Overload',
                        'Main Lab Complex is operating at 92% capacity. Consider adding more lab sessions in the Science Block.',
                        Icons.warning_amber_rounded,
                        Colors.orange,
                        theme,
                      ),
                      const SizedBox(height: 12),
                      _buildWarningCard(
                        'Underutilized Rooms',
                        'Rooms 301, 302 in Arts Block are under 40% utilization.',
                        Icons.info_outline,
                        Colors.blue,
                        theme,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 24),
                
                // Right Column: Quick Actions & Planning
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Planning Tools',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      _buildToolCard(
                        'Digital Twin Campus Map',
                        'View real-time room status and heatmaps.',
                        Icons.map,
                        theme.colorScheme.primary,
                        theme,
                      ),
                      const SizedBox(height: 12),
                      _buildToolCard(
                        'Capacity Simulator',
                        'Simulate adding new sections or increasing intake.',
                        Icons.science,
                        Colors.teal,
                        theme,
                      ),
                      const SizedBox(height: 12),
                      _buildToolCard(
                        'Demand Forecaster',
                        'Estimate resource needs for the next semester.',
                        Icons.trending_up,
                        Colors.indigo,
                        theme,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, String subtitle, IconData icon, Color color, ThemeData theme) {
    return Card(
      elevation: 0,
      color: color.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 32),
                Icon(Icons.trending_up, color: Colors.green, size: 24),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              value,
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBuildingBar(String name, int percentage, ThemeData theme, {bool isWarning = false}) {
    final color = isWarning ? Colors.orange : theme.colorScheme.primary;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('$percentage%', style: TextStyle(fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: color.withOpacity(0.1),
          color: color,
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildWarningCard(String title, String message, IconData icon, Color color, ThemeData theme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withOpacity(0.3)),
      ),
      color: color.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
                  const SizedBox(height: 4),
                  Text(message, style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolCard(String title, String description, IconData icon, Color color, ThemeData theme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(description, style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

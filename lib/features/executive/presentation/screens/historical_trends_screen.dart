import 'package:flutter/material.dart';

class HistoricalTrendsScreen extends StatefulWidget {
  const HistoricalTrendsScreen({super.key});

  @override
  State<HistoricalTrendsScreen> createState() => _HistoricalTrendsScreenState();
}

class _HistoricalTrendsScreenState extends State<HistoricalTrendsScreen> {
  String _selectedMetric = 'Classroom Utilization';

  final List<String> _metrics = [
    'Classroom Utilization',
    'Faculty Workload',
    'Student Intake',
    'Timetable Revisions',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historical Trends & Forecasts'),
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
                  'Trend Analysis',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                DropdownButton<String>(
                  value: _selectedMetric,
                  items: _metrics.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedMetric = newValue;
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Mock Chart Area
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.colorScheme.outlineVariant, style: BorderStyle.solid),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.show_chart, size: 64, color: theme.colorScheme.primary.withOpacity(0.5)),
                    const SizedBox(height: 16),
                    Text(
                      'Historical Trend Chart for $_selectedMetric',
                      style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '(Showing data from 2024-Odd to 2026-Odd)',
                      style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            const Text(
              'Resource Forecast (Next Academic Year)',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(child: _buildForecastCard('Additional Classrooms', '3', Icons.meeting_room, Colors.blue, theme)),
                const SizedBox(width: 16),
                Expanded(child: _buildForecastCard('Additional Labs', '1', Icons.science, Colors.purple, theme)),
                const SizedBox(width: 16),
                Expanded(child: _buildForecastCard('New Faculty Hires', '5', Icons.person_add, Colors.teal, theme)),
              ],
            ),
            
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.colorScheme.secondaryContainer),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb, color: theme.colorScheme.onSecondaryContainer),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Recommendation: Consider expanding the Science Block to accommodate new labs based on the projected 15% growth in Computer Science intake.',
                      style: TextStyle(color: theme.colorScheme.onSecondaryContainer, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForecastCard(String title, String value, IconData icon, Color color, ThemeData theme) {
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
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class ReportsCenterScreen extends StatelessWidget {
  const ReportsCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final reports = [
      {
        'title': 'Comprehensive Utilization Report',
        'description': 'Detailed breakdown of room and faculty utilization across the entire campus.',
        'icon': Icons.analytics,
        'color': Colors.blue,
      },
      {
        'title': 'Faculty Workload Report',
        'description': 'Teaching hours, free periods, and cross-department workload for all faculty.',
        'icon': Icons.person,
        'color': Colors.purple,
      },
      {
        'title': 'Capacity Planning Report',
        'description': 'Forecasts and simulation results for future resource requirements.',
        'icon': Icons.science,
        'color': Colors.teal,
      },
      {
        'title': 'Infrastructure Conflict Report',
        'description': 'List of overloaded rooms, underutilized spaces, and recurring issues.',
        'icon': Icons.warning_amber_rounded,
        'color': Colors.orange,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports Center'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Generate & Export Reports',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Select a report type to generate and download as PDF or Excel.',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 32),
            
            GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
                childAspectRatio: 2.5,
              ),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index];
                return _buildReportCard(report, theme);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report, ThemeData theme) {
    final color = report['color'] as Color;
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(report['icon'] as IconData, color: color, size: 32),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      report['title'] as String,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      report['description'] as String,
                      style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.picture_as_pdf),
                    color: Colors.red,
                    tooltip: 'Export as PDF',
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.table_chart),
                    color: Colors.green,
                    tooltip: 'Export as Excel',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

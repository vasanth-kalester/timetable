import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SchedulingControlCenter extends ConsumerStatefulWidget {
  const SchedulingControlCenter({super.key});

  @override
  ConsumerState<SchedulingControlCenter> createState() => _SchedulingControlCenterState();
}

class _SchedulingControlCenterState extends ConsumerState<SchedulingControlCenter> {
  int _currentStep = 4; // Mock current step (Generate Timetable)

  final List<Map<String, dynamic>> _steps = [
    {
      'title': 'Academic Planning',
      'subtitle': 'Define academic year, programs, and semesters.',
      'status': 'completed',
      'icon': Icons.calendar_month,
    },
    {
      'title': 'Validation',
      'subtitle': 'Ensure all master data (faculty, rooms, subjects) is ready.',
      'status': 'completed',
      'icon': Icons.fact_check,
    },
    {
      'title': 'Session Builder',
      'subtitle': 'Convert teaching assignments into normalized sessions.',
      'status': 'completed',
      'icon': Icons.view_timeline,
    },
    {
      'title': 'Candidate Slots',
      'subtitle': 'Generate and rank all legal scheduling possibilities.',
      'status': 'completed',
      'icon': Icons.grid_on,
    },
    {
      'title': 'Generate Timetable',
      'subtitle': 'Run the optimization engine to produce a conflict-free schedule.',
      'status': 'active',
      'icon': Icons.auto_awesome,
    },
    {
      'title': 'Review Draft',
      'subtitle': 'Inspect the generated timetable and make manual adjustments.',
      'status': 'pending',
      'icon': Icons.preview,
    },
    {
      'title': 'Approve',
      'subtitle': 'HODs and Principal approve the final timetable.',
      'status': 'pending',
      'icon': Icons.thumb_up,
    },
    {
      'title': 'Publish',
      'subtitle': 'Make the timetable visible to faculty and students.',
      'status': 'pending',
      'icon': Icons.publish,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scheduling Control Center'),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Sidebar - Workflow Guide
          Container(
            width: 350,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(right: BorderSide(color: theme.colorScheme.outlineVariant)),
            ),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 24),
              itemCount: _steps.length,
              itemBuilder: (context, index) {
                final step = _steps[index];
                final isCompleted = step['status'] == 'completed';
                final isActive = step['status'] == 'active';
                final isPending = step['status'] == 'pending';

                return InkWell(
                  onTap: () {
                    if (isCompleted || isActive) {
                      setState(() => _currentStep = index);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: isActive ? theme.colorScheme.primaryContainer.withOpacity(0.3) : Colors.transparent,
                      border: Border(
                        left: BorderSide(
                          color: isActive ? theme.colorScheme.primary : Colors.transparent,
                          width: 4,
                        ),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isCompleted 
                                ? Colors.green.withOpacity(0.1) 
                                : isActive 
                                    ? theme.colorScheme.primary.withOpacity(0.1) 
                                    : theme.colorScheme.surfaceVariant,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isCompleted ? Icons.check : step['icon'] as IconData,
                            size: 20,
                            color: isCompleted 
                                ? Colors.green 
                                : isActive 
                                    ? theme.colorScheme.primary 
                                    : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                step['title'] as String,
                                style: TextStyle(
                                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                                  color: isPending ? theme.colorScheme.onSurfaceVariant : theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                step['subtitle'] as String,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Right Content Area
          Expanded(
            child: _buildContentArea(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildContentArea(ThemeData theme) {
    if (_currentStep == 4) {
      return _buildGenerateTimetableContent(theme);
    }
    
    return Center(
      child: Text(
        'Content for ${_steps[_currentStep]['title']}',
        style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
      ),
    );
  }

  Widget _buildGenerateTimetableContent(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Generate Timetable',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Run the optimization engine to produce a conflict-free schedule for the entire institution.',
            style: TextStyle(fontSize: 16, color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 40),
          
          // Readiness Check
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.green.withOpacity(0.5)),
            ),
            color: Colors.green.withOpacity(0.05),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 32),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'System Ready for Generation',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '4,820 sessions validated. 162,000 candidate slots generated. No unresolvable conflicts detected.',
                          style: TextStyle(color: Colors.green.shade700),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Generation Options
          const Text(
            'Generation Scope',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildScopeCard(
                  'Full Institution',
                  'Generate timetable for all departments simultaneously. Recommended for best resource utilization.',
                  Icons.account_balance,
                  true,
                  theme,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildScopeCard(
                  'Single Department',
                  'Generate timetable for a specific department. May cause conflicts with shared resources.',
                  Icons.domain,
                  false,
                  theme,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 40),
          
          // Action Button
          Center(
            child: FilledButton.icon(
              onPressed: () {
                // Trigger generation
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const _GenerationProgressDialog(),
                );
              },
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
              ),
              icon: const Icon(Icons.auto_awesome, size: 24),
              label: const Text('Start Optimization Engine', style: TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScopeCard(String title, String subtitle, IconData icon, bool isSelected, ThemeData theme) {
    return Card(
      elevation: isSelected ? 2 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outlineVariant,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant, size: 32),
                  if (isSelected)
                    Icon(Icons.check_circle, color: theme.colorScheme.primary),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GenerationProgressDialog extends StatefulWidget {
  const _GenerationProgressDialog();

  @override
  State<_GenerationProgressDialog> createState() => _GenerationProgressDialogState();
}

class _GenerationProgressDialogState extends State<_GenerationProgressDialog> {
  double _progress = 0.0;
  String _status = 'Initializing Optimization Engine...';

  @override
  void initState() {
    super.initState();
    _simulateProgress();
  }

  void _simulateProgress() async {
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) setState(() { _progress = 0.2; _status = 'Sorting sessions by difficulty...'; });
    
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() { _progress = 0.5; _status = 'Selecting candidates & reserving resources...'; });
    
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() { _progress = 0.8; _status = 'Running local optimization...'; });
    
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) setState(() { _progress = 1.0; _status = 'Timetable generated successfully!'; });
    
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Generating Timetable'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LinearProgressIndicator(value: _progress),
          const SizedBox(height: 16),
          Text(_status),
        ],
      ),
    );
  }
}

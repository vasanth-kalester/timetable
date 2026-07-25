import 'package:flutter/material.dart';

class CapacitySimulatorScreen extends StatefulWidget {
  const CapacitySimulatorScreen({super.key});

  @override
  State<CapacitySimulatorScreen> createState() => _CapacitySimulatorScreenState();
}

class _CapacitySimulatorScreenState extends State<CapacitySimulatorScreen> {
  int _newSections = 0;
  int _studentsPerSection = 60;
  int _newLabs = 0;

  bool _isSimulated = false;

  // Mock simulation results
  final Map<String, dynamic> _simulationResults = {
    'baseline': {
      'totalRooms': 45,
      'currentUtilization': 78.5,
    },
    'simulation': {
      'estimatedNewPeriods': 120,
      'projectedUtilization': 88.2,
      'additionalRoomsNeeded': 2,
      'additionalFacultyNeeded': 8.0,
      'status': 'Warning',
    }
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Capacity Simulator'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Simulate Changes',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Input hypothetical changes to estimate the impact on infrastructure and faculty requirements.',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 32),
            
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Input Form
                Expanded(
                  flex: 1,
                  child: Card(
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
                          const Text('Parameters', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 24),
                          
                          _buildNumberInput('New Sections', _newSections, (val) => setState(() => _newSections = val), theme),
                          const SizedBox(height: 16),
                          _buildNumberInput('Students per Section', _studentsPerSection, (val) => setState(() => _studentsPerSection = val), theme, step: 10),
                          const SizedBox(height: 16),
                          _buildNumberInput('New Labs', _newLabs, (val) => setState(() => _newLabs = val), theme),
                          
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: () {
                                setState(() {
                                  _isSimulated = true;
                                });
                              },
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('Run Simulation'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 24),
                
                // Results Area
                Expanded(
                  flex: 2,
                  child: _isSimulated ? _buildResultsArea(theme) : _buildEmptyState(theme),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberInput(String label, int value, Function(int) onChanged, ThemeData theme, {int step = 1}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Row(
          children: [
            IconButton(
              onPressed: value > 0 ? () => onChanged(value - step) : null,
              icon: const Icon(Icons.remove_circle_outline),
              color: theme.colorScheme.primary,
            ),
            SizedBox(
              width: 40,
              child: Text(
                '$value',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              onPressed: () => onChanged(value + step),
              icon: const Icon(Icons.add_circle_outline),
              color: theme.colorScheme.primary,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Container(
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
            Icon(Icons.science, size: 64, color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              'Run a simulation to see the impact.',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsArea(ThemeData theme) {
    final baseline = _simulationResults['baseline'];
    final sim = _simulationResults['simulation'];
    final status = sim['status'] as String;
    
    final statusColor = status == 'Warning' ? Colors.orange : Colors.green;
    final statusIcon = status == 'Warning' ? Icons.warning_amber_rounded : Icons.check_circle_outline;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status Banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: statusColor.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(statusIcon, color: statusColor),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      status == 'Warning' ? 'Infrastructure Strain Detected' : 'Capacity Feasible',
                      style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      status == 'Warning' 
                          ? 'The projected utilization exceeds safe limits. Additional resources are required.'
                          : 'The current infrastructure can accommodate these changes.',
                      style: TextStyle(color: statusColor.withOpacity(0.8), fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Metrics Grid
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 2,
          children: [
            _buildResultCard('Projected Utilization', '${sim['projectedUtilization']}%', 'Up from ${baseline['currentUtilization']}%', Icons.trending_up, Colors.blue, theme),
            _buildResultCard('New Periods/Week', '+${sim['estimatedNewPeriods']}', 'Theory + Lab', Icons.schedule, Colors.purple, theme),
            _buildResultCard('Rooms Shortfall', '${sim['additionalRoomsNeeded']}', 'Additional rooms needed', Icons.meeting_room, Colors.orange, theme),
            _buildResultCard('Faculty Required', '+${sim['additionalFacultyNeeded']}', 'Estimated new hires', Icons.person_add, Colors.teal, theme),
          ],
        ),
      ],
    );
  }

  Widget _buildResultCard(String title, String value, String subtitle, IconData icon, Color color, ThemeData theme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    value,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
                  ),
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 11),
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

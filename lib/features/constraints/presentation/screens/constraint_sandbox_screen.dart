import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConstraintSandboxScreen extends ConsumerStatefulWidget {
  const ConstraintSandboxScreen({super.key});

  @override
  ConsumerState<ConstraintSandboxScreen> createState() => _ConstraintSandboxScreenState();
}

class _ConstraintSandboxScreenState extends ConsumerState<ConstraintSandboxScreen> {
  bool _isSimulating = false;
  bool _hasResults = false;

  // Mock simulation results
  final int _originalSlots = 162000;
  final int _newSlots = 148500;
  final int _affectedSessions = 450;
  final bool _isFeasible = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Constraint Sandbox'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Simulation Environment',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Test policy changes and see their impact on candidate slots before applying them to the live system.',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 32),
            
            // Scenario Configuration
            Card(
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
                    const Text(
                      'Scenario Configuration',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    
                    // Mock parameter change
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Constraint to Modify',
                              border: OutlineInputBorder(),
                            ),
                            value: 'Spread Workload',
                            items: const [
                              DropdownMenuItem(value: 'Spread Workload', child: Text('Spread Workload')),
                              DropdownMenuItem(value: 'Continuous Lab', child: Text('Continuous Lab')),
                            ],
                            onChanged: (value) {},
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            initialValue: '4',
                            decoration: const InputDecoration(
                              labelText: 'Current Value (Max Classes/Day)',
                              border: OutlineInputBorder(),
                              enabled: false,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            initialValue: '3',
                            decoration: const InputDecoration(
                              labelText: 'New Value',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.icon(
                        onPressed: _isSimulating ? null : _runSimulation,
                        icon: _isSimulating 
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.play_arrow),
                        label: Text(_isSimulating ? 'Simulating...' : 'Run Simulation'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            if (_hasResults) ...[
              const SizedBox(height: 32),
              const Text(
                'Simulation Results',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              // Results Grid
              Row(
                children: [
                  Expanded(
                    child: _buildResultCard(
                      'Candidate Slots Lost/Gained',
                      '${_newSlots - _originalSlots}',
                      Icons.compare_arrows,
                      Colors.red,
                      theme,
                      subtitle: 'From $_originalSlots to $_newSlots',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildResultCard(
                      'Affected Sessions',
                      '$_affectedSessions',
                      Icons.warning_amber_rounded,
                      Colors.orange,
                      theme,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildResultCard(
                      'Timetable Feasibility',
                      _isFeasible ? 'Feasible' : 'Infeasible',
                      _isFeasible ? Icons.check_circle : Icons.cancel,
                      _isFeasible ? Colors.green : Colors.red,
                      theme,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Apply Changes
              Card(
                elevation: 0,
                color: theme.colorScheme.primaryContainer.withOpacity(0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.2)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: theme.colorScheme.primary),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'This policy change reduces the search space by 8.3%, which may speed up generation but increases the risk of conflicts for highly constrained faculty.',
                          style: TextStyle(color: theme.colorScheme.onPrimaryContainer),
                        ),
                      ),
                      const SizedBox(width: 16),
                      FilledButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Policy applied to live system')),
                          );
                        },
                        child: const Text('Apply Policy'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(String title, String value, IconData icon, Color color, ThemeData theme, {String? subtitle}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurfaceVariant),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _runSimulation() {
    setState(() {
      _isSimulating = true;
      _hasResults = false;
    });
    
    // Simulate network delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isSimulating = false;
          _hasResults = true;
        });
      }
    });
  }
}

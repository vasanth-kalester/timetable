import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConstraintSettingsScreen extends ConsumerStatefulWidget {
  const ConstraintSettingsScreen({super.key});

  @override
  ConsumerState<ConstraintSettingsScreen> createState() => _ConstraintSettingsScreenState();
}

class _ConstraintSettingsScreenState extends ConsumerState<ConstraintSettingsScreen> {
  // Mock data for constraints
  final List<Map<String, dynamic>> _hardConstraints = [
    {'id': '1', 'name': 'Faculty Conflict', 'description': 'A faculty cannot teach two sessions simultaneously.', 'isActive': true, 'type': 'hard'},
    {'id': '2', 'name': 'Classroom Conflict', 'description': 'A classroom can only host one session at a time.', 'isActive': true, 'type': 'hard'},
    {'id': '3', 'name': 'Continuous Lab', 'description': 'Lab sessions must be scheduled in consecutive periods.', 'isActive': true, 'type': 'hard'},
  ];

  final List<Map<String, dynamic>> _softConstraints = [
    {'id': '4', 'name': 'Preferred Day Off', 'description': 'Avoid scheduling on a faculty\'s preferred day off.', 'isActive': true, 'type': 'soft', 'weight': 10},
    {'id': '5', 'name': 'Avoid First Hour', 'description': 'Minimize classes in the first period of the day.', 'isActive': false, 'type': 'soft', 'weight': 5},
    {'id': '6', 'name': 'Spread Workload', 'description': 'Avoid scheduling too many classes for a faculty on a single day.', 'isActive': true, 'type': 'soft', 'weight': 8, 'parameters': 'Max 4 per day'},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Constraint Settings'),
        actions: [
          FilledButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings saved successfully')),
              );
            },
            icon: const Icon(Icons.save),
            label: const Text('Save Changes'),
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
              'Constraint Engine Configuration',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Configure the rules used by the Candidate Slot Generator to determine valid scheduling options.',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 32),
            
            // Hard Constraints Section
            Row(
              children: [
                Icon(Icons.gavel, color: theme.colorScheme.error),
                const SizedBox(width: 8),
                const Text(
                  'Hard Constraints',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'These rules must never be violated. Any slot violating a hard constraint is immediately rejected.',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _hardConstraints.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final constraint = _hardConstraints[index];
                  return _buildConstraintTile(constraint, theme);
                },
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Soft Constraints Section
            Row(
              children: [
                Icon(Icons.tune, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                const Text(
                  'Soft Constraints (Preferences)',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'These rules influence the quality of the schedule. Violations add a penalty score to the candidate slot.',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _softConstraints.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final constraint = _softConstraints[index];
                  return _buildConstraintTile(constraint, theme, isSoft: true);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConstraintTile(Map<String, dynamic> constraint, ThemeData theme, {bool isSoft = false}) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Switch(
            value: constraint['isActive'] as bool,
            onChanged: (value) {
              setState(() {
                constraint['isActive'] = value;
              });
            },
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      constraint['name'] as String,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    if (isSoft) ...[
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Penalty Weight: ${constraint['weight']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  constraint['description'] as String,
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                ),
                if (constraint['parameters'] != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.settings, size: 14, color: theme.colorScheme.primary),
                      const SizedBox(width: 4),
                      Text(
                        'Parameter: ${constraint['parameters']}',
                        style: TextStyle(fontSize: 12, color: theme.colorScheme.primary, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('Edit', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (isSoft)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit Weight',
              onPressed: () {},
            ),
        ],
      ),
    );
  }
}

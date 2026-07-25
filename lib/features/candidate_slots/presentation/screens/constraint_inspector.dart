import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConstraintInspectorScreen extends ConsumerWidget {
  final String slotId;
  
  const ConstraintInspectorScreen({super.key, required this.slotId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Mock data for the inspector
    final slot = {
      'sessionCode': 'CS301-T1',
      'day': 'Wednesday',
      'period': 4,
      'status': 'Invalid',
      'penalty': 0,
    };
    
    final hardConstraints = [
      {'name': 'Faculty Conflict', 'passed': false, 'message': 'Faculty Dr. Alan Turing is already scheduled for CS302-T2 in Room 105.'},
      {'name': 'Classroom Conflict', 'passed': true, 'message': 'Room 101 is available.'},
      {'name': 'Working Day', 'passed': true, 'message': 'Wednesday is a valid working day.'},
      {'name': 'Period Validity', 'passed': true, 'message': 'Period 4 is a valid teaching period.'},
    ];
    
    final softConstraints = [
      {'name': 'Preferred Day Off', 'passed': true, 'penalty': 0, 'message': 'Wednesday is not a preferred day off.'},
      {'name': 'Avoid First Hour', 'passed': true, 'penalty': 0, 'message': 'Period 4 is not the first hour.'},
      {'name': 'Spread Workload', 'passed': false, 'penalty': 10, 'message': 'Faculty already has 4 classes on Wednesday.'},
    ];

    final isInvalid = slot['status'] == 'Invalid';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Constraint Inspector'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isInvalid ? Colors.red.withOpacity(0.05) : Colors.green.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isInvalid ? Colors.red.withOpacity(0.2) : Colors.green.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Slot Evaluation: ${slot['sessionCode']}',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Proposed: ${slot['day']}, Period ${slot['period']}',
                        style: TextStyle(fontSize: 16, color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isInvalid ? Colors.red : Colors.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isInvalid ? 'REJECTED' : 'ACCEPTED (Penalty: ${slot['penalty']})',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Hard Constraints
            Row(
              children: [
                Icon(Icons.gavel, color: theme.colorScheme.error),
                const SizedBox(width: 8),
                const Text(
                  'Hard Constraints Evaluation',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
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
                itemCount: hardConstraints.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final constraint = hardConstraints[index];
                  final passed = constraint['passed'] as bool;
                  return ListTile(
                    leading: Icon(
                      passed ? Icons.check_circle : Icons.cancel,
                      color: passed ? Colors.green : Colors.red,
                    ),
                    title: Text(constraint['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(constraint['message'] as String),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Soft Constraints
            Row(
              children: [
                Icon(Icons.tune, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                const Text(
                  'Soft Constraints Evaluation',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
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
                itemCount: softConstraints.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final constraint = softConstraints[index];
                  final passed = constraint['passed'] as bool;
                  final penalty = constraint['penalty'] as int;
                  return ListTile(
                    leading: Icon(
                      passed ? Icons.check_circle : Icons.warning_amber_rounded,
                      color: passed ? Colors.green : Colors.orange,
                    ),
                    title: Row(
                      children: [
                        Text(constraint['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                        if (penalty > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.orange.withOpacity(0.3)),
                            ),
                            child: Text('+${penalty} Penalty', style: const TextStyle(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ],
                    ),
                    subtitle: Text(constraint['message'] as String),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

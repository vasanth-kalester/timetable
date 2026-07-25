import 'package:flutter/material.dart';

class AccreditationCenterScreen extends StatefulWidget {
  const AccreditationCenterScreen({super.key});

  @override
  State<AccreditationCenterScreen> createState() => _AccreditationCenterScreenState();
}

class _AccreditationCenterScreenState extends State<AccreditationCenterScreen> {
  String _selectedBody = 'AICTE';

  final List<Map<String, dynamic>> _metrics = [
    {'indicator': 'Faculty-Student Ratio', 'value': '1:15', 'target': '1:20', 'status': 'Compliant'},
    {'indicator': 'Classroom Availability', 'value': '100%', 'target': '100%', 'status': 'Compliant'},
    {'indicator': 'Laboratory Adequacy', 'value': '95%', 'target': '100%', 'status': 'Warning'},
    {'indicator': 'Teaching Load Distribution', 'value': 'Even', 'target': 'Even', 'status': 'Compliant'},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accreditation Center'),
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
                  'Compliance Dashboard',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download),
                  label: const Text('Generate Evidence Report'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Body Selector
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'AICTE', label: Text('AICTE')),
                ButtonSegment(value: 'NBA', label: Text('NBA')),
                ButtonSegment(value: 'NAAC', label: Text('NAAC')),
              ],
              selected: {_selectedBody},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  _selectedBody = newSelection.first;
                });
              },
            ),
            
            const SizedBox(height: 32),
            
            // Overall Status
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 48),
                  const SizedBox(width: 24),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$_selectedBody Status: Ready for Audit',
                        style: const TextStyle(color: Colors.green, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Most key indicators are currently meeting or exceeding requirements.',
                        style: TextStyle(color: Colors.green.withOpacity(0.8)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Metrics Table
            const Text('Key Indicators', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _metrics.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final metric = _metrics[index];
                  final isCompliant = metric['status'] == 'Compliant';
                  final color = isCompliant ? Colors.green : Colors.orange;
                  final icon = isCompliant ? Icons.check_circle : Icons.warning;
                  
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(icon, color: color),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: Text(metric['indicator'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Current: ${metric['value']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text('Target: ${metric['target']}', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            metric['status'] as String,
                            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
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

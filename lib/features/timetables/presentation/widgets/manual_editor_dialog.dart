import 'package:flutter/material.dart';

class ManualEditorDialog extends StatefulWidget {
  final Map<String, dynamic> entry;
  final int proposedDay;
  final int proposedPeriod;

  const ManualEditorDialog({
    super.key,
    required this.entry,
    required this.proposedDay,
    required this.proposedPeriod,
  });

  @override
  State<ManualEditorDialog> createState() => _ManualEditorDialogState();
}

class _ManualEditorDialogState extends State<ManualEditorDialog> {
  bool _isValidating = true;
  bool _isValid = false;
  List<Map<String, dynamic>> _conflicts = [];
  List<Map<String, dynamic>> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _validateMove();
  }

  void _validateMove() async {
    // Simulate API call to validate the manual edit
    await Future.delayed(const Duration(milliseconds: 800));
    
    if (mounted) {
      // Mock validation logic
      if (widget.proposedDay == 3 && widget.proposedPeriod == 4) {
        // Mock a conflict
        setState(() {
          _isValidating = false;
          _isValid = false;
          _conflicts = [
            {
              'type': 'Faculty Conflict',
              'message': 'Dr. Alan Turing is already scheduled for CS302-T2 in Room 105.',
            }
          ];
          _suggestions = [
            {'day': 3, 'period': 5, 'room': 'Room 101'},
            {'day': 4, 'period': 2, 'room': 'Room 101'},
          ];
        });
      } else {
        // Mock success
        setState(() {
          _isValidating = false;
          _isValid = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
    final dayName = dayNames[widget.proposedDay - 1];

    return AlertDialog(
      title: const Text('Manual Adjustment'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Moving ${widget.entry['sessionCode']} to $dayName, Period ${widget.proposedPeriod}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            
            if (_isValidating)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Validating move against constraints...'),
                  ],
                ),
              )
            else if (_isValid)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'This move is valid and does not create any hard constraint conflicts.',
                        style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: theme.colorScheme.error.withOpacity(0.5)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.cancel, color: theme.colorScheme.error),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Conflict Detected',
                                style: TextStyle(color: theme.colorScheme.error, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              ..._conflicts.map((c) => Text('• ${c['message']}', style: TextStyle(color: theme.colorScheme.onErrorContainer, fontSize: 13))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  const Text('Auto-Repair Suggestions', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  
                  ..._suggestions.map((s) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: theme.colorScheme.outlineVariant),
                      ),
                      leading: const Icon(Icons.auto_awesome, color: Colors.purple),
                      title: Text('${dayNames[s['day'] - 1]}, Period ${s['period']}'),
                      subtitle: Text(s['room']),
                      trailing: FilledButton.tonal(
                        onPressed: () {
                          Navigator.of(context).pop(s);
                        },
                        child: const Text('Apply'),
                      ),
                    ),
                  )),
                ],
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        if (!_isValidating && _isValid)
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop({
                'day': widget.proposedDay,
                'period': widget.proposedPeriod,
                'room': widget.entry['room'],
              });
            },
            child: const Text('Confirm Move'),
          ),
      ],
    );
  }
}

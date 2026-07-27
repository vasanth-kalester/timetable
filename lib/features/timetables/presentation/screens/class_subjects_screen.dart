import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ClassSubjectsScreen extends ConsumerStatefulWidget {
  const ClassSubjectsScreen({super.key});

  @override
  ConsumerState<ClassSubjectsScreen> createState() => _ClassSubjectsScreenState();
}

class _ClassSubjectsScreenState extends ConsumerState<ClassSubjectsScreen> {
  String? _selectedClassId;
  
  // Mock data for demonstration
  final List<Map<String, dynamic>> _classes = [
    {'id': 'c1', 'name': 'Year 2 - Section A'},
    {'id': 'c2', 'name': 'Year 2 - Section B'},
    {'id': 'c3', 'name': 'Year 3 - Section A'},
  ];

  final List<Map<String, dynamic>> _subjects = [
    {'id': 's1', 'name': 'Data Structures', 'code': 'CS201', 'classId': 'c1', 'staffId': 'f1'},
    {'id': 's2', 'name': 'Database Systems', 'code': 'CS202', 'classId': 'c1', 'staffId': null},
  ];

  final List<Map<String, dynamic>> _staff = [
    {'id': 'f1', 'name': 'Dr. Smith'},
    {'id': 'f2', 'name': 'Prof. Johnson'},
    {'id': 'f3', 'name': 'Dr. Williams'},
  ];

  @override
  void initState() {
    super.initState();
    if (_classes.isNotEmpty) {
      _selectedClassId = _classes.first['id'];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final classSubjects = _subjects.where((s) => s['classId'] == _selectedClassId).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Class Subjects'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Manage Class Subjects',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add subjects to a specific class and assign faculty members.',
                      style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
                FilledButton.icon(
                  onPressed: () {
                    // Show add subject dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Add Subject dialog would open here')),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Subject'),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            // Class Selector
            Row(
              children: [
                const Text('Select Class:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: _selectedClassId,
                  items: _classes.map((c) {
                    return DropdownMenuItem<String>(
                      value: c['id'],
                      child: Text(c['name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedClassId = value;
                    });
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Subjects Grid
            Expanded(
              child: classSubjects.isEmpty 
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.book_outlined, size: 64, color: theme.colorScheme.outlineVariant),
                        const SizedBox(height: 16),
                        Text('No subjects added to this class yet.', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  )
                : GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: classSubjects.length,
                itemBuilder: (context, index) {
                  final subject = classSubjects[index];
                  
                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: theme.colorScheme.outlineVariant),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                subject['name'],
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Row(
                                children: [
                                  Text(
                                    subject['code'],
                                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12),
                                  ),
                                  const SizedBox(width: 8),
                                  InkWell(
                                    onTap: () {},
                                    child: Icon(Icons.delete_outline, size: 16, color: theme.colorScheme.error),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            hint: const Text('Unassigned Staff'),
                            value: subject['staffId'],
                            items: [
                              const DropdownMenuItem<String>(
                                value: null,
                                child: Text('Unassigned Staff'),
                              ),
                              ..._staff.map((s) {
                                return DropdownMenuItem<String>(
                                  value: s['id'],
                                  child: Text(s['name']),
                                );
                              }).toList(),
                            ],
                            onChanged: (value) {
                              setState(() {
                                final subIndex = _subjects.indexWhere((s) => s['id'] == subject['id']);
                                if (subIndex != -1) {
                                  _subjects[subIndex]['staffId'] = value;
                                }
                              });
                              
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Staff assigned successfully'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
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

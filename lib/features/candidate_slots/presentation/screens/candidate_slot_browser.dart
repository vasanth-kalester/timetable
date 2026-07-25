import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CandidateSlotBrowser extends ConsumerStatefulWidget {
  const CandidateSlotBrowser({super.key});

  @override
  ConsumerState<CandidateSlotBrowser> createState() => _CandidateSlotBrowserState();
}

class _CandidateSlotBrowserState extends ConsumerState<CandidateSlotBrowser> {
  String _searchQuery = '';
  String _selectedDay = 'All';
  String _selectedStatus = 'All';

  // Mock data
  final List<Map<String, dynamic>> _slots = [
    {
      'id': '1',
      'sessionCode': 'CS301-T1',
      'day': 'Monday',
      'period': 2,
      'room': 'Room 101',
      'faculty': 'Dr. Alan Turing',
      'penalty': 0,
      'status': 'Valid',
      'priority': 1,
    },
    {
      'id': '2',
      'sessionCode': 'CS301-T1',
      'day': 'Tuesday',
      'period': 3,
      'room': 'Room 102',
      'faculty': 'Dr. Alan Turing',
      'penalty': 8,
      'status': 'Valid',
      'priority': 2,
    },
    {
      'id': '3',
      'sessionCode': 'CS301-T1',
      'day': 'Wednesday',
      'period': 4,
      'room': 'Room 101',
      'faculty': 'Dr. Alan Turing',
      'penalty': 0,
      'status': 'Invalid',
      'priority': 0,
      'violation': 'Faculty Busy',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final filteredSlots = _slots.where((slot) {
      final matchesSearch = slot['sessionCode'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          slot['faculty'].toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesDay = _selectedDay == 'All' || slot['day'] == _selectedDay;
      final matchesStatus = _selectedStatus == 'All' || slot['status'] == _selectedStatus;
      return matchesSearch && matchesDay && matchesStatus;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Candidate Slot Browser'),
      ),
      body: Column(
        children: [
          // Filters & Search
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(bottom: BorderSide(color: theme.colorScheme.outlineVariant)),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search by session code or faculty...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                    onChanged: (value) => setState(() => _searchQuery = value),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedDay,
                    decoration: InputDecoration(
                      labelText: 'Day',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                    ),
                    items: ['All', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday']
                        .map((day) => DropdownMenuItem(value: day, child: Text(day)))
                        .toList(),
                    onChanged: (value) => setState(() => _selectedDay = value!),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    decoration: InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                    ),
                    items: ['All', 'Valid', 'Invalid']
                        .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                        .toList(),
                    onChanged: (value) => setState(() => _selectedStatus = value!),
                  ),
                ),
              ],
            ),
          ),
          
          // Data Table
          Expanded(
            child: filteredSlots.isEmpty
                ? const Center(child: Text('No candidate slots found.'))
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: theme.colorScheme.outlineVariant),
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingTextStyle: const TextStyle(fontWeight: FontWeight.bold),
                            columns: const [
                              DataColumn(label: Text('Session Code')),
                              DataColumn(label: Text('Day')),
                              DataColumn(label: Text('Period')),
                              DataColumn(label: Text('Room')),
                              DataColumn(label: Text('Faculty')),
                              DataColumn(label: Text('Penalty Score')),
                              DataColumn(label: Text('Status')),
                              DataColumn(label: Text('Actions')),
                            ],
                            rows: filteredSlots.map((slot) {
                              final isInvalid = slot['status'] == 'Invalid';
                              return DataRow(
                                cells: [
                                  DataCell(Text(slot['sessionCode'], style: const TextStyle(fontWeight: FontWeight.w500))),
                                  DataCell(Text(slot['day'])),
                                  DataCell(Text('P${slot['period']}')),
                                  DataCell(Text(slot['room'])),
                                  DataCell(Text(slot['faculty'])),
                                  DataCell(
                                    isInvalid 
                                      ? const Text('-', style: TextStyle(color: Colors.grey))
                                      : Text(slot['penalty'].toString(), style: TextStyle(
                                          color: slot['penalty'] == 0 ? Colors.green : Colors.orange,
                                          fontWeight: FontWeight.bold,
                                        )),
                                  ),
                                  DataCell(_buildStatusChip(slot['status'], isInvalid ? slot['violation'] : null, theme)),
                                  DataCell(
                                    IconButton(
                                      icon: const Icon(Icons.policy, size: 20),
                                      tooltip: 'Constraint Inspector',
                                      onPressed: () {
                                        // Navigate to constraint inspector
                                      },
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status, String? violation, ThemeData theme) {
    final isInvalid = status == 'Invalid';
    final color = isInvalid ? Colors.red : Colors.green;
    
    return Tooltip(
      message: violation ?? 'Valid Slot',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isInvalid ? Icons.cancel : Icons.check_circle, size: 14, color: color),
            const SizedBox(width: 6),
            Text(
              isInvalid ? 'Rejected' : 'Accepted',
              style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

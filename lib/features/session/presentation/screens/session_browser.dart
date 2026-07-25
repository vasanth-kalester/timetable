import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SessionBrowser extends ConsumerStatefulWidget {
  const SessionBrowser({super.key});

  @override
  ConsumerState<SessionBrowser> createState() => _SessionBrowserState();
}

class _SessionBrowserState extends ConsumerState<SessionBrowser> {
  String _searchQuery = '';
  String _selectedType = 'All';
  String _selectedStatus = 'All';

  // Mock data
  final List<Map<String, dynamic>> _sessions = [
    {
      'id': '1',
      'code': 'CS301-T1',
      'subject': 'Operating Systems',
      'faculty': 'Dr. Alan Turing',
      'section': 'CSBS A',
      'type': 'Theory',
      'duration': 1,
      'priority': 60,
      'status': 'Ready',
    },
    {
      'id': '2',
      'code': 'CS301-L1',
      'subject': 'Operating Systems Lab',
      'faculty': 'Dr. Alan Turing',
      'section': 'CSBS A',
      'type': 'Lab',
      'duration': 3,
      'priority': 100,
      'status': 'Ready',
    },
    {
      'id': '3',
      'code': 'MA201-T1',
      'subject': 'Discrete Mathematics',
      'faculty': 'Dr. John von Neumann',
      'section': 'CSBS A',
      'type': 'Theory',
      'duration': 1,
      'priority': 40,
      'status': 'Pending',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final filteredSessions = _sessions.where((session) {
      final matchesSearch = session['code'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          session['subject'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          session['faculty'].toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesType = _selectedType == 'All' || session['type'] == _selectedType;
      final matchesStatus = _selectedStatus == 'All' || session['status'] == _selectedStatus;
      return matchesSearch && matchesType && matchesStatus;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Session Browser'),
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
                      hintText: 'Search sessions by code, subject, or faculty...',
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
                    value: _selectedType,
                    decoration: InputDecoration(
                      labelText: 'Session Type',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                    ),
                    items: ['All', 'Theory', 'Lab', 'Tutorial', 'Project']
                        .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                        .toList(),
                    onChanged: (value) => setState(() => _selectedType = value!),
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
                    items: ['All', 'Ready', 'Pending', 'Validation Error']
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
            child: filteredSessions.isEmpty
                ? const Center(child: Text('No sessions found matching your criteria.'))
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
                              DataColumn(label: Text('Subject')),
                              DataColumn(label: Text('Faculty')),
                              DataColumn(label: Text('Section')),
                              DataColumn(label: Text('Type')),
                              DataColumn(label: Text('Duration')),
                              DataColumn(label: Text('Priority')),
                              DataColumn(label: Text('Status')),
                              DataColumn(label: Text('Actions')),
                            ],
                            rows: filteredSessions.map((session) {
                              return DataRow(
                                cells: [
                                  DataCell(Text(session['code'], style: const TextStyle(fontWeight: FontWeight.w500))),
                                  DataCell(Text(session['subject'])),
                                  DataCell(Text(session['faculty'])),
                                  DataCell(Text(session['section'])),
                                  DataCell(_buildTypeChip(session['type'], theme)),
                                  DataCell(Text('${session['duration']} hr(s)')),
                                  DataCell(Text(session['priority'].toString())),
                                  DataCell(_buildStatusChip(session['status'], theme)),
                                  DataCell(
                                    IconButton(
                                      icon: const Icon(Icons.visibility, size: 20),
                                      onPressed: () {
                                        // Navigate to session details
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

  Widget _buildTypeChip(String type, ThemeData theme) {
    Color color;
    switch (type) {
      case 'Theory': color = Colors.blue; break;
      case 'Lab': color = Colors.purple; break;
      case 'Tutorial': color = Colors.orange; break;
      default: color = Colors.grey;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        type,
        style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildStatusChip(String status, ThemeData theme) {
    Color color;
    switch (status) {
      case 'Ready': color = Colors.green; break;
      case 'Pending': color = Colors.orange; break;
      default: color = Colors.red;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            status,
            style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

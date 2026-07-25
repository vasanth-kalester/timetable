import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SessionDetailsScreen extends ConsumerWidget {
  final String sessionId;
  
  const SessionDetailsScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Mock data for the session
    final session = {
      'id': sessionId,
      'code': 'CS301-L1',
      'subject': 'Operating Systems Lab',
      'faculty': 'Dr. Alan Turing',
      'section': 'CSBS A',
      'type': 'Lab',
      'duration': 3,
      'priority': 100,
      'status': 'Ready',
      'department': 'Computer Science',
      'program': 'B.Tech CSBS',
      'semester': 'Semester 5',
      'laboratory': 'Lab 4 (Turing Lab)',
      'studentGroup': 'All',
      'createdAt': '2026-07-25 10:00 AM',
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(session['code'] as String),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session['subject'] as String,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Session ID: ${session['id']}',
                      style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
                _buildStatusChip(session['status'] as String, theme),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Details Grid
            Card(
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
                    const Text(
                      'Session Details',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(child: _buildDetailItem('Type', session['type'] as String, Icons.category, theme)),
                        Expanded(child: _buildDetailItem('Duration', '${session['duration']} hr(s)', Icons.timer, theme)),
                        Expanded(child: _buildDetailItem('Priority', session['priority'].toString(), Icons.priority_high, theme)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(child: _buildDetailItem('Faculty', session['faculty'] as String, Icons.person, theme)),
                        Expanded(child: _buildDetailItem('Section', session['section'] as String, Icons.group, theme)),
                        Expanded(child: _buildDetailItem('Student Group', session['studentGroup'] as String, Icons.groups, theme)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(child: _buildDetailItem('Department', session['department'] as String, Icons.domain, theme)),
                        Expanded(child: _buildDetailItem('Program', session['program'] as String, Icons.school, theme)),
                        Expanded(child: _buildDetailItem('Semester', session['semester'] as String, Icons.calendar_today, theme)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(child: _buildDetailItem('Laboratory', session['laboratory'] as String, Icons.science, theme)),
                        Expanded(child: _buildDetailItem('Created At', session['createdAt'] as String, Icons.access_time, theme)),
                        const Expanded(child: SizedBox()),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Resource Requirements
            const Text(
              'Resource Requirements',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildResourceRow('Faculty Required', session['faculty'] as String, Icons.person, true, theme),
                    const Divider(),
                    _buildResourceRow('Classroom/Lab Required', session['laboratory'] as String, Icons.room, true, theme),
                    const Divider(),
                    _buildResourceRow('Duration Block', '${session['duration']} consecutive periods', Icons.view_week, true, theme),
                  ],
                ),
              ),
            ),
          ],
        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            status,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon, ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResourceRow(String label, String value, IconData icon, bool isMet, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
                Text(value, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          Icon(
            isMet ? Icons.check_circle : Icons.cancel,
            color: isMet ? Colors.green : Colors.red,
          ),
        ],
      ),
    );
  }
}

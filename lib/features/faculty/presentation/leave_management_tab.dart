import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/faculty_provider.dart';

class LeaveManagementTab extends ConsumerWidget {
  final String facultyId;

  const LeaveManagementTab({super.key, required this.facultyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leavesAsyncValue = ref.watch(leavesProvider(facultyId));

    return leavesAsyncValue.when(
      data: (leaves) {
        if (leaves.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('No leave records found.'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Implement add leave
                  },
                  child: const Text('Apply for Leave'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: leaves.length,
          itemBuilder: (context, index) {
            final leave = leaves[index];
            final startDate = DateTime.fromMillisecondsSinceEpoch(leave.startDate);
            final endDate = DateTime.fromMillisecondsSinceEpoch(leave.endDate);
            final dateFormat = DateFormat('MMM dd, yyyy');
            
            return Card(
              child: ListTile(
                title: Text(leave.leaveType),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${dateFormat.format(startDate)} - ${dateFormat.format(endDate)}'),
                    if (leave.reason != null) Text('Reason: ${leave.reason}'),
                  ],
                ),
                trailing: Chip(
                  label: Text(
                    leave.status,
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: _getStatusColor(leave.status),
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Text('Error: $error'),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green.shade100;
      case 'rejected':
        return Colors.red.shade100;
      case 'pending':
      default:
        return Colors.orange.shade100;
    }
  }
}

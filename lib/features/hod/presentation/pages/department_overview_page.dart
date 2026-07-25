import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../academic/application/providers/academic_providers.dart';
import '../../../academic/data/models/academic_models.dart';

class DepartmentOverviewPage extends ConsumerWidget {
  final String departmentId;

  const DepartmentOverviewPage({super.key, required this.departmentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncDepartments = ref.watch(departmentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Department Overview'),
      ),
      body: asyncDepartments.when(
        data: (departments) {
          final dept = departments.firstWhere((d) => d.id == departmentId, orElse: () => Department(id: '', name: 'Unknown', code: '', status: '', readinessStatus: ''));
          return _buildDashboard(context, ref, dept);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, WidgetRef ref, Department dept) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildHeader(dept),
        const SizedBox(height: 24),
        _buildReadinessCard(dept),
        const SizedBox(height: 24),
        _buildMetricsGrid(ref, dept.id),
      ],
    );
  }

  Widget _buildHeader(Department dept) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(dept.name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        Text('Code: ${dept.code}', style: const TextStyle(fontSize: 16, color: Colors.grey)),
      ],
    );
  }

  Widget _buildReadinessCard(Department dept) {
    Color statusColor;
    switch (dept.readinessStatus) {
      case 'ready':
      case 'frozen':
        statusColor = Colors.green;
        break;
      case 'configured':
        statusColor = Colors.orange;
        break;
      default:
        statusColor = Colors.red;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Readiness Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Chip(
                  label: Text(dept.readinessStatus.toUpperCase(), style: const TextStyle(color: Colors.white)),
                  backgroundColor: statusColor,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const LinearProgressIndicator(value: 0.75), // Mock progress
            const SizedBox(height: 8),
            const Text('75% Complete - Pending Home Classrooms'),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsGrid(WidgetRef ref, String deptId) {
    final asyncPrograms = ref.watch(programsProvider(deptId));

    return asyncPrograms.when(
      data: (programs) => GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 2,
        children: [
          _buildMetricCard('Programs', programs.length.toString(), Icons.school),
          _buildMetricCard('Faculty', 'Pending', Icons.people),
          _buildMetricCard('Classrooms', 'Pending', Icons.meeting_room),
          _buildMetricCard('Laboratories', 'Pending', Icons.science),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Text('Error: $err'),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 32, color: Colors.blue),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                Text(title, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

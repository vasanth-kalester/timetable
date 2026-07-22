import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/academic_provider.dart';
import '../../../../core/widgets/status_badge.dart';

class DepartmentListPage extends ConsumerWidget {
  const DepartmentListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(academicProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Department Directory'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${state.departments.length} Configured Departments',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.departments.length,
              itemBuilder: (context, index) {
                final dept = state.departments[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.indigo.withOpacity(0.2),
                      child: Text(dept.code, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.indigoAccent)),
                    ),
                    title: Text(dept.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('HOD: ${dept.hodName} • Contact: ${dept.email}'),
                    trailing: StatusBadge(
                      label: dept.isActive ? 'Active' : 'Inactive',
                      type: dept.isActive ? StatusBadgeType.success : StatusBadgeType.neutral,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

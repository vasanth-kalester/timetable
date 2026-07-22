import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/academic_provider.dart';
import '../widgets/csv_import_dialog.dart';
import '../../../../core/widgets/app_text_field.dart';

class StudentDirectoryPage extends ConsumerStatefulWidget {
  const StudentDirectoryPage({super.key});

  @override
  ConsumerState<StudentDirectoryPage> createState() => _StudentDirectoryPageState();
}

class _StudentDirectoryPageState extends ConsumerState<StudentDirectoryPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(academicProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Directory'),
        actions: [
          ElevatedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => const CsvImportDialog(),
              );
            },
            icon: const Icon(Icons.upload_file_rounded, size: 16),
            label: const Text('CSV Import'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Instant Search Input
            AppTextField(
              label: 'Global Instant Student Search',
              hint: 'Search by student name, roll number, or register number...',
              controller: _searchController,
              prefixIcon: Icons.search_rounded,
              onChanged: (query) {
                ref.read(academicProvider.notifier).setSearchQuery(query);
              },
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${state.students.length} Enrolled Students Found',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (state.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (state.students.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text('No student records matched your search query.'),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.students.length,
                itemBuilder: (context, index) {
                  final student = state.students[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.green.withOpacity(0.2),
                        child: Text(
                          student.fullName[0],
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.greenAccent),
                        ),
                      ),
                      title: Text(student.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        'Roll: ${student.rollNumber} • Register: ${student.registerNumber} • ${student.semesterId} (${student.sectionId.toUpperCase()})',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.indigo.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          student.departmentId.toUpperCase(),
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.indigoAccent),
                        ),
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/faculty_provider.dart';
import 'faculty_details_screen.dart';

class FacultyListScreen extends ConsumerWidget {
  const FacultyListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final facultiesAsyncValue = ref.watch(facultyListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Faculty Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implement search functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Implement filter functionality
            },
          ),
        ],
      ),
      body: facultiesAsyncValue.when(
        data: (faculties) {
          if (faculties.isEmpty) {
            return const Center(child: Text('No faculty found.'));
          }
          return ListView.builder(
            itemCount: faculties.length,
            itemBuilder: (context, index) {
              final faculty = faculties[index];
              return ListTile(
                leading: CircleAvatar(
                  child: Text(faculty.name[0]),
                ),
                title: Text(faculty.name),
                subtitle: Text('${faculty.designation ?? 'Faculty'} • ${faculty.departmentId}'),
                trailing: Chip(
                  label: Text(
                    faculty.status,
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: faculty.status == 'Active' ? Colors.green.shade100 : Colors.grey.shade200,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FacultyDetailsScreen(facultyId: faculty.id),
                    ),
                  );
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Error: $error'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Implement create faculty functionality
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

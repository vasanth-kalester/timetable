import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/academic_provider.dart';
import '../../timetable/domain/models/scheduling_models.dart';

class SubjectDirectoryPage extends ConsumerWidget {
  const SubjectDirectoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(academicProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Curriculum & Subject Matrix'),
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
                  '${state.subjects.length} Registered Subjects',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.subjects.length,
              itemBuilder: (context, index) {
                final sub = state.subjects[index];
                final isLab = sub.requiredRoomType == RoomType.lab;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isLab ? Colors.purple.withOpacity(0.2) : Colors.indigo.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        isLab ? Icons.biotech_rounded : Icons.menu_book_rounded,
                        color: isLab ? Colors.purpleAccent : Colors.indigoAccent,
                        size: 20,
                      ),
                    ),
                    title: Text('${sub.code}: ${sub.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      'Semester: ${sub.semesterId} • Theory: ${sub.theoryHours} hrs • Lab: ${sub.practicalHours} hrs • Credits: ${sub.totalCredits}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isLab ? Colors.purple.withOpacity(0.15) : Colors.indigo.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isLab ? 'PRACTICAL LAB' : 'THEORY CORE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isLab ? Colors.purpleAccent : Colors.indigoAccent,
                        ),
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

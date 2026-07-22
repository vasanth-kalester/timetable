import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/academic_provider.dart';
import '../widgets/academic_stat_card.dart';
import '../widgets/csv_import_dialog.dart';
import 'department_list_page.dart';
import 'subject_directory_page.dart';
import 'faculty_directory_page.dart';
import 'student_directory_page.dart';
import 'section_curriculum_page.dart';

class AcademicDashboardPage extends ConsumerWidget {
  const AcademicDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(academicProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page Title & Header Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Academic Management Core', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      'Configure institutional hierarchy, curriculum, credit matrix, and faculty allocations.',
                      style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => const CsvImportDialog(),
                    );
                  },
                  icon: const Icon(Icons.upload_file_rounded, size: 18),
                  label: const Text('Bulk CSV Import'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Metrics Row
            Row(
              children: [
                Expanded(
                  child: AcademicStatCard(
                    title: 'Departments',
                    value: '${state.departments.length}',
                    icon: Icons.business_rounded,
                    color: Colors.indigoAccent,
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DepartmentListPage()));
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AcademicStatCard(
                    title: 'Subjects & Labs',
                    value: '${state.subjects.length}',
                    icon: Icons.menu_book_rounded,
                    color: Colors.purpleAccent,
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SubjectDirectoryPage()));
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AcademicStatCard(
                    title: 'Enrolled Students',
                    value: '${state.students.length}',
                    icon: Icons.people_alt_rounded,
                    color: Colors.greenAccent,
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const StudentDirectoryPage()));
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AcademicStatCard(
                    title: 'Faculty Members',
                    value: '${state.faculty.length}',
                    icon: Icons.badge_rounded,
                    color: Colors.amberAccent,
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FacultyDirectoryPage()));
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Directories Shortcuts Grid
            const Text('Academic Directories & Management', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              childAspectRatio: 2.2,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildDirectoryTile(
                  context,
                  title: 'Department Directory',
                  subtitle: 'HOD assignment, codes, and contact info',
                  icon: Icons.apartment_rounded,
                  color: Colors.indigoAccent,
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DepartmentListPage()));
                  },
                ),
                _buildDirectoryTile(
                  context,
                  title: 'Curriculum & Credit Matrix',
                  subtitle: 'Theory, lab hours, and elective specifications',
                  icon: Icons.auto_stories_rounded,
                  color: Colors.purpleAccent,
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SubjectDirectoryPage()));
                  },
                ),
                _buildDirectoryTile(
                  context,
                  title: 'Faculty Directory & Workload',
                  subtitle: 'Max weekly load, specialization, and availability',
                  icon: Icons.work_history_rounded,
                  color: Colors.amberAccent,
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FacultyDirectoryPage()));
                  },
                ),
                _buildDirectoryTile(
                  context,
                  title: 'Student Directory & Search',
                  subtitle: 'Roll numbers, semesters, and sections',
                  icon: Icons.school_rounded,
                  color: Colors.greenAccent,
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const StudentDirectoryPage()));
                  },
                ),
                _buildDirectoryTile(
                  context,
                  title: 'Faculty Subject Assignments',
                  subtitle: 'Section allocations and workload balancing',
                  icon: Icons.assignment_ind_rounded,
                  color: Colors.blueAccent,
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SectionCurriculumPage()));
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDirectoryTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

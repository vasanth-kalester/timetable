import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/academic_entities.dart';
import '../../application/providers/academic_provider.dart';
import '../../../../core/widgets/app_button.dart';
import 'package:eduflow/features/timetable/domain/models/scheduling_models.dart';

class SectionCurriculumPage extends ConsumerStatefulWidget {
  const SectionCurriculumPage({super.key});

  @override
  ConsumerState<SectionCurriculumPage> createState() => _SectionCurriculumPageState();
}

class _SectionCurriculumPageState extends ConsumerState<SectionCurriculumPage> {
  String? _selectedFacultyId;
  String? _selectedSubjectId;
  String _selectedSection = 'Section A';
  int _weeklyHours = 4;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(academicProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Faculty Subject Assignment'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (state.errorMessage != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade900.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        state.errorMessage!,
                        style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Assignment Form Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('New Faculty Subject Allocation', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),

                    // Faculty Dropdown
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Select Faculty Member', border: OutlineInputBorder()),
                      value: _selectedFacultyId,
                      items: state.faculty.map((fac) {
                        return DropdownMenuItem(
                          value: fac.id,
                          child: Text('${fac.name} (${fac.maxHoursPerWeek} hrs max load)'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedFacultyId = val;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Subject Dropdown
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Select Subject', border: OutlineInputBorder()),
                      value: _selectedSubjectId,
                      items: state.subjects.map((sub) {
                        return DropdownMenuItem(
                          value: sub.id,
                          child: Text('${sub.code}: ${sub.name} (${sub.semesterId})'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedSubjectId = val;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(labelText: 'Target Section', border: OutlineInputBorder()),
                            value: _selectedSection,
                            items: const [
                              DropdownMenuItem(value: 'Section A', child: Text('Section A')),
                              DropdownMenuItem(value: 'Section B', child: Text('Section B')),
                              DropdownMenuItem(value: 'Section C', child: Text('Section C')),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedSection = val;
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            initialValue: '4',
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Weekly Hours', border: OutlineInputBorder()),
                            onChanged: (val) {
                              _weeklyHours = int.tryParse(val) ?? 4;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    AppButton(
                      label: 'Allocate Faculty Subject',
                      isLoading: _isSubmitting,
                      onPressed: _selectedFacultyId == null || _selectedSubjectId == null
                          ? null
                          : () async {
                              setState(() {
                                _isSubmitting = true;
                              });

                              final success = await ref.read(academicProvider.notifier).assignFaculty(
                                    FacultyAssignmentEntity(
                                      id: 'assgn_${DateTime.now().millisecondsSinceEpoch}',
                                      facultyId: _selectedFacultyId!,
                                      subjectId: _selectedSubjectId!,
                                      sectionId: _selectedSection,
                                      weeklyHours: _weeklyHours,
                                    ),
                                  );

                              setState(() {
                                _isSubmitting = false;
                              });

                              if (success && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Faculty subject assigned successfully!')),
                                );
                              }
                            },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Active Allocations List
            Text(
              '${state.assignments.length} Active Faculty Allocations',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (state.assignments.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No faculty allocations created yet.'),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.assignments.length,
                itemBuilder: (context, index) {
                  final a = state.assignments[index];
                  final faculty = state.faculty.firstWhere((f) => f.id == a.facultyId,
                      orElse: () => FacultyEntity(id: a.facultyId, name: 'Faculty', departmentId: ''));
                  final subject = state.subjects.firstWhere((s) => s.id == a.subjectId,
                      orElse: () => const SubjectEntity(id: 's', code: 'SUB', name: 'Subject', departmentId: '', semesterId: '', lectureCredits: 3));

                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: const Icon(Icons.assignment_turned_in_rounded, color: Colors.greenAccent),
                      title: Text('${subject.code}: ${subject.name} (${a.sectionId})'),
                      subtitle: Text('Faculty: ${faculty.name} • Load: ${a.weeklyHours} hrs/week'),
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/academic_providers.dart';
import '../models/academic_models.dart';

class AcademicStructurePage extends ConsumerStatefulWidget {
  const AcademicStructurePage({super.key});

  @override
  ConsumerState<AcademicStructurePage> createState() => _AcademicStructurePageState();
}

class _AcademicStructurePageState extends ConsumerState<AcademicStructurePage> {
  String? selectedDepartmentId;
  String? selectedProgramId;
  String? selectedSemesterId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Academic Structure Builder'),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Departments Column
          Expanded(
            child: _buildColumn<Department>(
              title: 'Departments',
              provider: departmentsProvider,
              selectedId: selectedDepartmentId,
              onSelect: (id) => setState(() {
                selectedDepartmentId = id;
                selectedProgramId = null;
                selectedSemesterId = null;
              }),
              itemBuilder: (dept) => ListTile(
                title: Text(dept.name),
                subtitle: Text(dept.code),
                selected: selectedDepartmentId == dept.id,
                onTap: () => setState(() {
                  selectedDepartmentId = dept.id;
                  selectedProgramId = null;
                  selectedSemesterId = null;
                }),
              ),
              onAdd: () => _showAddDepartmentDialog(context),
            ),
          ),
          const VerticalDivider(width: 1),

          // Programs Column
          Expanded(
            child: selectedDepartmentId == null
                ? const Center(child: Text('Select a department'))
                : _buildColumn<Program>(
                    title: 'Programs',
                    provider: programsProvider(selectedDepartmentId),
                    selectedId: selectedProgramId,
                    onSelect: (id) => setState(() {
                      selectedProgramId = id;
                      selectedSemesterId = null;
                    }),
                    itemBuilder: (prog) => ListTile(
                      title: Text(prog.name),
                      subtitle: Text('${prog.degree} • ${prog.durationYears} Years'),
                      selected: selectedProgramId == prog.id,
                      onTap: () => setState(() {
                        selectedProgramId = prog.id;
                        selectedSemesterId = null;
                      }),
                    ),
                    onAdd: () => _showAddProgramDialog(context, selectedDepartmentId!),
                  ),
          ),
          const VerticalDivider(width: 1),

          // Semesters Column
          Expanded(
            child: selectedProgramId == null
                ? const Center(child: Text('Select a program'))
                : _buildColumn<Semester>(
                    title: 'Semesters',
                    provider: semestersProvider(selectedProgramId),
                    selectedId: selectedSemesterId,
                    onSelect: (id) => setState(() {
                      selectedSemesterId = id;
                    }),
                    itemBuilder: (sem) => ListTile(
                      title: Text(sem.name),
                      selected: selectedSemesterId == sem.id,
                      onTap: () => setState(() {
                        selectedSemesterId = sem.id;
                      }),
                    ),
                    onAdd: () => _showAddSemesterDialog(context, selectedProgramId!),
                  ),
          ),
          const VerticalDivider(width: 1),

          // Sections Column
          Expanded(
            child: selectedSemesterId == null
                ? const Center(child: Text('Select a semester'))
                : _buildColumn<Section>(
                    title: 'Sections',
                    provider: sectionsProvider(selectedSemesterId),
                    selectedId: null,
                    onSelect: (_) {},
                    itemBuilder: (sec) => ListTile(
                      title: Text('Section ${sec.name}'),
                      subtitle: Text('Intake: ${sec.intake}'),
                    ),
                    onAdd: () => _showAddSectionDialog(context, selectedSemesterId!),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildColumn<T>({
    required String title,
    required AutoDisposeFutureProvider<List<T>> provider,
    required String? selectedId,
    required Function(String) onSelect,
    required Widget Function(T) itemBuilder,
    required VoidCallback onAdd,
  }) {
    final asyncValue = ref.watch(provider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              IconButton(icon: const Icon(Icons.add), onPressed: onAdd),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: asyncValue.when(
            data: (items) => items.isEmpty
                ? const Center(child: Text('No items found'))
                : ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) => itemBuilder(items[index]),
                  ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error: $err')),
          ),
        ),
      ],
    );
  }

  // Dialogs for adding entities (simplified for brevity)
  void _showAddDepartmentDialog(BuildContext context) {
    // TODO: Implement dialog
  }

  void _showAddProgramDialog(BuildContext context, String departmentId) {
    // TODO: Implement dialog
  }

  void _showAddSemesterDialog(BuildContext context, String programId) {
    // TODO: Implement dialog
  }

  void _showAddSectionDialog(BuildContext context, String semesterId) {
    // TODO: Implement dialog
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/academic_entities.dart';
import '../../domain/repositories/academic_repository.dart';
import '../../data/repositories/academic_repository_impl.dart';
import '../../../timetable/domain/models/scheduling_models.dart';

final academicRepositoryProvider = Provider<AcademicRepository>((ref) {
  return AcademicRepositoryImpl();
});

class AcademicState {
  final bool isLoading;
  final String? errorMessage;
  final List<DepartmentEntity> departments;
  final List<ProgramEntity> programs;
  final List<SubjectEntity> subjects;
  final List<StudentRecordEntity> students;
  final List<FacultyEntity> faculty;
  final List<FacultyAssignmentEntity> assignments;
  final String searchQuery;
  final String? selectedDepartmentId;

  const AcademicState({
    this.isLoading = false,
    this.errorMessage,
    this.departments = const [],
    this.programs = const [],
    this.subjects = const [],
    this.students = const [],
    this.faculty = const [],
    this.assignments = const [],
    this.searchQuery = '',
    this.selectedDepartmentId,
  });

  AcademicState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<DepartmentEntity>? departments,
    List<ProgramEntity>? programs,
    List<SubjectEntity>? subjects,
    List<StudentRecordEntity>? students,
    List<FacultyEntity>? faculty,
    List<FacultyAssignmentEntity>? assignments,
    String? searchQuery,
    String? selectedDepartmentId,
  }) {
    return AcademicState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      departments: departments ?? this.departments,
      programs: programs ?? this.programs,
      subjects: subjects ?? this.subjects,
      students: students ?? this.students,
      faculty: faculty ?? this.faculty,
      assignments: assignments ?? this.assignments,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedDepartmentId: selectedDepartmentId ?? this.selectedDepartmentId,
    );
  }
}

final academicProvider = StateNotifierProvider<AcademicNotifier, AcademicState>((ref) {
  final repo = ref.watch(academicRepositoryProvider);
  return AcademicNotifier(repo);
});

class AcademicNotifier extends StateNotifier<AcademicState> {
  final AcademicRepository _repository;

  AcademicNotifier(this._repository) : super(const AcademicState()) {
    loadAcademicData();
  }

  Future<void> loadAcademicData() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final depts = await _repository.getDepartments();
    final progs = await _repository.getPrograms();
    final subs = await _repository.getSubjects();
    final stds = await _repository.getStudents(
      searchQuery: state.searchQuery,
      departmentId: state.selectedDepartmentId,
    );
    final facs = await _repository.getFacultyList();
    final assgns = await _repository.getFacultyAssignments();

    state = state.copyWith(
      isLoading: false,
      departments: depts,
      programs: progs,
      subjects: subs,
      students: stds,
      faculty: facs,
      assignments: assgns,
    );
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    loadAcademicData();
  }

  void selectDepartment(String? deptId) {
    state = state.copyWith(selectedDepartmentId: deptId);
    loadAcademicData();
  }

  Future<bool> addSubject(SubjectEntity subject) async {
    final failure = await _repository.addSubject(subject);
    if (failure != null) {
      state = state.copyWith(errorMessage: failure.message);
      return false;
    }
    await loadAcademicData();
    return true;
  }

  Future<bool> addStudent(StudentRecordEntity student) async {
    final failure = await _repository.addStudent(student);
    if (failure != null) {
      state = state.copyWith(errorMessage: failure.message);
      return false;
    }
    await loadAcademicData();
    return true;
  }

  Future<(int count, List<String> errors)> importStudents(List<StudentRecordEntity> list) async {
    final result = await _repository.bulkImportStudents(list);
    await loadAcademicData();
    return result;
  }

  Future<bool> assignFaculty(FacultyAssignmentEntity assignment) async {
    final failure = await _repository.assignFaculty(assignment);
    if (failure != null) {
      state = state.copyWith(errorMessage: failure.message);
      return false;
    }
    await loadAcademicData();
    return true;
  }
}

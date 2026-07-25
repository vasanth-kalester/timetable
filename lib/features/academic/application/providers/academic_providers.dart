import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/api_client.dart';
import '../repositories/academic_repository.dart';
import '../models/academic_models.dart';

final academicRepositoryProvider = Provider<AcademicRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AcademicRepository(apiClient: apiClient);
});

final academicYearsProvider = FutureProvider<List<AcademicYear>>((ref) async {
  final repo = ref.watch(academicRepositoryProvider);
  final (years, failure) = await repo.getAcademicYears();
  if (failure != null) throw failure;
  return years ?? [];
});

final departmentsProvider = FutureProvider<List<Department>>((ref) async {
  final repo = ref.watch(academicRepositoryProvider);
  final (departments, failure) = await repo.getDepartments();
  if (failure != null) throw failure;
  return departments ?? [];
});

final programsProvider = FutureProvider.family<List<Program>, String?>((ref, departmentId) async {
  final repo = ref.watch(academicRepositoryProvider);
  final (programs, failure) = await repo.getPrograms(departmentId: departmentId);
  if (failure != null) throw failure;
  return programs ?? [];
});

final semestersProvider = FutureProvider.family<List<Semester>, String?>((ref, programId) async {
  final repo = ref.watch(academicRepositoryProvider);
  final (semesters, failure) = await repo.getSemesters(programId: programId);
  if (failure != null) throw failure;
  return semesters ?? [];
});

final sectionsProvider = FutureProvider.family<List<Section>, String?>((ref, semesterId) async {
  final repo = ref.watch(academicRepositoryProvider);
  final (sections, failure) = await repo.getSections(semesterId: semesterId);
  if (failure != null) throw failure;
  return sections ?? [];
});

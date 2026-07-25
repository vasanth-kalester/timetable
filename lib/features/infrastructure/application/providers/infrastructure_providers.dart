import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/api_client.dart';
import '../repositories/infrastructure_repository.dart';
import '../models/infrastructure_models.dart';
import '../models/period_template.dart';

final infrastructureRepositoryProvider = Provider<InfrastructureRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return InfrastructureRepository(apiClient: apiClient);
});

final buildingsProvider = FutureProvider<List<Building>>((ref) async {
  final repo = ref.watch(infrastructureRepositoryProvider);
  final (buildings, failure) = await repo.getBuildings();
  if (failure != null) throw failure;
  return buildings ?? [];
});

final classroomsProvider = FutureProvider.family<List<Classroom>, String?>((ref, buildingId) async {
  final repo = ref.watch(infrastructureRepositoryProvider);
  final (classrooms, failure) = await repo.getClassrooms(buildingId: buildingId);
  if (failure != null) throw failure;
  return classrooms ?? [];
});

final laboratoriesProvider = FutureProvider.family<List<Laboratory>, String?>((ref, departmentId) async {
  final repo = ref.watch(infrastructureRepositoryProvider);
  final (laboratories, failure) = await repo.getLaboratories(departmentId: departmentId);
  if (failure != null) throw failure;
  return laboratories ?? [];
});

final workingDaysProvider = FutureProvider<List<WorkingDay>>((ref) async {
  final repo = ref.watch(infrastructureRepositoryProvider);
  final (workingDays, failure) = await repo.getWorkingDays();
  if (failure != null) throw failure;
  return workingDays ?? [];
});

final periodTemplatesProvider = FutureProvider<List<PeriodTemplate>>((ref) async {
  final repo = ref.watch(infrastructureRepositoryProvider);
  final (templates, failure) = await repo.getPeriodTemplates();
  if (failure != null) throw failure;
  return templates ?? [];
});

final periodsProvider = FutureProvider<List<PeriodConfiguration>>((ref) async {
  final repo = ref.watch(infrastructureRepositoryProvider);
  final (periods, failure) = await repo.getPeriods();
  if (failure != null) throw failure;
  return periods ?? [];
});

final policiesProvider = FutureProvider<List<InstitutionPolicy>>((ref) async {
  final repo = ref.watch(infrastructureRepositoryProvider);
  final (policies, failure) = await repo.getPolicies();
  if (failure != null) throw failure;
  return policies ?? [];
});

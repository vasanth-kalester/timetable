import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/faculty.dart';
import '../repositories/faculty_repository.dart';

final facultyListProvider = FutureProvider.autoDispose<List<Faculty>>((ref) async {
  final repository = ref.watch(facultyRepositoryProvider);
  final result = await repository.getFaculties();
  return result.fold(
    (failure) => throw failure,
    (faculties) => faculties,
  );
});

final facultyDetailProvider = FutureProvider.family.autoDispose<Faculty, String>((ref, facultyId) async {
  final repository = ref.watch(facultyRepositoryProvider);
  final result = await repository.getFaculty(facultyId);
  return result.fold(
    (failure) => throw failure,
    (faculty) => faculty,
  );
});

final schedulingProfileProvider = FutureProvider.family.autoDispose<SchedulingProfile, String>((ref, facultyId) async {
  final repository = ref.watch(facultyRepositoryProvider);
  final result = await repository.getSchedulingProfile(facultyId);
  return result.fold(
    (failure) => throw failure,
    (profile) => profile,
  );
});

final availabilityProvider = FutureProvider.family.autoDispose<List<Availability>>((ref, facultyId) async {
  final repository = ref.watch(facultyRepositoryProvider);
  final result = await repository.getAvailability(facultyId);
  return result.fold(
    (failure) => throw failure,
    (availability) => availability,
  );
});

final leavesProvider = FutureProvider.family.autoDispose<List<Leave>>((ref, facultyId) async {
  final repository = ref.watch(facultyRepositoryProvider);
  final result = await repository.getLeaves(facultyId);
  return result.fold(
    (failure) => throw failure,
    (leaves) => leaves,
  );
});

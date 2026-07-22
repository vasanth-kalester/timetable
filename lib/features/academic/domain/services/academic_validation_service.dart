import '../entities/academic_entities.dart';
import '../../../timetable/domain/models/scheduling_models.dart';
import '../../../../core/utils/app_failure.dart';

class AcademicValidationService {
  /// Validates a candidate student record against existing students.
  static ValidationFailure? validateStudent({
    required StudentRecordEntity candidate,
    required List<StudentRecordEntity> existingStudents,
  }) {
    for (final s in existingStudents) {
      if (s.id != candidate.id && s.rollNumber.trim().toLowerCase() == candidate.rollNumber.trim().toLowerCase()) {
        return ValidationFailure('Duplicate Roll Number: Roll number "${candidate.rollNumber}" is already registered.');
      }
      if (s.id != candidate.id && s.registerNumber.trim().toLowerCase() == candidate.registerNumber.trim().toLowerCase()) {
        return ValidationFailure('Duplicate Register Number: Register number "${candidate.registerNumber}" already exists.');
      }
    }
    return null;
  }

  /// Validates a candidate subject code against existing subjects.
  static ValidationFailure? validateSubject({
    required SubjectEntity candidate,
    required List<SubjectEntity> existingSubjects,
  }) {
    for (final sub in existingSubjects) {
      if (sub.id != candidate.id && sub.code.trim().toLowerCase() == candidate.code.trim().toLowerCase()) {
        return ValidationFailure('Duplicate Subject Code: Subject code "${candidate.code}" already exists.');
      }
    }
    return null;
  }

  /// Validates faculty workload before assigning a new subject session.
  static ValidationFailure? validateFacultyAssignment({
    required FacultyAssignmentEntity candidate,
    required FacultyEntity faculty,
    required List<FacultyAssignmentEntity> existingAssignments,
  }) {
    // Check 1: Duplicate assignment for same subject + section
    for (final a in existingAssignments) {
      if (a.id != candidate.id && a.subjectId == candidate.subjectId && a.sectionId == candidate.sectionId) {
        return const ValidationFailure('Duplicate Assignment: This subject is already assigned to the selected section.');
      }
    }

    // Check 2: Max weekly hours check
    final currentWeeklyHours = existingAssignments
        .where((a) => a.facultyId == faculty.id && a.id != candidate.id)
        .fold(0, (sum, a) => sum + a.weeklyHours);

    if (currentWeeklyHours + candidate.weeklyHours > faculty.maxHoursPerWeek) {
      return ValidationFailure(
        'Faculty Overload: Assigning ${candidate.weeklyHours} hrs to ${faculty.name} total ${currentWeeklyHours + candidate.weeklyHours} hrs, exceeding maximum limit of ${faculty.maxHoursPerWeek} hrs/week.',
      );
    }

    return null;
  }
}

import 'package:eduflow/features/timetable/domain/models/scheduling_models.dart';
import 'package:eduflow/features/infrastructure/domain/models/infrastructure_models.dart';

enum ExamType {
  midSemester,
  endSemester,
  practical,
  internal,
  viva
}

enum ExamTimetableStatus {
  draft,
  published,
  archived
}

class ExamSession {
  final String id;
  final ExamType examType;
  final String subjectId;
  final String departmentId;
  final String semesterId;
  final DateTime date;
  final int startTimeMinutes; // e.g., 540 for 09:00 AM
  final int durationMinutes;
  final int expectedStudentCount;

  const ExamSession({
    required this.id,
    required this.examType,
    required this.subjectId,
    required this.departmentId,
    required this.semesterId,
    required this.date,
    required this.startTimeMinutes,
    required this.durationMinutes,
    required this.expectedStudentCount,
  });
}

class ExamTimetable {
  final String id;
  final String name;
  final List<ExamSession> sessions;
  final ExamTimetableStatus status;

  const ExamTimetable({
    required this.id,
    required this.name,
    required this.sessions,
    required this.status,
  });
}

enum AllocationStatus {
  pending,
  confirmed
}

class HallAllocation {
  final String id;
  final String examSessionId;
  final String roomId;
  final List<String> allocatedStudentIds;
  
  const HallAllocation({
    required this.id,
    required this.examSessionId,
    required this.roomId,
    required this.allocatedStudentIds,
  });
}

class InvigilatorAssignment {
  final String id;
  final String hallAllocationId;
  final String facultyId;
  final AllocationStatus status;

  const InvigilatorAssignment({
    required this.id,
    required this.hallAllocationId,
    required this.facultyId,
    required this.status,
  });
}

enum AssessmentType {
  assignment,
  quiz,
  project,
  labRecord,
  exam
}

class GradeRecord {
  final String id;
  final String studentId;
  final String subjectId;
  final double internalMarks; // Out of e.g., 40
  final double externalMarks; // Out of e.g., 60
  
  const GradeRecord({
    required this.id,
    required this.studentId,
    required this.subjectId,
    required this.internalMarks,
    required this.externalMarks,
  });
  
  double get totalMarks => internalMarks + externalMarks;
}

class SemesterRecord {
  final String semesterId;
  final List<GradeRecord> gradeRecords;
  final double sgpa;
  final int creditsCompleted;

  const SemesterRecord({
    required this.semesterId,
    required this.gradeRecords,
    required this.sgpa,
    required this.creditsCompleted,
  });
}

class Transcript {
  final String studentId;
  final List<SemesterRecord> semesterRecords;
  final double currentCGPA;
  final int totalCreditsCompleted;

  const Transcript({
    required this.studentId,
    required this.semesterRecords,
    required this.currentCGPA,
    required this.totalCreditsCompleted,
  });
}

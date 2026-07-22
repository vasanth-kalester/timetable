import '../../../timetable/domain/models/scheduling_models.dart';

class DepartmentEntity {
  final String id;
  final String code;
  final String name;
  final String hodName;
  final String email;
  final bool isActive;

  const DepartmentEntity({
    required this.id,
    required this.code,
    required this.name,
    required this.hodName,
    required this.email,
    this.isActive = true,
  });
}

class ProgramEntity {
  final String id;
  final String code;
  final String name;
  final String departmentId;
  final int durationYears;
  final int totalCredits;

  const ProgramEntity({
    required this.id,
    required this.code,
    required this.name,
    required this.departmentId,
    this.durationYears = 4,
    this.totalCredits = 160,
  });
}

class SubjectEntity {
  final String id;
  final String code;
  final String name;
  final String departmentId;
  final String semesterId;
  final int lectureCredits;
  final int labCredits;
  final int theoryHours;
  final int practicalHours;
  final bool isElective;
  final RoomType requiredRoomType;

  const SubjectEntity({
    required this.id,
    required this.code,
    required this.name,
    required this.departmentId,
    required this.semesterId,
    required this.lectureCredits,
    this.labCredits = 0,
    this.theoryHours = 3,
    this.practicalHours = 0,
    this.isElective = false,
    this.requiredRoomType = RoomType.lecture,
  });

  int get totalCredits => lectureCredits + labCredits;
  int get totalWeeklyHours => theoryHours + practicalHours;
}

class StudentRecordEntity {
  final String id;
  final String rollNumber;
  final String registerNumber;
  final String fullName;
  final String email;
  final String departmentId;
  final String programId;
  final String semesterId;
  final String sectionId;

  const StudentRecordEntity({
    required this.id,
    required this.rollNumber,
    required this.registerNumber,
    required this.fullName,
    required this.email,
    required this.departmentId,
    required this.programId,
    required this.semesterId,
    required this.sectionId,
  });
}

class SectionEntity {
  final String id;
  final String name; // e.g. "Section A"
  final String semesterId;
  final String departmentId;
  final int studentCapacity;
  final String facultyAdvisorId;

  const SectionEntity({
    required this.id,
    required this.name,
    required this.semesterId,
    required this.departmentId,
    this.studentCapacity = 60,
    required this.facultyAdvisorId,
  });
}

class FacultyAssignmentEntity {
  final String id;
  final String facultyId;
  final String subjectId;
  final String sectionId;
  final int weeklyHours;

  const FacultyAssignmentEntity({
    required this.id,
    required this.facultyId,
    required this.subjectId,
    required this.sectionId,
    required this.weeklyHours,
  });
}

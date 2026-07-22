import '../../domain/entities/academic_entities.dart';
import '../../domain/repositories/academic_repository.dart';
import '../../domain/services/academic_validation_service.dart';
import '../../../timetable/domain/models/scheduling_models.dart';
import '../../../../core/utils/app_failure.dart';

class AcademicRepositoryImpl implements AcademicRepository {
  final List<DepartmentEntity> _departments = [
    const DepartmentEntity(id: 'dept_cs', code: 'CS', name: 'Computer Science & Engineering', hodName: 'Dr. Alan Turing', email: 'cs@eduflow.campus'),
    const DepartmentEntity(id: 'dept_ece', code: 'ECE', name: 'Electronics & Communication', hodName: 'Dr. Claude Shannon', email: 'ece@eduflow.campus'),
    const DepartmentEntity(id: 'dept_mech', code: 'MECH', name: 'Mechanical Engineering', hodName: 'Dr. Nikola Tesla', email: 'mech@eduflow.campus'),
  ];

  final List<ProgramEntity> _programs = [
    const ProgramEntity(id: 'prog_btech_cs', code: 'BTECH-CS', name: 'B.Tech CSBS', departmentId: 'dept_cs', durationYears: 4, totalCredits: 160),
    const ProgramEntity(id: 'prog_btech_ece', code: 'BTECH-ECE', name: 'B.Tech ECE', departmentId: 'dept_ece', durationYears: 4, totalCredits: 164),
  ];

  final List<SubjectEntity> _subjects = [
    const SubjectEntity(id: 'sub_cs101', code: 'CS101', name: 'Data Structures & Algorithms', departmentId: 'dept_cs', semesterId: 'Sem 3', lectureCredits: 3, labCredits: 1, theoryHours: 3, practicalHours: 2, requiredRoomType: RoomType.lecture),
    const SubjectEntity(id: 'sub_cs102', code: 'CS102', name: 'Operating Systems', departmentId: 'dept_cs', semesterId: 'Sem 3', lectureCredits: 3, labCredits: 0, theoryHours: 3, practicalHours: 0, requiredRoomType: RoomType.lecture),
    const SubjectEntity(id: 'sub_cs101l', code: 'CS101L', name: 'Data Structures Lab', departmentId: 'dept_cs', semesterId: 'Sem 3', lectureCredits: 0, labCredits: 2, theoryHours: 0, practicalHours: 4, requiredRoomType: RoomType.lab),
    const SubjectEntity(id: 'sub_ec201', code: 'EC201', name: 'Digital Signal Processing', departmentId: 'dept_ece', semesterId: 'Sem 5', lectureCredits: 4, labCredits: 0, theoryHours: 4, practicalHours: 0, requiredRoomType: RoomType.lecture),
  ];

  final List<StudentRecordEntity> _students = [
    const StudentRecordEntity(id: 'std_1', rollNumber: '21CS001', registerNumber: 'REG21CS001', fullName: 'Alice Johnson', email: 'alice@student.campus', departmentId: 'dept_cs', programId: 'prog_btech_cs', semesterId: 'Sem 5', sectionId: 'sec_a'),
    const StudentRecordEntity(id: 'std_2', rollNumber: '21CS002', registerNumber: 'REG21CS002', fullName: 'Bob Smith', email: 'bob@student.campus', departmentId: 'dept_cs', programId: 'prog_btech_cs', semesterId: 'Sem 5', sectionId: 'sec_a'),
    const StudentRecordEntity(id: 'std_3', rollNumber: '21CS003', registerNumber: 'REG21CS003', fullName: 'Charlie Brown', email: 'charlie@student.campus', departmentId: 'dept_cs', programId: 'prog_btech_cs', semesterId: 'Sem 5', sectionId: 'sec_b'),
  ];

  final List<FacultyEntity> _facultyList = [
    const FacultyEntity(id: 'fac_cs01', name: 'Dr. Alan Turing', departmentId: 'dept_cs', maxHoursPerWeek: 20),
    const FacultyEntity(id: 'fac_cs02', name: 'Prof. Grace Hopper', departmentId: 'dept_cs', maxHoursPerWeek: 24),
    const FacultyEntity(id: 'fac_ece01', name: 'Dr. Claude Shannon', departmentId: 'dept_ece', maxHoursPerWeek: 20),
  ];

  final List<FacultyAssignmentEntity> _assignments = [];

  @override
  Future<List<DepartmentEntity>> getDepartments() async => List.unmodifiable(_departments);

  @override
  Future<AppFailure?> addDepartment(DepartmentEntity department) async {
    _departments.add(department);
    return null;
  }

  @override
  Future<List<ProgramEntity>> getPrograms() async => List.unmodifiable(_programs);

  @override
  Future<AppFailure?> addProgram(ProgramEntity program) async {
    _programs.add(program);
    return null;
  }

  @override
  Future<List<SubjectEntity>> getSubjects() async => List.unmodifiable(_subjects);

  @override
  Future<AppFailure?> addSubject(SubjectEntity subject) async {
    final err = AcademicValidationService.validateSubject(candidate: subject, existingSubjects: _subjects);
    if (err != null) return err;
    _subjects.add(subject);
    return null;
  }

  @override
  Future<List<StudentRecordEntity>> getStudents({
    String? searchQuery,
    String? departmentId,
    int page = 1,
    int pageSize = 20,
  }) async {
    Iterable<StudentRecordEntity> filtered = _students;

    if (departmentId != null && departmentId.isNotEmpty) {
      filtered = filtered.where((s) => s.departmentId == departmentId);
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = searchQuery.trim().toLowerCase();
      filtered = filtered.where((s) =>
          s.fullName.toLowerCase().contains(q) ||
          s.rollNumber.toLowerCase().contains(q) ||
          s.registerNumber.toLowerCase().contains(q));
    }

    final list = filtered.toList();
    final start = (page - 1) * pageSize;
    if (start >= list.length) return [];
    final end = (start + pageSize) > list.length ? list.length : (start + pageSize);

    return list.sublist(start, end);
  }

  @override
  Future<AppFailure?> addStudent(StudentRecordEntity student) async {
    final err = AcademicValidationService.validateStudent(candidate: student, existingStudents: _students);
    if (err != null) return err;
    _students.add(student);
    return null;
  }

  @override
  Future<(int successCount, List<String> errors)> bulkImportStudents(List<StudentRecordEntity> students) async {
    int count = 0;
    final List<String> errors = [];

    for (final candidate in students) {
      final err = AcademicValidationService.validateStudent(candidate: candidate, existingStudents: _students);
      if (err != null) {
        errors.add('Roll ${candidate.rollNumber}: ${err.message}');
      } else {
        _students.add(candidate);
        count++;
      }
    }
    return (count, errors);
  }

  @override
  Future<List<FacultyEntity>> getFacultyList() async => List.unmodifiable(_facultyList);

  @override
  Future<List<FacultyAssignmentEntity>> getFacultyAssignments() async => List.unmodifiable(_assignments);

  @override
  Future<AppFailure?> assignFaculty(FacultyAssignmentEntity assignment) async {
    final faculty = _facultyList.firstWhere((f) => f.id == assignment.facultyId,
        orElse: () => FacultyEntity(id: assignment.facultyId, name: 'Faculty', departmentId: ''));

    final err = AcademicValidationService.validateFacultyAssignment(
      candidate: assignment,
      faculty: faculty,
      existingAssignments: _assignments,
    );
    if (err != null) return err;

    _assignments.add(assignment);
    return null;
  }
}

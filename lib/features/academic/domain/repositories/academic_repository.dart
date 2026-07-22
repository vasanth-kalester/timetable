import '../entities/academic_entities.dart';
import '../../../timetable/domain/models/scheduling_models.dart';
import '../../../../core/utils/app_failure.dart';

abstract class AcademicRepository {
  Future<List<DepartmentEntity>> getDepartments();
  Future<AppFailure?> addDepartment(DepartmentEntity department);

  Future<List<ProgramEntity>> getPrograms();
  Future<AppFailure?> addProgram(ProgramEntity program);

  Future<List<SubjectEntity>> getSubjects();
  Future<AppFailure?> addSubject(SubjectEntity subject);

  Future<List<StudentRecordEntity>> getStudents({
    String? searchQuery,
    String? departmentId,
    int page = 1,
    int pageSize = 20,
  });
  Future<AppFailure?> addStudent(StudentRecordEntity student);
  Future<(int successCount, List<String> errors)> bulkImportStudents(List<StudentRecordEntity> students);

  Future<List<FacultyEntity>> getFacultyList();
  Future<List<FacultyAssignmentEntity>> getFacultyAssignments();
  Future<AppFailure?> assignFaculty(FacultyAssignmentEntity assignment);
}

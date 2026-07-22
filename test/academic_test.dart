import 'package:flutter_test/flutter_test.dart';
import 'package:eduflow/features/academic/domain/entities/academic_entities.dart';
import 'package:eduflow/features/academic/data/repositories/academic_repository_impl.dart';
import 'package:eduflow/features/academic/data/datasources/csv_parser_service.dart';
import 'package:eduflow/features/timetable/domain/models/scheduling_models.dart';

void main() {
  group('EduFlow Academic Management Unit Tests', () {
    late AcademicRepositoryImpl repository;

    setUp(() {
      repository = AcademicRepositoryImpl();
    });

    test('Initial repository loads seed departments and subjects', () async {
      final depts = await repository.getDepartments();
      final subs = await repository.getSubjects();

      expect(depts.length, greaterThanOrEqualTo(3));
      expect(subs.length, greaterThanOrEqualTo(4));
    });

    test('Duplicate Student Roll Number is rejected', () async {
      const student1 = StudentRecordEntity(
        id: 's1',
        rollNumber: '21CS099',
        registerNumber: 'REG21CS099',
        fullName: 'David Miller',
        email: 'david@student.campus',
        departmentId: 'dept_cs',
        programId: 'prog_btech_cs',
        semesterId: 'Sem 5',
        sectionId: 'sec_a',
      );

      const student2 = StudentRecordEntity(
        id: 's2',
        rollNumber: '21CS099', // Duplicate roll number!
        registerNumber: 'REG21CS100',
        fullName: 'Daniel Miller',
        email: 'daniel@student.campus',
        departmentId: 'dept_cs',
        programId: 'prog_btech_cs',
        semesterId: 'Sem 5',
        sectionId: 'sec_a',
      );

      final err1 = await repository.addStudent(student1);
      expect(err1, isNull);

      final err2 = await repository.addStudent(student2);
      expect(err2, isNotNull);
      expect(err2!.message, contains('Duplicate Roll Number'));
    });

    test('Duplicate Subject Code is rejected', () async {
      const subject = SubjectEntity(
        id: 'sub_dup',
        code: 'CS101', // Pre-exists in seed data
        name: 'Duplicate DS',
        departmentId: 'dept_cs',
        semesterId: 'Sem 3',
        lectureCredits: 3,
      );

      final err = await repository.addSubject(subject);

      expect(err, isNotNull);
      expect(err!.message, contains('Duplicate Subject Code'));
    });

    test('Faculty Weekly Workload limit is enforced', () async {
      const assignment1 = FacultyAssignmentEntity(
        id: 'a1',
        facultyId: 'fac_cs01', // maxHoursPerWeek = 20
        subjectId: 'sub_cs101',
        sectionId: 'sec_a',
        weeklyHours: 15,
      );

      const assignment2 = FacultyAssignmentEntity(
        id: 'a2',
        facultyId: 'fac_cs01',
        subjectId: 'sub_cs102',
        sectionId: 'sec_b',
        weeklyHours: 10, // Total = 25 hrs, exceeds limit 20 hrs!
      );

      final err1 = await repository.assignFaculty(assignment1);
      expect(err1, isNull);

      final err2 = await repository.assignFaculty(assignment2);
      expect(err2, isNotNull);
      expect(err2!.message, contains('Faculty Overload'));
    });

    test('CsvParserService correctly parses raw CSV string', () {
      const rawCsv = '''roll_number,register_number,name,email,department_id,semester_id
21CS080,REG21CS080,Grace Hopper,grace@student.campus,dept_cs,Sem 5
21CS081,REG21CS081,Hank Pym,hank@student.campus,dept_cs,Sem 5''';

      final result = CsvParserService.parseStudentsCsv(rawCsv);

      expect(result.validRecords.length, equals(2));
      expect(result.parseErrors, isEmpty);
      expect(result.validRecords[0].fullName, equals('Grace Hopper'));
      expect(result.validRecords[1].rollNumber, equals('21CS081'));
    });

    test('Instant search filters students by query', () async {
      final results = await repository.getStudents(searchQuery: 'Alice');

      expect(results.length, equals(1));
      expect(results.first.fullName, equals('Alice Johnson'));
    });
  });
}

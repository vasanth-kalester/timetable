import 'package:flutter_test/flutter_test.dart';
import 'package:eduflow/features/examination/domain/models/examination_models.dart';
import 'package:eduflow/features/examination/domain/services/hall_allocation_engine.dart';
import 'package:eduflow/features/examination/domain/services/invigilator_engine.dart';
import 'package:eduflow/features/examination/domain/services/grade_computation_service.dart';
import 'package:eduflow/features/examination/domain/services/exam_impact_simulator.dart';
import 'package:eduflow/features/infrastructure/domain/models/infrastructure_models.dart';
import 'package:eduflow/features/timetable/domain/models/scheduling_models.dart' hide RoomType;

void main() {
  group('Examination Domain: HallAllocationEngine', () {
    test('Allocates students accounting for seating density factor', () {
      final session = ExamSession(
        id: 's1', examType: ExamType.endSemester, subjectId: 'CS101', 
        departmentId: 'CS', semesterId: '1', date: DateTime.now(), 
        startTimeMinutes: 540, durationMinutes: 180, expectedStudentCount: 50
      );

      // We have 2 rooms of capacity 60. At 50% density, each can hold 30 students.
      // So to fit 50 students, we need 2 rooms. (30 in Room 1, 20 in Room 2).
      final room1 = Room(id: 'r1', floorId: 'f1', roomNumber: '101', type: RoomType.classroom, capacity: 60, currentStatus: ResourceStatus.available);
      final room2 = Room(id: 'r2', floorId: 'f1', roomNumber: '102', type: RoomType.classroom, capacity: 60, currentStatus: ResourceStatus.available);

      final allocations = HallAllocationEngine.allocateHalls(
        session: session,
        availableRooms: [room1, room2],
        seatingDensityFactor: 0.5,
      );

      expect(allocations.length, 2);
      expect(allocations[0].allocatedStudentIds.length, 30);
      expect(allocations[1].allocatedStudentIds.length, 20);
    });

    test('Throws exception if capacity is insufficient', () {
      final session = ExamSession(
        id: 's1', examType: ExamType.endSemester, subjectId: 'CS101', 
        departmentId: 'CS', semesterId: '1', date: DateTime.now(), 
        startTimeMinutes: 540, durationMinutes: 180, expectedStudentCount: 100
      );

      final room1 = Room(id: 'r1', floorId: 'f1', roomNumber: '101', type: RoomType.classroom, capacity: 60, currentStatus: ResourceStatus.available);

      // Needs 100 seats. Room 1 can only hold 30 (at 0.5 density).
      expect(
        () => HallAllocationEngine.allocateHalls(session: session, availableRooms: [room1]),
        throwsException
      );
    });
  });

  group('Examination Domain: InvigilatorEngine', () {
    test('Assigns invigilators balancing workload and avoiding same department bias', () {
      final session = ExamSession(
        id: 's1', examType: ExamType.endSemester, subjectId: 'CS101', 
        departmentId: 'CS', semesterId: '1', date: DateTime.now(), 
        startTimeMinutes: 540, durationMinutes: 180, expectedStudentCount: 50
      );

      final allocation1 = HallAllocation(id: 'h1', examSessionId: 's1', roomId: 'r1', allocatedStudentIds: []);
      final allocation2 = HallAllocation(id: 'h2', examSessionId: 's1', roomId: 'r2', allocatedStudentIds: []);

      // We need 2 invigilators
      final f1 = FacultyEntity(id: 'f1', name: 'Prof CS', departmentId: 'CS'); // Same dept (Invalid)
      final f2 = FacultyEntity(id: 'f2', name: 'Prof EE 1', departmentId: 'EE');
      final f3 = FacultyEntity(id: 'f3', name: 'Prof EE 2', departmentId: 'EE');

      // Let's give f2 high workload already
      Map<String, int> workload = {
        'f2': 5,
        'f3': 1, // f3 has lower workload, should be picked first
      };

      final assignments = InvigilatorEngine.assignInvigilators(
        allocations: [allocation1, allocation2],
        session: session,
        availableFaculty: [f1, f2, f3],
        currentInvigilationCounts: workload,
      );

      expect(assignments.length, 2);
      
      // f1 should NOT be assigned (same department bias rule)
      expect(assignments.any((a) => a.facultyId == 'f1'), false);

      // f3 and f2 should be assigned.
      expect(assignments.any((a) => a.facultyId == 'f2'), true);
      expect(assignments.any((a) => a.facultyId == 'f3'), true);
    });
  });

  group('Examination Domain: GradeComputationService', () {
    test('Computes Grade Points and SGPA correctly', () {
      final r1 = GradeRecord(id: '1', studentId: 'stu1', subjectId: 'sub1', internalMarks: 40, externalMarks: 50); // Total 90 -> 10.0
      final r2 = GradeRecord(id: '2', studentId: 'stu1', subjectId: 'sub2', internalMarks: 30, externalMarks: 40); // Total 70 -> 8.0

      Map<String, int> credits = {
        'sub1': 4, // 4 credits * 10 = 40
        'sub2': 3, // 3 credits * 8 = 24
      }; // Total Credits = 7, Total Points = 64. SGPA = 64/7 = 9.14

      double sgpa = GradeComputationService.calculateSGPA([r1, r2], credits);
      
      expect(sgpa.toStringAsFixed(2), '9.14');
    });

    test('Computes CGPA correctly across semesters', () {
      final sem1 = SemesterRecord(semesterId: '1', gradeRecords: [], sgpa: 9.0, creditsCompleted: 20); // 180 points
      final sem2 = SemesterRecord(semesterId: '2', gradeRecords: [], sgpa: 8.0, creditsCompleted: 22); // 176 points
      
      // Total Credits = 42
      // Total Points = 356
      // CGPA = 356 / 42 = 8.476...

      double cgpa = GradeComputationService.calculateCGPA([sem1, sem2]);
      
      expect(cgpa.toStringAsFixed(2), '8.48');
    });
  });

  group('Examination Domain: ExamImpactSimulator', () {
    test('Detects clashes when hall capacity or faculty is insufficient', () {
      final session1 = ExamSession(
        id: 's1', examType: ExamType.endSemester, subjectId: 'CS101', 
        departmentId: 'CS', semesterId: '1', date: DateTime.now(), 
        startTimeMinutes: 540, durationMinutes: 180, expectedStudentCount: 200
      );
      
      final timetable = ExamTimetable(id: 't1', name: 'Finals', sessions: [session1], status: ExamTimetableStatus.draft);
      
      final room1 = Room(id: 'r1', floorId: 'f1', roomNumber: '101', type: RoomType.classroom, capacity: 100, currentStatus: ResourceStatus.available);

      final report = ExamImpactSimulator.simulateImpact(
        timetable: timetable,
        allRooms: [room1], // 1 room, 100 capacity (50 effective). We need 200 effective.
        allFaculty: [], // 0 faculty. We will need invigilators!
      );

      expect(report.isFeasible, false);
      expect(report.detectedClashes.length, 2); // 1 for capacity, 1 for faculty
      expect(report.detectedClashes[0].contains('Not enough hall capacity'), true);
      expect(report.detectedClashes[1].contains('Not enough faculty'), true);
    });
  });
}

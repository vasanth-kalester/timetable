import 'package:flutter_test/flutter_test.dart';
import 'package:eduflow/features/timetable/domain/models/scheduling_models.dart';
import 'package:eduflow/features/timetable/domain/models/rule_models.dart';
import 'package:eduflow/features/timetable/domain/models/versioning_models.dart';
import 'package:eduflow/features/timetable/domain/services/constraint_engine.dart';
import 'package:eduflow/features/timetable/domain/services/conflict_engine.dart';
import 'package:eduflow/features/timetable/domain/services/optimization_engine.dart';
import 'package:eduflow/features/timetable/domain/services/scheduling_engine.dart';
import 'package:eduflow/features/timetable/domain/services/simulation_engine.dart';

void main() {
  final room1 = const ClassroomEntity(id: 'r1', code: 'A101', name: 'A101', capacity: 60, roomType: RoomType.lecture);
  final roomLab = const ClassroomEntity(id: 'r2', code: 'L101', name: 'L101', capacity: 30, roomType: RoomType.lab);
  
  final faculty1 = const FacultyEntity(id: 'f1', name: 'Prof. X', departmentId: 'd1');
  
  final time1 = const TimeSlot(id: 't1', dayOfWeek: 1, startHour: 9);
  
  final session1 = const SubjectSession(
    id: 's1', subjectCode: 'CS101', subjectName: 'Intro to CS', 
    semesterId: 'sem1', departmentId: 'd1', facultyId: 'f1', 
    studentCount: 50, requiredRoomType: RoomType.lecture
  );

  final sessionLab = const SubjectSession(
    id: 's2', subjectCode: 'CS101-L', subjectName: 'Intro to CS Lab', 
    semesterId: 'sem1', departmentId: 'd1', facultyId: 'f1', 
    studentCount: 25, requiredRoomType: RoomType.lab
  );

  group('Timetable Phase 5: ConstraintEngine', () {
    test('Evaluates hard constraints correctly (Room Capacity)', () {
      final engine = ConstraintEngine(activeRules: [const RoomCapacityRule()]);
      
      final validAssignment = SlotAssignment(session: session1, timeSlot: time1, classroom: room1);
      final invalidAssignment = SlotAssignment(session: session1, timeSlot: time1, classroom: roomLab); // roomLab cap is 30, session is 50

      final context = const TimetableContext(existingAssignments: [], allRooms: [], allFaculty: []);

      expect(engine.isHardConstraintViolated(validAssignment, context), false);
      expect(engine.isHardConstraintViolated(invalidAssignment, context), true);
    });

    test('Evaluates Lab Requirement Rule', () {
      final engine = ConstraintEngine(activeRules: [const LabRequiresLabRoomRule()]);
      final context = const TimetableContext(existingAssignments: [], allRooms: [], allFaculty: []);

      final validLab = SlotAssignment(session: sessionLab, timeSlot: time1, classroom: roomLab);
      final invalidLab = SlotAssignment(session: sessionLab, timeSlot: time1, classroom: room1); // room1 is lecture

      expect(engine.isHardConstraintViolated(validLab, context), false);
      expect(engine.isHardConstraintViolated(invalidLab, context), true);
    });
  });

  group('Timetable Phase 5: ConflictEngineV2', () {
    test('Detects faculty double booking with severity and cause', () {
      final existing = SlotAssignment(session: session1, timeSlot: time1, classroom: room1);
      final candidate = SlotAssignment(session: sessionLab, timeSlot: time1, classroom: roomLab);

      final context = TimetableContext(existingAssignments: [existing], allRooms: [], allFaculty: []);

      final conflicts = ConflictEngineV2.detectConflicts(candidate: candidate, context: context);
      
      expect(conflicts.length, 1);
      expect(conflicts.first.severity, ConflictSeverity.high);
      expect(conflicts.first.cause.contains('Faculty double-booked'), true);
    });
  });

  group('Timetable Phase 5: Simulation & Versioning', () {
    test('Branching creates a decoupled copy', () {
      final baseVersion = TimetableVersion(
        id: 'v1', name: 'V1', status: TimetableStatus.published, 
        createdAt: DateTime.now(), optimizationScore: 90, 
        assignments: [SlotAssignment(session: session1, timeSlot: time1, classroom: room1)]
      );

      final simVersion = SimulationEngine.branchSimulation(baseVersion);

      expect(simVersion.id, isNot('v1'));
      expect(simVersion.parentVersionId, 'v1');
      expect(simVersion.status, TimetableStatus.simulation);
      expect(simVersion.assignments.length, 1);
      
      // Modify simulation
      simVersion.assignments.clear();
      expect(baseVersion.assignments.length, 1); // Base should be unaffected
    });

    test('calculateDiff accurately detects additions and modifications', () {
      final assignment1 = SlotAssignment(session: session1, timeSlot: time1, classroom: room1);
      
      final baseVersion = TimetableVersion(
        id: 'v1', name: 'V1', status: TimetableStatus.published, createdAt: DateTime.now(), optimizationScore: 90, 
        assignments: [assignment1]
      );

      final newTime = const TimeSlot(id: 't2', dayOfWeek: 1, startHour: 10);
      final modifiedAssignment = SlotAssignment(session: session1, timeSlot: newTime, classroom: room1); // Time changed
      final addedAssignment = SlotAssignment(session: sessionLab, timeSlot: time1, classroom: roomLab);

      final newVersion = TimetableVersion(
        id: 'v2', name: 'V2', status: TimetableStatus.simulation, createdAt: DateTime.now(), optimizationScore: 92, 
        assignments: [modifiedAssignment, addedAssignment]
      );

      final diff = SimulationEngine.calculateDiff(baseVersion: baseVersion, newVersion: newVersion);

      expect(diff.addedAssignments.length, 1);
      expect(diff.modifiedAssignments.length, 1);
      expect(diff.removedAssignments.length, 0);
      expect(diff.modifiedAssignments.first.timeSlot.id, 't2');
    });
  });

  group('Timetable Phase 5: CoreSchedulingEngine (CSP)', () {
    test('CSP Backtracking successfully schedules if constraints allow', () {
      final engine = CoreSchedulingEngine(constraintEngine: ConstraintEngine(activeRules: [
        const RoomCapacityRule(), const FacultyDoubleBookingRule(), const RoomDoubleBookingRule()
      ]));

      final context = TimetableContext(existingAssignments: [], allRooms: [room1, roomLab], allFaculty: [faculty1]);
      
      // We have 1 faculty, 2 sessions. Faculty can't double book, so they must be in different time slots.
      final time2 = const TimeSlot(id: 't2', dayOfWeek: 1, startHour: 10);

      final result = engine.generateSchedule(
        unassignedSessions: [session1, sessionLab],
        availableTimeSlots: [time1, time2],
        context: context,
      );

      expect(result.isSuccess, true);
      expect(result.assignments.length, 2);
      
      // Verify faculty is not double booked
      final f1Slots = result.assignments.where((a) => a.session.facultyId == 'f1').map((a) => a.timeSlot.id).toSet();
      expect(f1Slots.length, 2); // Must occupy two distinct slots
    });
  });
}

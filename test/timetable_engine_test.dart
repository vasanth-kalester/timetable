import 'package:flutter_test/flutter_test.dart';
import 'package:eduflow/features/timetable/domain/models/scheduling_models.dart';
import 'package:eduflow/features/timetable/domain/services/conflict_engine.dart';
import 'package:eduflow/features/timetable/domain/services/scheduling_engine.dart';
import 'package:eduflow/features/timetable/domain/services/optimization_engine.dart';

void main() {
  group('EduFlow Engine Verification Suite', () {
    late List<ClassroomEntity> rooms;
    late List<FacultyEntity> faculty;
    late List<TimeSlot> slots;

    setUp(() {
      rooms = [
        const ClassroomEntity(
          id: 'room_101',
          code: 'LH-101',
          name: 'Lecture Hall 101',
          capacity: 60,
          roomType: RoomType.lecture,
        ),
        const ClassroomEntity(
          id: 'room_lab1',
          code: 'LAB-01',
          name: 'Computer Lab 1',
          capacity: 40,
          roomType: RoomType.lab,
        ),
      ];

      faculty = [
        const FacultyEntity(
          id: 'fac_cs01',
          name: 'Dr. Alan Turing',
          departmentId: 'dept_cs',
          maxHoursPerDay: 5,
        ),
        const FacultyEntity(
          id: 'fac_cs02',
          name: 'Prof. Grace Hopper',
          departmentId: 'dept_cs',
          maxHoursPerDay: 5,
        ),
      ];

      slots = [
        const TimeSlot(id: 'slot_m1', dayOfWeek: 1, startHour: 9),
        const TimeSlot(id: 'slot_m2', dayOfWeek: 1, startHour: 10),
        const TimeSlot(id: 'slot_m3', dayOfWeek: 1, startHour: 11),
        const TimeSlot(id: 'slot_m4', dayOfWeek: 1, startHour: 12),
      ];
    });

    test('ConflictEngine detects room capacity overflow', () {
      const session = SubjectSession(
        id: 'sess_large',
        subjectCode: 'CS101',
        subjectName: 'Data Structures',
        semesterId: 'sem_3',
        departmentId: 'dept_cs',
        facultyId: 'fac_cs01',
        studentCount: 80, // Exceeds LH-101 (capacity 60)
        requiredRoomType: RoomType.lecture,
      );

      final assignment = SlotAssignment(
        session: session,
        timeSlot: slots[0],
        classroom: rooms[0],
      );

      final conflicts = ConflictEngine.validateAssignment(
        assignment: assignment,
        existingAssignments: [],
        faculty: faculty[0],
      );

      expect(conflicts.length, equals(1));
      expect(conflicts.first.type, equals(ConflictType.roomCapacityExceeded));
    });

    test('ConflictEngine detects faculty double-booking', () {
      const session1 = SubjectSession(
        id: 'sess_1',
        subjectCode: 'CS101',
        subjectName: 'Algorithms',
        semesterId: 'sem_3',
        departmentId: 'dept_cs',
        facultyId: 'fac_cs01',
        studentCount: 40,
        requiredRoomType: RoomType.lecture,
      );

      const session2 = SubjectSession(
        id: 'sess_2',
        subjectCode: 'CS102',
        subjectName: 'Operating Systems',
        semesterId: 'sem_5',
        departmentId: 'dept_cs',
        facultyId: 'fac_cs01', // Same faculty
        studentCount: 35,
        requiredRoomType: RoomType.lecture,
      );

      final assignment1 = SlotAssignment(
        session: session1,
        timeSlot: slots[0],
        classroom: rooms[0],
      );

      final assignment2 = SlotAssignment(
        session: session2,
        timeSlot: slots[0], // Same slot!
        classroom: rooms[1],
      );

      final conflicts = ConflictEngine.validateAssignment(
        assignment: assignment2,
        existingAssignments: [assignment1],
        faculty: faculty[0],
      );

      expect(conflicts.any((c) => c.type == ConflictType.facultyClash), isTrue);
    });

    test('SchedulingEngine generates conflict-free schedule', () {
      final sessions = [
        const SubjectSession(
          id: 'sess_alg',
          subjectCode: 'CS201',
          subjectName: 'Algorithms',
          semesterId: 'sem_3',
          departmentId: 'dept_cs',
          facultyId: 'fac_cs01',
          studentCount: 50,
          requiredRoomType: RoomType.lecture,
        ),
        const SubjectSession(
          id: 'sess_lab',
          subjectCode: 'CS201L',
          subjectName: 'Algorithms Lab',
          semesterId: 'sem_3',
          departmentId: 'dept_cs',
          facultyId: 'fac_cs02',
          studentCount: 30,
          requiredRoomType: RoomType.lab,
        ),
      ];

      final result = SchedulingEngine.generateTimetable(
        sessions: sessions,
        availableSlots: slots,
        availableRooms: rooms,
        facultyList: faculty,
      );

      expect(result.isSuccess, isTrue);
      expect(result.assignments.length, equals(2));

      final conflicts = ConflictEngine.validateFullTimetable(
        assignments: result.assignments,
        facultyList: faculty,
      );
      expect(conflicts, isEmpty);
    });

    test('OptimizationEngine evaluates utilization rate correctly', () {
      final session = SubjectSession(
        id: 'sess_alg',
        subjectCode: 'CS201',
        subjectName: 'Algorithms',
        semesterId: 'sem_3',
        departmentId: 'dept_cs',
        facultyId: 'fac_cs01',
        studentCount: 50,
        requiredRoomType: RoomType.lecture,
      );

      final assignments = [
        SlotAssignment(
          session: session,
          timeSlot: slots[0],
          classroom: rooms[0],
        ),
      ];

      final score = OptimizationEngine.evaluateSchedule(
        assignments: assignments,
        allRooms: rooms,
        totalOperatingSlots: 4,
      );

      expect(score.overallScore, greaterThan(0));
      expect(score.classroomUsageHours[rooms[0].id], equals(1));
    });
  });
}

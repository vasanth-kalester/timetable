import 'package:flutter_test/flutter_test.dart';
import 'package:eduflow/features/operations/domain/models/operations_models.dart';
import 'package:eduflow/features/operations/domain/services/attendance_sync_service.dart';
import 'package:eduflow/features/operations/domain/services/substitute_engine.dart';
import 'package:eduflow/features/operations/domain/services/operations_health_service.dart';
import 'package:eduflow/features/timetable/domain/models/scheduling_models.dart';
import 'package:eduflow/features/timetable/domain/models/versioning_models.dart';
import 'package:eduflow/features/timetable/domain/models/rule_models.dart';

void main() {
  final now = DateTime.now();
  final room1 = const ClassroomEntity(id: 'r1', code: 'A1', name: 'A1', capacity: 60, roomType: RoomType.lecture);
  final facultyA = const FacultyEntity(id: 'fA', name: 'Prof A', departmentId: 'CS');
  final facultyB = const FacultyEntity(id: 'fB', name: 'Prof B', departmentId: 'CS');
  final facultyC = const FacultyEntity(id: 'fC', name: 'Prof C', departmentId: 'EE'); // Diff dept
  
  final time1 = TimeSlot(id: 't1', dayOfWeek: now.weekday, startHour: 9); // Matches today
  
  final session1 = const SubjectSession(
    id: 's1', subjectCode: 'CS101', subjectName: 'Intro', 
    semesterId: '1', departmentId: 'CS', facultyId: 'fA', 
    studentCount: 50, requiredRoomType: RoomType.lecture
  );

  final assignment1 = SlotAssignment(session: session1, timeSlot: time1, classroom: room1);
  final publishedTimetable = TimetableVersion(
    id: 'v1', name: 'V1', status: TimetableStatus.published, createdAt: now, optimizationScore: 90, 
    assignments: [assignment1]
  );

  group('Operations Domain: AttendanceSyncService', () {
    test('Queues attendance when offline, syncs when online', () async {
      final service = AttendanceSyncService();
      final record = AttendanceRecord(
        id: 'att1', sessionId: 's1', studentId: 'stu1', date: now, 
        status: AttendanceStatus.present, markedByFacultyId: 'fA', timestamp: now
      );

      // Offline mark
      await service.markAttendance(record: record, isOnline: false, publishedTimetable: publishedTimetable);
      expect(service.offlineQueue.length, 1);
      expect(service.syncedDatabase.length, 0);

      // Sync
      int count = await service.syncPendingRecords();
      expect(count, 1);
      expect(service.offlineQueue.length, 0);
      expect(service.syncedDatabase.length, 1);
      expect(service.syncedDatabase.first.isSynced, true);
    });

    test('Throws error if session does not exist in published timetable', () async {
      final service = AttendanceSyncService();
      final invalidRecord = AttendanceRecord(
        id: 'att2', sessionId: 'invalid_session', studentId: 'stu1', date: now, 
        status: AttendanceStatus.present, markedByFacultyId: 'fA', timestamp: now
      );

      expect(
        () => service.markAttendance(record: invalidRecord, isOnline: true, publishedTimetable: publishedTimetable),
        throwsException,
      );
    });
  });

  group('Operations Domain: SubstituteEngine', () {
    test('Suggests substitutes based on department and workload', () {
      final leave = FacultyLeave(
        id: 'l1', facultyId: 'fA', type: LeaveType.casual, 
        startDate: now, endDate: now, reason: 'Personal', status: LeaveStatus.approved
      );

      // We need to give faculty B and C some workload to test the sorting
      final sessionB = const SubjectSession(
        id: 'sB', subjectCode: 'CS201', subjectName: 'Algo', 
        semesterId: '1', departmentId: 'CS', facultyId: 'fB', 
        studentCount: 50, requiredRoomType: RoomType.lecture
      );
      // Faculty B has a class, but at a DIFFERENT time (so they are available for substitute)
      final time2 = TimeSlot(id: 't2', dayOfWeek: now.weekday, startHour: 10);
      final assignmentB = SlotAssignment(session: sessionB, timeSlot: time2, classroom: room1);
      
      final timetableContext = TimetableContext(
        existingAssignments: [],
        allRooms: [room1],
        allFaculty: [facultyA, facultyB, facultyC],
      );

      final publishedWithWorkload = TimetableVersion(
        id: 'v1', name: 'V1', status: TimetableStatus.published, createdAt: now, optimizationScore: 90, 
        assignments: [assignment1, assignmentB]
      );

      final suggestions = SubstituteEngine.findSubstitutes(
        leave: leave,
        publishedTimetable: publishedWithWorkload,
        context: timetableContext,
      );

      // Faculty A is the one on leave (should be excluded)
      // Faculty B is CS department (same as A), available.
      // Faculty C is EE department (different), available.
      // So B should score higher than C.

      expect(suggestions.length, 2);
      expect(suggestions.first.faculty.id, 'fB');
      expect(suggestions.first.matchReasons.contains('Same Department'), true);
      expect(suggestions.last.faculty.id, 'fC');
    });

    test('Excludes busy faculty from substitute suggestions', () {
      final leave = FacultyLeave(
        id: 'l1', facultyId: 'fA', type: LeaveType.casual, 
        startDate: now, endDate: now, reason: 'Personal', status: LeaveStatus.approved
      );

      // Faculty B has a class at the EXACT SAME TIME as Faculty A
      final sessionB = const SubjectSession(
        id: 'sB', subjectCode: 'CS201', subjectName: 'Algo', 
        semesterId: '1', departmentId: 'CS', facultyId: 'fB', 
        studentCount: 50, requiredRoomType: RoomType.lecture
      );
      final assignmentB = SlotAssignment(session: sessionB, timeSlot: time1, classroom: room1); // time1!

      final timetableContext = TimetableContext(
        existingAssignments: [],
        allRooms: [room1],
        allFaculty: [facultyA, facultyB, facultyC],
      );

      final publishedWithWorkload = TimetableVersion(
        id: 'v1', name: 'V1', status: TimetableStatus.published, createdAt: now, optimizationScore: 90, 
        assignments: [assignment1, assignmentB]
      );

      final suggestions = SubstituteEngine.findSubstitutes(
        leave: leave,
        publishedTimetable: publishedWithWorkload,
        context: timetableContext,
      );

      // Faculty B is busy at time1, so only Faculty C should be suggested.
      expect(suggestions.length, 1);
      expect(suggestions.first.faculty.id, 'fC');
    });
  });

  group('Operations Domain: OperationsHealthService', () {
    test('Calculates health score and penalizes missed attendance and uncovered leaves', () {
      final leave = FacultyLeave(
        id: 'l1', facultyId: 'fA', type: LeaveType.casual, 
        startDate: now, endDate: now, reason: 'Personal', status: LeaveStatus.approved,
        substituteFacultyId: null, // Uncovered leave! (-15 pts)
      );

      final roomChange = RoomChangeRequest(
        id: 'rc1', originalSlotId: 't1', requestedRoomId: 'r2', reason: 'Projector broken', 
        status: RoomChangeStatus.approved // (-2 pts)
      );

      // We have 1 assignment (assignment1) for today. If no attendance is logged for it, (-5 pts).
      // Let's pass empty attendance logs.
      
      final score = OperationsHealthService.calculateDailyHealthScore(
        date: now,
        publishedTimetable: publishedTimetable,
        activeLeaves: [leave],
        todaysAttendanceLogs: [], // Missing attendance for session 1
        roomChangeRequests: [roomChange],
      );

      // 100 - 15 (leave) - 5 (attendance) - 2 (room change) = 78.0
      expect(score, 78.0);
    });
  });
}

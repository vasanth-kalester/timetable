import 'package:flutter_test/flutter_test.dart';
import 'package:eduflow/features/admin/domain/models/admin_models.dart';
import 'package:eduflow/features/admin/domain/services/configuration_service.dart';
import 'package:eduflow/features/admin/domain/services/analytics_aggregator.dart';
import 'package:eduflow/features/admin/domain/services/report_engine.dart';
import 'package:eduflow/features/admin/domain/services/audit_service.dart';
import 'package:eduflow/features/infrastructure/domain/models/infrastructure_models.dart' as infra;
import 'package:eduflow/features/timetable/domain/models/scheduling_models.dart';
import 'package:eduflow/features/timetable/domain/models/versioning_models.dart';

void main() {
  group('Admin Domain: ConfigurationService', () {
    test('Validates config updates correctly', () {
      final initialConfig = const SystemConfig(
        institutionName: 'EduFlow University',
        workingDays: [1, 2, 3, 4, 5],
        defaultTimeSlotsPerDay: 8,
        semesterDurationWeeks: 16,
        defaultLeavePolicy: LeavePolicy(casualLeaveLimit: 12, sickLeaveLimit: 12),
        rolePermissions: {'hod': ['approve_leave', 'view_reports']},
      );

      final service = ConfigurationService(initialConfig);

      // Invalid config (0 working days)
      final invalidConfig1 = const SystemConfig(
        institutionName: 'EduFlow', workingDays: [], defaultTimeSlotsPerDay: 8,
        semesterDurationWeeks: 16, defaultLeavePolicy: LeavePolicy(casualLeaveLimit: 12, sickLeaveLimit: 12),
        rolePermissions: {},
      );

      expect(() => service.updateConfig(invalidConfig1), throwsException);

      // Check Permissions
      expect(service.hasPermission('hod', 'approve_leave'), true);
      expect(service.hasPermission('hod', 'publish_timetable'), false);
    });
  });

  group('Admin Domain: AnalyticsAggregator', () {
    test('Computes campus utilization correctly', () {
      final room1 = infra.Room(id: 'r1', floorId: 'f1', roomNumber: '101', type: infra.RoomType.classroom, capacity: 60, currentStatus: infra.ResourceStatus.available);
      
      final session1 = const SubjectSession(
        id: 's1', subjectCode: 'CS101', subjectName: 'Intro', 
        semesterId: '1', departmentId: 'CS', facultyId: 'fA', 
        studentCount: 50, requiredRoomType: RoomType.lecture
      );

      // 1 room * 8 slots * 5 days = 40 possible slots
      // 2 assignments = 2 used slots
      // Utilization = 2 / 40 = 5%
      
      final time1 = const TimeSlot(id: 't1', dayOfWeek: 1, startHour: 9);
      final time2 = const TimeSlot(id: 't2', dayOfWeek: 2, startHour: 9);
      final classRoom1 = const ClassroomEntity(id: 'r1', code: '101', name: '101', capacity: 60, roomType: RoomType.lecture);
      final a1 = SlotAssignment(session: session1, timeSlot: time1, classroom: classRoom1);
      final a2 = SlotAssignment(session: session1, timeSlot: time2, classroom: classRoom1);

      final timetable = TimetableVersion(
        id: 'v1', name: 'V1', status: TimetableStatus.published, createdAt: DateTime.now(), optimizationScore: 90, 
        assignments: [a1, a2]
      );

      final metrics = AnalyticsAggregator.computePrincipalMetrics(
        activeTimetable: timetable,
        allRooms: [room1],
        dailyTimeSlots: 8,
      );

      expect(metrics.campusUtilizationPercent, 5.0);
    });
  });

  group('Admin Domain: ReportEngine', () {
    test('Extracts workload tabular report and converts to CSV', () {
      final session1 = const SubjectSession(
        id: 's1', subjectCode: 'CS101', subjectName: 'Intro', 
        semesterId: '1', departmentId: 'CS', facultyId: 'fA', 
        studentCount: 50, requiredRoomType: RoomType.lecture
      );

      final room1 = infra.Room(id: 'r1', floorId: 'f1', roomNumber: '101', type: infra.RoomType.classroom, capacity: 60, currentStatus: infra.ResourceStatus.available);
      final time1 = const TimeSlot(id: 't1', dayOfWeek: 1, startHour: 9, durationMinutes: 60);
      
      final classRoom1 = const ClassroomEntity(id: 'r1', code: '101', name: '101', capacity: 60, roomType: RoomType.lecture);
      final a1 = SlotAssignment(session: session1, timeSlot: time1, classroom: classRoom1);
      final timetable = TimetableVersion(
        id: 'v1', name: 'V1', status: TimetableStatus.published, createdAt: DateTime.now(), optimizationScore: 90, 
        assignments: [a1, a1] // 2 classes, 120 mins
      );

      final facultyA = const FacultyEntity(id: 'fA', name: 'Prof A', departmentId: 'CS');

      final report = ReportEngine.generateFacultyWorkloadReport(
        timetable: timetable,
        allFaculty: [facultyA],
      );

      expect(report.rows.length, 1);
      expect(report.rows[0][3], 2); // 2 classes
      expect(report.rows[0][4], 120); // 120 mins

      // Test CSV Export
      final csvString = report.toCsv();
      expect(csvString.contains('Faculty ID,Faculty Name'), true); // Headers
      expect(csvString.contains('"fA"'), true); // Row data
    });
  });

  group('Admin Domain: AuditService', () {
    test('Logs are immutable', () {
      final service = AuditService();
      
      service.logAction(userId: 'u1', action: 'publish_timetable', details: 'Published V2');
      
      final logs = service.getLogs();
      expect(logs.length, 1);

      // The returned list should be unmodifiable
      expect(() => logs.add(logs.first), throwsUnsupportedError);
    });
  });
}

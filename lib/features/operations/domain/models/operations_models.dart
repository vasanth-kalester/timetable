import 'package:eduflow/features/timetable/domain/models/scheduling_models.dart';

// --- ATTENDANCE ---

enum AttendanceStatus {
  present,
  absent,
  late,
  excused
}

class AttendanceRecord {
  final String id;
  final String sessionId; // Refers to SubjectSession.id from the timetable
  final String studentId;
  final DateTime date;
  final AttendanceStatus status;
  final String markedByFacultyId;
  final bool isSynced;
  final DateTime timestamp;

  const AttendanceRecord({
    required this.id,
    required this.sessionId,
    required this.studentId,
    required this.date,
    required this.status,
    required this.markedByFacultyId,
    this.isSynced = true,
    required this.timestamp,
  });

  AttendanceRecord copyWith({bool? isSynced, AttendanceStatus? status}) {
    return AttendanceRecord(
      id: id,
      sessionId: sessionId,
      studentId: studentId,
      date: date,
      status: status ?? this.status,
      markedByFacultyId: markedByFacultyId,
      isSynced: isSynced ?? this.isSynced,
      timestamp: timestamp,
    );
  }
}

// --- LEAVE MANAGEMENT ---

enum LeaveType {
  casual,
  sick,
  onDuty,
  vacation,
  emergency
}

enum LeaveStatus {
  pending,
  approved,
  rejected,
  cancelled
}

class FacultyLeave {
  final String id;
  final String facultyId;
  final LeaveType type;
  final DateTime startDate;
  final DateTime endDate;
  final String reason;
  final LeaveStatus status;
  final String? substituteFacultyId; // Assigned by HOD

  const FacultyLeave({
    required this.id,
    required this.facultyId,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.status,
    this.substituteFacultyId,
  });

  FacultyLeave copyWith({LeaveStatus? status, String? substituteFacultyId}) {
    return FacultyLeave(
      id: id,
      facultyId: facultyId,
      type: type,
      startDate: startDate,
      endDate: endDate,
      reason: reason,
      status: status ?? this.status,
      substituteFacultyId: substituteFacultyId ?? this.substituteFacultyId,
    );
  }
}

// --- ROOM CHANGE & ANNOUNCEMENTS ---

enum RoomChangeStatus {
  pending,
  approved,
  rejected
}

class RoomChangeRequest {
  final String id;
  final String originalSlotId; // Refers to SlotAssignment.id in published version
  final String requestedRoomId;
  final String reason;
  final RoomChangeStatus status;

  const RoomChangeRequest({
    required this.id,
    required this.originalSlotId,
    required this.requestedRoomId,
    required this.reason,
    required this.status,
  });
}

class Announcement {
  final String id;
  final String title;
  final String body;
  final String category; // e.g. Academic, Emergency
  final int priority; // 1 = High, 3 = Low
  final DateTime expiryDate;
  final List<String>? targetAudienceIds; // Could be department IDs or specific role strings

  const Announcement({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.priority,
    required this.expiryDate,
    this.targetAudienceIds,
  });
}

// --- NOTIFICATIONS & AUDIT LOGS ---

class AppNotification {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String type; // e.g. leave_approved, alert
  final bool isRead;
  final DateTime timestamp;

  const AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.isRead = false,
    required this.timestamp,
  });
}

class AuditLog {
  final String id;
  final String userId;
  final String action;
  final String details;
  final DateTime timestamp;

  const AuditLog({
    required this.id,
    required this.userId,
    required this.action,
    required this.details,
    required this.timestamp,
  });
}

enum RoomType { lecture, lab, auditorium, seminar }

enum ConflictType {
  facultyClash,
  roomClash,
  studentBatchClash,
  roomCapacityExceeded,
  roomTypeMismatch,
  facultyMaxHoursExceeded,
  facultyUnavailableSlot,
}

class TimeSlot {
  final String id;
  final int dayOfWeek; // 1 = Monday, 6 = Saturday
  final int startHour; // e.g. 9 for 09:00
  final int startMinute; // e.g. 0 or 30
  final int durationMinutes; // e.g. 60

  const TimeSlot({
    required this.id,
    required this.dayOfWeek,
    required this.startHour,
    this.startMinute = 0,
    this.durationMinutes = 60,
  });

  int get endHour => startHour + ((startMinute + durationMinutes) ~/ 60);
  int get endMinute => (startMinute + durationMinutes) % 60;

  bool overlapsWith(TimeSlot other) {
    if (dayOfWeek != other.dayOfWeek) return false;
    final thisStart = startHour * 60 + startMinute;
    final thisEnd = thisStart + durationMinutes;
    final otherStart = other.startHour * 60 + other.startMinute;
    final otherEnd = otherStart + other.durationMinutes;

    return thisStart < otherEnd && otherStart < thisEnd;
  }

  @override
  String toString() => 'Day $dayOfWeek ${startHour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')} ($durationMinutes min)';
}

class ClassroomEntity {
  final String id;
  final String code;
  final String name;
  final int capacity;
  final RoomType roomType;
  final bool hasProjector;
  final bool hasLabEquipment;

  const ClassroomEntity({
    required this.id,
    required this.code,
    required this.name,
    required this.capacity,
    required this.roomType,
    this.hasProjector = true,
    this.hasLabEquipment = false,
  });
}

class FacultyEntity {
  final String id;
  final String name;
  final String departmentId;
  final int maxHoursPerDay;
  final int maxHoursPerWeek;
  final List<TimeSlot> unavailableSlots;

  const FacultyEntity({
    required this.id,
    required this.name,
    required this.departmentId,
    this.maxHoursPerDay = 6,
    this.maxHoursPerWeek = 24,
    this.unavailableSlots = const [],
  });
}

class SubjectSession {
  final String id;
  final String subjectCode;
  final String subjectName;
  final String semesterId;
  final String departmentId;
  final String facultyId;
  final int studentCount;
  final RoomType requiredRoomType;
  final int durationSlots; // 1 slot = 1 hour, 2 slots = lab

  const SubjectSession({
    required this.id,
    required this.subjectCode,
    required this.subjectName,
    required this.semesterId,
    required this.departmentId,
    required this.facultyId,
    required this.studentCount,
    required this.requiredRoomType,
    this.durationSlots = 1,
  });
}

class SlotAssignment {
  final SubjectSession session;
  final TimeSlot timeSlot;
  final ClassroomEntity classroom;

  const SlotAssignment({
    required this.session,
    required this.timeSlot,
    required this.classroom,
  });
}

class ScheduleConflict {
  final ConflictType type;
  final String message;
  final List<String> involvedEntityIds;

  const ScheduleConflict({
    required this.type,
    required this.message,
    required this.involvedEntityIds,
  });

  @override
  String toString() => '[${type.name.toUpperCase()}] $message';
}

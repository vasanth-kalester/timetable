import 'scheduling_models.dart';

enum RuleSeverity {
  hard, // Must not be violated
  soft, // Can be violated, but penalizes optimization score
}

class TimetableContext {
  final List<SlotAssignment> existingAssignments;
  final List<ClassroomEntity> allRooms;
  final List<FacultyEntity> allFaculty;

  const TimetableContext({
    required this.existingAssignments,
    required this.allRooms,
    required this.allFaculty,
  });
}

abstract class SchedulingRule {
  final String id;
  final String name;
  final String description;
  final RuleSeverity severity;
  final int penaltyScore; // Deducted if soft rule is violated

  const SchedulingRule({
    required this.id,
    required this.name,
    required this.description,
    required this.severity,
    this.penaltyScore = 5,
  });

  /// Returns true if the rule is satisfied (no violation).
  /// Returns false if the rule is violated by the candidate assignment.
  bool evaluate(SlotAssignment candidate, TimetableContext context);
}

// Example Concrete Rules

class RoomCapacityRule extends SchedulingRule {
  const RoomCapacityRule()
      : super(
          id: 'room_capacity_1',
          name: 'Room Capacity',
          description: 'Room capacity must be greater than or equal to student count.',
          severity: RuleSeverity.hard,
        );

  @override
  bool evaluate(SlotAssignment candidate, TimetableContext context) {
    return candidate.classroom.capacity >= candidate.session.studentCount;
  }
}

class FacultyDoubleBookingRule extends SchedulingRule {
  const FacultyDoubleBookingRule()
      : super(
          id: 'faculty_double_booking_1',
          name: 'Faculty Double Booking',
          description: 'A faculty member cannot teach two sessions at the same time.',
          severity: RuleSeverity.hard,
        );

  @override
  bool evaluate(SlotAssignment candidate, TimetableContext context) {
    for (var existing in context.existingAssignments) {
      if (existing.session.facultyId == candidate.session.facultyId &&
          existing.timeSlot.overlapsWith(candidate.timeSlot)) {
        return false; // Violation
      }
    }
    return true; // Satisfied
  }
}

class RoomDoubleBookingRule extends SchedulingRule {
  const RoomDoubleBookingRule()
      : super(
          id: 'room_double_booking_1',
          name: 'Room Double Booking',
          description: 'A room cannot host two sessions at the same time.',
          severity: RuleSeverity.hard,
        );

  @override
  bool evaluate(SlotAssignment candidate, TimetableContext context) {
    for (var existing in context.existingAssignments) {
      if (existing.classroom.id == candidate.classroom.id &&
          existing.timeSlot.overlapsWith(candidate.timeSlot)) {
        return false; // Violation
      }
    }
    return true; // Satisfied
  }
}

class LabRequiresLabRoomRule extends SchedulingRule {
  const LabRequiresLabRoomRule()
      : super(
          id: 'lab_room_type_1',
          name: 'Lab Room Requirement',
          description: 'Lab sessions must be assigned to laboratory rooms.',
          severity: RuleSeverity.hard,
        );

  @override
  bool evaluate(SlotAssignment candidate, TimetableContext context) {
    if (candidate.session.requiredRoomType == RoomType.lab) {
      return candidate.classroom.roomType == RoomType.lab;
    }
    return true;
  }
}

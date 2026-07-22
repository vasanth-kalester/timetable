import '../models/scheduling_models.dart';
import '../models/rule_models.dart';

enum ConflictSeverity {
  high,   // Must fix (e.g. double booking)
  medium, // Should fix (e.g. capacity slightly exceeded)
  low,    // Optimization issue (e.g. gap hours)
}

class DetailedConflict {
  final ConflictSeverity severity;
  final String cause;
  final String suggestedResolution;
  final List<String> involvedEntityIds;

  const DetailedConflict({
    required this.severity,
    required this.cause,
    required this.suggestedResolution,
    required this.involvedEntityIds,
  });

  @override
  String toString() => '[$severity] $cause -> $suggestedResolution';
}

class ConflictEngineV2 {
  /// Detects detailed conflicts for a candidate assignment.
  /// (In Phase 5, this works alongside ConstraintEngine to provide UX-friendly feedback)
  static List<DetailedConflict> detectConflicts({
    required SlotAssignment candidate,
    required TimetableContext context,
  }) {
    List<DetailedConflict> conflicts = [];

    for (var existing in context.existingAssignments) {
      if (existing.timeSlot.overlapsWith(candidate.timeSlot)) {
        // Faculty Clash
        if (existing.session.facultyId == candidate.session.facultyId) {
          conflicts.add(DetailedConflict(
            severity: ConflictSeverity.high,
            cause: 'Faculty double-booked: already teaching ${existing.session.subjectName} in ${existing.classroom.code}',
            suggestedResolution: 'Move ${candidate.session.subjectName} to a time slot where faculty is free.',
            involvedEntityIds: [candidate.session.facultyId, existing.timeSlot.id],
          ));
        }

        // Room Clash
        if (existing.classroom.id == candidate.classroom.id) {
          conflicts.add(DetailedConflict(
            severity: ConflictSeverity.high,
            cause: 'Room ${candidate.classroom.code} is occupied by ${existing.session.subjectName}',
            suggestedResolution: 'Select a different room with capacity >= ${candidate.session.studentCount}.',
            involvedEntityIds: [candidate.classroom.id, existing.timeSlot.id],
          ));
        }
      }
    }

    // Capacity Clash
    if (candidate.classroom.capacity < candidate.session.studentCount) {
      conflicts.add(DetailedConflict(
        severity: ConflictSeverity.medium,
        cause: 'Room ${candidate.classroom.code} capacity (${candidate.classroom.capacity}) is less than class size (${candidate.session.studentCount})',
        suggestedResolution: 'Move to a larger room like an Auditorium.',
        involvedEntityIds: [candidate.classroom.id],
      ));
    }

    return conflicts;
  }
}

import '../models/scheduling_models.dart';
import '../models/rule_models.dart';
import 'constraint_engine.dart';

class SchedulingResultV2 {
  final bool isSuccess;
  final List<SlotAssignment> assignments;
  final int totalIterations;

  const SchedulingResultV2({
    required this.isSuccess,
    required this.assignments,
    required this.totalIterations,
  });
}

class CoreSchedulingEngine {
  final ConstraintEngine constraintEngine;
  
  CoreSchedulingEngine({required this.constraintEngine});

  /// Generates a timetable using CSP Backtracking with MRV (Minimum Remaining Values) heuristic.
  SchedulingResultV2 generateSchedule({
    required List<SubjectSession> unassignedSessions,
    required List<TimeSlot> availableTimeSlots,
    required TimetableContext context,
  }) {
    List<SlotAssignment> currentAssignments = List.from(context.existingAssignments);
    int iterations = 0;

    bool backtrack(List<SubjectSession> remainingSessions) {
      iterations++;
      
      if (remainingSessions.isEmpty) {
        return true; // All assigned successfully
      }

      // Variable Selection: MRV (Sort by fewest valid room/time combinations)
      // For performance in this demo, we'll just pick the first, 
      // but a true MRV would count valid valid combinations for each session here.
      SubjectSession currentSession = remainingSessions.removeAt(0);

      // Value Selection: Try all TimeSlots x Rooms
      for (var room in context.allRooms) {
        // Filter room by required type early
        if (room.roomType != currentSession.requiredRoomType) continue;
        if (room.capacity < currentSession.studentCount) continue;

        for (var timeSlot in availableTimeSlots) {
          final candidate = SlotAssignment(
            session: currentSession,
            timeSlot: timeSlot,
            classroom: room,
          );

          // Evaluate Hard Constraints
          bool isHardViolated = constraintEngine.isHardConstraintViolated(
            candidate, 
            TimetableContext(
              existingAssignments: currentAssignments,
              allRooms: context.allRooms,
              allFaculty: context.allFaculty,
            ),
          );

          if (!isHardViolated) {
            // Assign and Recurse
            currentAssignments.add(candidate);
            
            if (backtrack(remainingSessions)) {
              return true;
            }
            
            // Backtrack if failed
            currentAssignments.removeLast();
          }
        }
      }

      // If no valid assignment found, put it back and fail this path
      remainingSessions.insert(0, currentSession);
      return false;
    }

    bool success = backtrack(List.from(unassignedSessions));

    return SchedulingResultV2(
      isSuccess: success,
      assignments: currentAssignments,
      totalIterations: iterations,
    );
  }
}

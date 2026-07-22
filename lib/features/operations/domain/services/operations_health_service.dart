import '../models/operations_models.dart';
import 'package:eduflow/features/timetable/domain/models/versioning_models.dart';

class OperationsHealthService {
  /// Calculates a Daily Operational Health Score (0-100)
  static double calculateDailyHealthScore({
    required DateTime date,
    required TimetableVersion publishedTimetable,
    required List<FacultyLeave> activeLeaves,
    required List<AttendanceRecord> todaysAttendanceLogs,
    required List<RoomChangeRequest> roomChangeRequests,
  }) {
    double score = 100.0;

    // 1. Penalize for uncovered leaves (-15 pts each)
    for (var leave in activeLeaves) {
      if (leave.status == LeaveStatus.approved && leave.substituteFacultyId == null) {
        // Checking if the leave is for today (simplified check for demo)
        if (date.isAfter(leave.startDate.subtract(const Duration(days: 1))) && 
            date.isBefore(leave.endDate.add(const Duration(days: 1)))) {
          score -= 15.0;
        }
      }
    }

    // 2. Penalize for missed attendance logs (-5 pts each missed class)
    // Find all classes scheduled for today
    int expectedClassesToday = publishedTimetable.assignments
        .where((a) => a.timeSlot.dayOfWeek == date.weekday) // 1=Mon, 7=Sun
        .length;
    
    // Group attendance logs by sessionId to count unique classes where attendance was taken
    Set<String> sessionsWithAttendance = todaysAttendanceLogs.map((log) => log.sessionId).toSet();
    int missedAttendanceClasses = expectedClassesToday - sessionsWithAttendance.length;
    
    if (missedAttendanceClasses > 0) {
      score -= (missedAttendanceClasses * 5.0);
    }

    // 3. Penalize for Room Changes (-2 pts each, indicates friction/instability)
    for (var req in roomChangeRequests) {
      if (req.status == RoomChangeStatus.approved) {
        score -= 2.0;
      }
    }

    return score.clamp(0.0, 100.0);
  }
}

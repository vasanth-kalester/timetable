import '../models/examination_models.dart';
import 'package:eduflow/features/infrastructure/domain/models/infrastructure_models.dart';
import 'package:eduflow/features/timetable/domain/models/scheduling_models.dart';

class SimulatorReport {
  final int totalHallsRequired;
  final int peakFacultyRequired;
  final List<String> detectedClashes;
  final bool isFeasible;

  const SimulatorReport({
    required this.totalHallsRequired,
    required this.peakFacultyRequired,
    required this.detectedClashes,
    required this.isFeasible,
  });
}

class ExamImpactSimulator {
  /// Runs a pre-flight check on an ExamTimetable before publishing.
  static SimulatorReport simulateImpact({
    required ExamTimetable timetable,
    required List<Room> allRooms,
    required List<FacultyEntity> allFaculty,
    double seatingDensityFactor = 0.5,
  }) {
    List<String> clashes = [];
    int maxSimultaneousHalls = 0;
    int maxSimultaneousFaculty = 0;

    // Group sessions by date and startTime
    Map<String, List<ExamSession>> simultaneousSessions = {};
    for (var session in timetable.sessions) {
      String timeKey = '${session.date.toIso8601String()}_${session.startTimeMinutes}';
      if (!simultaneousSessions.containsKey(timeKey)) {
        simultaneousSessions[timeKey] = [];
      }
      simultaneousSessions[timeKey]!.add(session);
    }

    // Evaluate each time slot
    for (var timeKey in simultaneousSessions.keys) {
      var concurrentSessions = simultaneousSessions[timeKey]!;
      
      int totalStudentsInSlot = 0;
      for (var session in concurrentSessions) {
        totalStudentsInSlot += session.expectedStudentCount;
      }

      // Check Room Capacity
      int availableCampusCapacity = allRooms
          .where((r) => r.currentStatus != ResourceStatus.maintenance)
          .fold(0, (sum, r) => sum + (r.capacity * seatingDensityFactor).floor());
          
      if (totalStudentsInSlot > availableCampusCapacity) {
        clashes.add('Not enough hall capacity at $timeKey. Need $totalStudentsInSlot seats, only $availableCampusCapacity available (at ${seatingDensityFactor*100}% density).');
      }

      // Estimate Halls required
      // Simplistic greedy estimate: Assume we use biggest rooms first
      final sortedRooms = List<Room>.from(allRooms)
        ..sort((a, b) => b.capacity.compareTo(a.capacity));
      
      int hallsNeeded = 0;
      int studentsLeft = totalStudentsInSlot;
      for (var room in sortedRooms) {
        if (studentsLeft <= 0) break;
        int effCap = (room.capacity * seatingDensityFactor).floor();
        if (effCap > 0) {
          hallsNeeded++;
          studentsLeft -= effCap;
        }
      }

      if (hallsNeeded > maxSimultaneousHalls) {
        maxSimultaneousHalls = hallsNeeded;
      }

      // Invigilators required (1 per hall)
      int invigilatorsNeeded = hallsNeeded;
      if (invigilatorsNeeded > allFaculty.length) {
        clashes.add('Not enough faculty for invigilation at $timeKey. Need $invigilatorsNeeded, only ${allFaculty.length} available.');
      }

      if (invigilatorsNeeded > maxSimultaneousFaculty) {
        maxSimultaneousFaculty = invigilatorsNeeded;
      }
    }

    return SimulatorReport(
      totalHallsRequired: maxSimultaneousHalls,
      peakFacultyRequired: maxSimultaneousFaculty,
      detectedClashes: clashes,
      isFeasible: clashes.isEmpty,
    );
  }
}

import '../models/operations_models.dart';
import 'package:eduflow/features/timetable/domain/models/scheduling_models.dart';
import 'package:eduflow/features/timetable/domain/models/rule_models.dart';
import 'package:eduflow/features/timetable/domain/models/versioning_models.dart';

class SubstituteSuggestion {
  final FacultyEntity faculty;
  final int matchScore;
  final List<String> matchReasons;

  const SubstituteSuggestion({
    required this.faculty,
    required this.matchScore,
    required this.matchReasons,
  });
}

class SubstituteEngine {
  /// Finds and ranks available substitute faculty for an approved leave.
  static List<SubstituteSuggestion> findSubstitutes({
    required FacultyLeave leave,
    required TimetableVersion publishedTimetable,
    required TimetableContext context, // contains all faculty
  }) {
    // 1. Identify which classes the absent faculty is missing during their leave
    final missingClasses = publishedTimetable.assignments.where((a) {
      bool isTargetFaculty = a.session.facultyId == leave.facultyId;
      // In a real app, you'd convert TimeSlot to actual dates and check against leave.startDate/endDate.
      // For this pure domain logic demo, we'll assume the leave covers exactly the days of these slots.
      return isTargetFaculty; 
    }).toList();

    if (missingClasses.isEmpty) return [];

    // The absent faculty's department
    final absentFaculty = context.allFaculty.firstWhere((f) => f.id == leave.facultyId);
    final String targetDepartmentId = absentFaculty.departmentId;

    List<SubstituteSuggestion> suggestions = [];

    // 2. Evaluate every other faculty
    for (var candidateFaculty in context.allFaculty) {
      if (candidateFaculty.id == leave.facultyId) continue; // Skip the absent person

      bool isAvailable = true;
      int score = 0;
      List<String> reasons = [];

      // A. Check Availability (Cannot be teaching at the same time as missing classes)
      for (var missingClass in missingClasses) {
        bool candidateBusy = publishedTimetable.assignments.any(
          (a) => a.session.facultyId == candidateFaculty.id && a.timeSlot.overlapsWith(missingClass.timeSlot)
        );
        if (candidateBusy) {
          isAvailable = false;
          break; // Hard constraint failed
        }
      }

      if (!isAvailable) continue; // Skip busy faculty

      // B. Scoring: Department Match (+50)
      if (candidateFaculty.departmentId == targetDepartmentId) {
        score += 50;
        reasons.add('Same Department');
      }

      // C. Scoring: Workload Balance (+ up to 30 based on lowest hours)
      // Calculate candidate's current workload in the timetable
      int currentWorkloadMinutes = publishedTimetable.assignments
          .where((a) => a.session.facultyId == candidateFaculty.id)
          .fold(0, (sum, a) => sum + a.timeSlot.durationMinutes);
      
      // Assume a max weekly workload is 24 hours (1440 minutes).
      // The lower the current workload, the higher the score.
      double workloadRatio = currentWorkloadMinutes / 1440.0;
      int workloadScore = ((1.0 - workloadRatio.clamp(0.0, 1.0)) * 30).round();
      
      score += workloadScore;
      if (workloadScore > 15) {
        reasons.add('Low Workload ($currentWorkloadMinutes min/week)');
      }

      suggestions.add(SubstituteSuggestion(
        faculty: candidateFaculty,
        matchScore: score,
        matchReasons: reasons,
      ));
    }

    // 3. Rank by score descending
    suggestions.sort((a, b) => b.matchScore.compareTo(a.matchScore));

    return suggestions;
  }
}

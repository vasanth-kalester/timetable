import '../models/examination_models.dart';

class ExamSchedulingEngine {
  /// Basic check to ensure an ExamTimetable is valid.
  /// A valid timetable ensures no single semester batch has two exams on the same day.
  static bool validateTimetable(ExamTimetable timetable) {
    Map<String, Set<String>> dateToSemesters = {};

    for (var session in timetable.sessions) {
      String dateKey = session.date.toIso8601String().split('T')[0];
      
      if (!dateToSemesters.containsKey(dateKey)) {
        dateToSemesters[dateKey] = {};
      }

      // If the semester already has an exam on this date, conflict!
      if (dateToSemesters[dateKey]!.contains(session.semesterId)) {
        return false;
      }
      
      dateToSemesters[dateKey]!.add(session.semesterId);
    }

    return true; // No daily clashes for any semester batch
  }
}

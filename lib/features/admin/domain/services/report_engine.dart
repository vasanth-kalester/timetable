import '../models/admin_models.dart';
import 'package:eduflow/features/timetable/domain/models/versioning_models.dart';
import 'package:eduflow/features/timetable/domain/models/scheduling_models.dart';
import 'package:uuid/uuid.dart';

class ReportEngine {
  /// Extracts a tabular Faculty Workload Report from the timetable.
  static GeneratedReport generateFacultyWorkloadReport({
    required TimetableVersion timetable,
    required List<FacultyEntity> allFaculty,
  }) {
    List<String> headers = ['Faculty ID', 'Faculty Name', 'Department ID', 'Total Classes', 'Total Minutes'];
    List<List<dynamic>> rows = [];

    // Map to accumulate workload
    Map<String, int> classCount = {};
    Map<String, int> minuteCount = {};

    for (var a in timetable.assignments) {
      String fId = a.session.facultyId;
      classCount[fId] = (classCount[fId] ?? 0) + 1;
      minuteCount[fId] = (minuteCount[fId] ?? 0) + a.timeSlot.durationMinutes;
    }

    for (var faculty in allFaculty) {
      rows.add([
        faculty.id,
        faculty.name,
        faculty.departmentId,
        classCount[faculty.id] ?? 0,
        minuteCount[faculty.id] ?? 0,
      ]);
    }

    return GeneratedReport(
      id: const Uuid().v4(),
      title: 'Faculty Workload Report',
      generatedAt: DateTime.now(),
      headers: headers,
      rows: rows,
    );
  }
}

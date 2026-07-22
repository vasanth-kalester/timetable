// --- CONFIGURATION ENTITIES ---

class SystemConfig {
  final String institutionName;
  final List<int> workingDays; // 1 = Monday, 7 = Sunday
  final int defaultTimeSlotsPerDay;
  final int semesterDurationWeeks;
  final LeavePolicy defaultLeavePolicy;
  final Map<String, List<String>> rolePermissions; // Role -> List of actions

  const SystemConfig({
    required this.institutionName,
    required this.workingDays,
    required this.defaultTimeSlotsPerDay,
    required this.semesterDurationWeeks,
    required this.defaultLeavePolicy,
    required this.rolePermissions,
  });
}

class LeavePolicy {
  final int casualLeaveLimit;
  final int sickLeaveLimit;
  final bool requiresHodApproval;

  const LeavePolicy({
    required this.casualLeaveLimit,
    required this.sickLeaveLimit,
    this.requiresHodApproval = true,
  });
}

// --- REPORTING ENTITIES ---

enum ReportType {
  attendance,
  workload,
  utilization,
  grades
}

class GeneratedReport {
  final String id;
  final String title;
  final DateTime generatedAt;
  final List<String> headers;
  final List<List<dynamic>> rows;

  const GeneratedReport({
    required this.id,
    required this.title,
    required this.generatedAt,
    required this.headers,
    required this.rows,
  });

  /// Simple CSV converter logic on the entity itself for easy export
  String toCsv() {
    StringBuffer buffer = StringBuffer();
    buffer.writeln(headers.join(','));
    for (var row in rows) {
      buffer.writeln(row.map((e) => '"$e"').join(','));
    }
    return buffer.toString();
  }
}

// --- ANALYTICS ENTITIES ---

class PrincipalMetrics {
  final double overallAttendanceRate; // 0-100
  final double campusUtilizationPercent; // 0-100
  final double facultyPresenceRate; // 0-100
  final int activeAlertsCount;

  const PrincipalMetrics({
    required this.overallAttendanceRate,
    required this.campusUtilizationPercent,
    required this.facultyPresenceRate,
    required this.activeAlertsCount,
  });
}

class HodMetrics {
  final String departmentId;
  final double departmentAttendanceRate;
  final double facultyWorkloadStdDev; // Lower is better
  final int classesScheduledToday;
  final int pendingLeaveApprovals;

  const HodMetrics({
    required this.departmentId,
    required this.departmentAttendanceRate,
    required this.facultyWorkloadStdDev,
    required this.classesScheduledToday,
    required this.pendingLeaveApprovals,
  });
}

class FacultyMetrics {
  final String facultyId;
  final int totalTeachingHoursWeekly;
  final int upcomingClassesToday;
  final int assessmentsPendingGrading;

  const FacultyMetrics({
    required this.facultyId,
    required this.totalTeachingHoursWeekly,
    required this.upcomingClassesToday,
    required this.assessmentsPendingGrading,
  });
}

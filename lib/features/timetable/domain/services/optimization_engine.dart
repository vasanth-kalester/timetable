import '../models/scheduling_models.dart';
import 'constraint_engine.dart';
import '../models/rule_models.dart';

class OptimizationScoreV2 {
  final double overallScore; // 0-100
  final double facultyBalanceScore; // 0-100
  final double roomUtilizationScore; // 0-100
  final double studentGapScore; // 0-100
  final int totalSoftPenalties;

  const OptimizationScoreV2({
    required this.overallScore,
    required this.facultyBalanceScore,
    required this.roomUtilizationScore,
    required this.studentGapScore,
    required this.totalSoftPenalties,
  });

  @override
  String toString() => 'Overall: ${overallScore.toStringAsFixed(1)}% (Fac: $facultyBalanceScore%, Room: $roomUtilizationScore%, Gap: $studentGapScore%)';
}

class OptimizationEngineV2 {
  static OptimizationScoreV2 calculateScore({
    required List<SlotAssignment> assignments,
    required TimetableContext context,
    required ConstraintEngine constraintEngine,
  }) {
    if (assignments.isEmpty) {
      return const OptimizationScoreV2(
        overallScore: 0, facultyBalanceScore: 0, roomUtilizationScore: 0, studentGapScore: 0, totalSoftPenalties: 0,
      );
    }

    // 1. Faculty Workload Balance (Standard Deviation of hours)
    Map<String, int> facultyHours = {};
    for (var a in assignments) {
      facultyHours[a.session.facultyId] = (facultyHours[a.session.facultyId] ?? 0) + a.timeSlot.durationMinutes;
    }
    
    double avgHours = facultyHours.values.fold(0, (a, b) => a + b) / (facultyHours.isEmpty ? 1 : facultyHours.length);
    double variance = facultyHours.values.fold(0.0, (val, hours) => val + ((hours - avgHours) * (hours - avgHours)));
    double stdDev = variance / (facultyHours.isEmpty ? 1 : facultyHours.length);
    
    // Lower stdDev is better (more balanced). Map stdDev to 0-100 score.
    double facBalance = 100 - (stdDev / 100).clamp(0.0, 100.0);

    // 2. Room Utilization
    // Simple heuristic: Total assigned hours / Total available hours
    int totalAvailableRoomMinutes = context.allRooms.length * 5 * 8 * 60; // 5 days, 8 hours
    int totalAssignedRoomMinutes = assignments.fold(0, (sum, a) => sum + a.timeSlot.durationMinutes);
    double roomUtil = (totalAssignedRoomMinutes / totalAvailableRoomMinutes) * 100;
    roomUtil = roomUtil.clamp(0.0, 100.0);

    // 3. Student Gaps
    // Simplified heuristic: penalize days where students have only 1 class or huge gaps.
    double studentGap = 90.0; // Placeholder for complex gap calculation

    // 4. Soft Penalties
    int totalPenalties = 0;
    for (var a in assignments) {
      totalPenalties += constraintEngine.calculatePenalty(a, context);
    }

    // Calculate Overall (Weighted)
    double overall = (facBalance * 0.4) + (roomUtil * 0.4) + (studentGap * 0.2);
    overall -= totalPenalties;
    
    return OptimizationScoreV2(
      overallScore: overall.clamp(0.0, 100.0),
      facultyBalanceScore: facBalance,
      roomUtilizationScore: roomUtil,
      studentGapScore: studentGap,
      totalSoftPenalties: totalPenalties,
    );
  }
}

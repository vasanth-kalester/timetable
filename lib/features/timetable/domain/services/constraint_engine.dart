import '../models/rule_models.dart';
import '../models/scheduling_models.dart';

class ConstraintEngine {
  final List<SchedulingRule> activeRules;

  ConstraintEngine({required this.activeRules});

  /// Evaluates a candidate assignment against all active rules.
  /// Returns a list of violated rules.
  List<SchedulingRule> evaluateCandidate(SlotAssignment candidate, TimetableContext context) {
    List<SchedulingRule> violations = [];
    
    for (var rule in activeRules) {
      if (!rule.evaluate(candidate, context)) {
        violations.add(rule);
      }
    }
    
    return violations;
  }

  /// Checks if any HARD rule is violated.
  bool isHardConstraintViolated(SlotAssignment candidate, TimetableContext context) {
    final violations = evaluateCandidate(candidate, context);
    return violations.any((rule) => rule.severity == RuleSeverity.hard);
  }

  /// Calculates the total penalty score from SOFT rule violations.
  int calculatePenalty(SlotAssignment candidate, TimetableContext context) {
    final violations = evaluateCandidate(candidate, context);
    int penalty = 0;
    for (var rule in violations) {
      if (rule.severity == RuleSeverity.soft) {
        penalty += rule.penaltyScore;
      }
    }
    return penalty;
  }
}

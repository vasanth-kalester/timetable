import '../models/versioning_models.dart';
import '../models/scheduling_models.dart';
import 'package:uuid/uuid.dart';

class SimulationEngine {
  /// Branches a published timetable into a simulation version
  static TimetableVersion branchSimulation(TimetableVersion original) {
    return original.copyWith(
      id: const Uuid().v4(),
      name: '${original.name} (Simulation)',
      status: TimetableStatus.simulation,
      parentVersionId: original.id,
      createdAt: DateTime.now(),
      // Deep copy assignments to prevent mutating the original
      assignments: List<SlotAssignment>.from(original.assignments),
    );
  }

  /// Calculates the difference between two versions (e.g. Base vs Simulation)
  static VersionDiff calculateDiff({
    required TimetableVersion baseVersion,
    required TimetableVersion newVersion,
  }) {
    List<SlotAssignment> added = [];
    List<SlotAssignment> removed = [];
    List<SlotAssignment> modified = [];

    // Simple diffing logic based on Session ID
    Map<String, SlotAssignment> baseMap = {for (var a in baseVersion.assignments) a.session.id: a};
    Map<String, SlotAssignment> newMap = {for (var a in newVersion.assignments) a.session.id: a};

    for (var newAssignment in newVersion.assignments) {
      if (!baseMap.containsKey(newAssignment.session.id)) {
        added.add(newAssignment);
      } else {
        // Exists in both, check if time or room changed
        var baseAssignment = baseMap[newAssignment.session.id]!;
        if (baseAssignment.timeSlot.id != newAssignment.timeSlot.id ||
            baseAssignment.classroom.id != newAssignment.classroom.id) {
          modified.add(newAssignment);
        }
      }
    }

    for (var baseAssignment in baseVersion.assignments) {
      if (!newMap.containsKey(baseAssignment.session.id)) {
        removed.add(baseAssignment);
      }
    }

    return VersionDiff(
      baseVersion: baseVersion,
      newVersion: newVersion,
      addedAssignments: added,
      removedAssignments: removed,
      modifiedAssignments: modified,
    );
  }
}

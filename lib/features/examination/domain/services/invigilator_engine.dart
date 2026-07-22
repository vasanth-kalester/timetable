import '../models/examination_models.dart';
import 'package:eduflow/features/timetable/domain/models/scheduling_models.dart';
import 'package:uuid/uuid.dart';

class InvigilatorEngine {
  /// Assigns faculty to hall allocations.
  /// Balances workload and avoids assigning faculty from the same department as the subject.
  static List<InvigilatorAssignment> assignInvigilators({
    required List<HallAllocation> allocations,
    required ExamSession session,
    required List<FacultyEntity> availableFaculty,
    required Map<String, int> currentInvigilationCounts, // Track duties per faculty for fairness
  }) {
    List<InvigilatorAssignment> assignments = [];
    
    // Sort available faculty by least number of invigilation duties to distribute workload fairly
    final sortedFaculty = List<FacultyEntity>.from(availableFaculty)
      ..sort((a, b) => (currentInvigilationCounts[a.id] ?? 0).compareTo(currentInvigilationCounts[b.id] ?? 0));

    int facultyIndex = 0;

    for (var allocation in allocations) {
      bool assigned = false;
      
      while (facultyIndex < sortedFaculty.length) {
        var candidate = sortedFaculty[facultyIndex];
        
        // Anti-bias rule: avoid same department if possible. 
        // For strictness in this domain test, we enforce it.
        if (candidate.departmentId != session.departmentId) {
          assignments.add(InvigilatorAssignment(
            id: const Uuid().v4(),
            hallAllocationId: allocation.id,
            facultyId: candidate.id,
            status: AllocationStatus.pending,
          ));
          
          // Increment their count for the rest of the run
          currentInvigilationCounts[candidate.id] = (currentInvigilationCounts[candidate.id] ?? 0) + 1;
          facultyIndex++; // Move to next faculty for the next hall
          assigned = true;
          break;
        }
        
        facultyIndex++;
      }

      if (!assigned) {
        throw Exception('Not enough valid invigilators for session ${session.id}. Required: ${allocations.length}, Available/Valid: ${assignments.length}');
      }
    }

    return assignments;
  }
}

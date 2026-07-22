import '../models/examination_models.dart';
import 'package:eduflow/features/infrastructure/domain/models/infrastructure_models.dart';
import 'package:uuid/uuid.dart';

class HallAllocationEngine {
  /// Allocates students to available rooms for a given ExamSession.
  /// Exam hall capacity is typically reduced by `seatingDensityFactor` (e.g., 50%) 
  /// for spacing to prevent cheating.
  static List<HallAllocation> allocateHalls({
    required ExamSession session,
    required List<Room> availableRooms,
    double seatingDensityFactor = 0.5,
  }) {
    List<HallAllocation> allocations = [];
    int remainingStudents = session.expectedStudentCount;
    int currentStudentId = 1; // Simulated student IDs for this domain logic

    // Sort rooms by capacity descending (try to fill large rooms first)
    final sortedRooms = List<Room>.from(availableRooms)
      ..sort((a, b) => b.capacity.compareTo(a.capacity));

    for (var room in sortedRooms) {
      if (remainingStudents <= 0) break;
      if (room.currentStatus == ResourceStatus.maintenance) continue;

      int effectiveCapacity = (room.capacity * seatingDensityFactor).floor();
      if (effectiveCapacity == 0) continue;

      int studentsToAllocateToThisRoom = remainingStudents > effectiveCapacity ? effectiveCapacity : remainingStudents;

      List<String> allocatedIds = [];
      for (int i = 0; i < studentsToAllocateToThisRoom; i++) {
        allocatedIds.add('STU_${session.semesterId}_${currentStudentId++}');
      }

      allocations.add(HallAllocation(
        id: const Uuid().v4(),
        examSessionId: session.id,
        roomId: room.id,
        allocatedStudentIds: allocatedIds,
      ));

      remainingStudents -= studentsToAllocateToThisRoom;
    }

    if (remainingStudents > 0) {
      throw Exception('Not enough hall capacity. $remainingStudents students unallocated for session ${session.id}.');
    }

    return allocations;
  }
}

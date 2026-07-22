import 'scheduling_models.dart';

enum TimetableStatus {
  draft,
  simulation,
  approved,
  published,
  archived
}

class TimetableVersion {
  final String id;
  final String name;
  final TimetableStatus status;
  final DateTime createdAt;
  final double optimizationScore;
  final List<SlotAssignment> assignments;
  final String? parentVersionId;

  const TimetableVersion({
    required this.id,
    required this.name,
    required this.status,
    required this.createdAt,
    required this.optimizationScore,
    required this.assignments,
    this.parentVersionId,
  });

  TimetableVersion copyWith({
    String? id,
    String? name,
    TimetableStatus? status,
    DateTime? createdAt,
    double? optimizationScore,
    List<SlotAssignment>? assignments,
    String? parentVersionId,
  }) {
    return TimetableVersion(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      optimizationScore: optimizationScore ?? this.optimizationScore,
      assignments: assignments ?? this.assignments,
      parentVersionId: parentVersionId ?? this.parentVersionId,
    );
  }
}

class VersionDiff {
  final TimetableVersion baseVersion;
  final TimetableVersion newVersion;
  
  final List<SlotAssignment> addedAssignments;
  final List<SlotAssignment> removedAssignments;
  final List<SlotAssignment> modifiedAssignments; // Conceptually, removed from old time/room and added to new

  const VersionDiff({
    required this.baseVersion,
    required this.newVersion,
    required this.addedAssignments,
    required this.removedAssignments,
    required this.modifiedAssignments,
  });
}

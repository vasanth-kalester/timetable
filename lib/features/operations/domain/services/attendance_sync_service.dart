import '../models/operations_models.dart';
import 'package:eduflow/features/timetable/domain/models/versioning_models.dart';
import 'package:eduflow/features/timetable/domain/models/scheduling_models.dart';

class AttendanceSyncService {
  final List<AttendanceRecord> _offlineQueue = [];
  final List<AttendanceRecord> _syncedDatabase = []; // Mock backend for domain tests

  /// Marks attendance. If offline, queues it. If online, syncs it immediately.
  Future<void> markAttendance({
    required AttendanceRecord record,
    required bool isOnline,
    required TimetableVersion publishedTimetable,
  }) async {
    // 1. Validate that the class exists in the published timetable
    final isValidSession = publishedTimetable.assignments.any((a) => a.session.id == record.sessionId);
    if (!isValidSession) {
      throw Exception('Cannot mark attendance: Session ${record.sessionId} does not exist in the published timetable.');
    }

    if (isOnline) {
      // Sync immediately
      final syncedRecord = record.copyWith(isSynced: true);
      _syncedDatabase.add(syncedRecord);
    } else {
      // Save to offline queue
      final offlineRecord = record.copyWith(isSynced: false);
      _offlineQueue.add(offlineRecord);
    }
  }

  /// Flushes the offline queue when connectivity is restored.
  Future<int> syncPendingRecords() async {
    int syncCount = 0;
    
    // In a real app, this would be an API call batch insert.
    // For now, we move from queue to database.
    for (var record in _offlineQueue) {
      final syncedRecord = record.copyWith(isSynced: true);
      _syncedDatabase.add(syncedRecord);
      syncCount++;
    }
    
    _offlineQueue.clear();
    return syncCount;
  }

  // Getters for testing
  List<AttendanceRecord> get offlineQueue => List.unmodifiable(_offlineQueue);
  List<AttendanceRecord> get syncedDatabase => List.unmodifiable(_syncedDatabase);
}

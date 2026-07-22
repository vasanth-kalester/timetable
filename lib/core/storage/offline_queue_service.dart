import 'sync_action.dart';

/// Simulates a Hive-backed offline queue for the domain testing
class OfflineQueueService {
  final List<SyncAction> _queue = [];

  void enqueue(SyncAction action) {
    _queue.add(action);
  }

  List<SyncAction> getPendingActions() {
    // Sort chronologically (oldest first)
    final sorted = List<SyncAction>.from(_queue)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return sorted;
  }

  void removeAction(String id) {
    _queue.removeWhere((a) => a.id == id);
  }

  void incrementRetry(String id) {
    final index = _queue.indexWhere((a) => a.id == id);
    if (index != -1) {
      _queue[index].retryCount++;
    }
  }

  void clear() {
    _queue.clear();
  }
}

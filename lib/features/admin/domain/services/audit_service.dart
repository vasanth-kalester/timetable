import 'package:eduflow/features/operations/domain/models/operations_models.dart';
import 'package:uuid/uuid.dart';

class AuditService {
  final List<AuditLog> _logs = [];

  /// Logs a critical action to the immutable audit trail.
  void logAction({
    required String userId,
    required String action,
    required String details,
  }) {
    final log = AuditLog(
      id: const Uuid().v4(),
      userId: userId,
      action: action,
      details: details,
      timestamp: DateTime.now().toUtc(), // Always use UTC for audits
    );
    _logs.add(log);
  }

  /// Retrieves an immutable copy of the logs (cannot be altered by UI)
  List<AuditLog> getLogs() {
    return List.unmodifiable(_logs);
  }
}

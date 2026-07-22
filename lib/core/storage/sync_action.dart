import 'package:uuid/uuid.dart';

enum ActionType { post, put, delete }

class SyncAction {
  final String id;
  final String endpoint;
  final Map<String, dynamic> payload;
  final ActionType actionType;
  final DateTime timestamp;
  int retryCount;

  SyncAction({
    String? id,
    required this.endpoint,
    required this.payload,
    required this.actionType,
    DateTime? timestamp,
    this.retryCount = 0,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now();
}

class AuditLog {
  final String id;
  final String userId;
  final String role;
  final String action;
  final String entity;
  final String entityId;
  final String? oldValue;
  final String? newValue;
  final String? reason;
  final String timestamp;

  AuditLog({
    required this.id,
    required this.userId,
    required this.role,
    required this.action,
    required this.entity,
    required this.entityId,
    this.oldValue,
    this.newValue,
    this.reason,
    required this.timestamp,
  });

  factory AuditLog.fromJson(Map<String, dynamic> json) {
    return AuditLog(
      id: json['id'],
      userId: json['userId'],
      role: json['role'],
      action: json['action'],
      entity: json['entity'],
      entityId: json['entityId'],
      oldValue: json['oldValue'],
      newValue: json['newValue'],
      reason: json['reason'],
      timestamp: json['timestamp'],
    );
  }
}

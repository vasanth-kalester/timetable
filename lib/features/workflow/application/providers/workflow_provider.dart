import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';

final workflowProvider = Provider<WorkflowService>((ref) {
  return WorkflowService(ref.read(dioClientProvider));
});

class WorkflowService {
  final Dio _dio;

  WorkflowService(this._dio);

  // Workflow & Approvals
  Future<Map<String, dynamic>> triggerEvent(String eventType, Map<String, dynamic> context) async {
    try {
      final response = await _dio.post('/workflow/trigger-event', data: {
        'event_type': eventType,
        'context': context,
      });
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> processApproval(String requestId, String approverId, String action, {String? comments}) async {
    try {
      final response = await _dio.post('/workflow/approvals/$requestId/process', data: {
        'approver_id': approverId,
        'action': action,
        'comments': comments,
      });
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // Communication
  Future<Map<String, dynamic>> publishAnnouncement(String title, String content, String authorId, String targetAudience, {String? targetDepartmentId}) async {
    try {
      final response = await _dio.post('/communication/announcements', data: {
        'title': title,
        'content': content,
        'author_id': authorId,
        'target_audience': targetAudience,
        'target_department_id': targetDepartmentId,
      });
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getNotifications(String userId, {bool unreadOnly = false}) async {
    try {
      final response = await _dio.get('/communication/notifications/$userId', queryParameters: {
        'unread_only': unreadOnly,
      });
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // Calendar & Tasks
  Future<List<dynamic>> getUnifiedCalendar(String userId, String role, String startDate, String endDate) async {
    try {
      final response = await _dio.get('/calendar/unified', queryParameters: {
        'user_id': userId,
        'role': role,
        'start_date': startDate,
        'end_date': endDate,
      });
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createTask(String title, String description, String assigneeId, String dueDate, {String priority = 'medium'}) async {
    try {
      final response = await _dio.post('/calendar/tasks', data: {
        'title': title,
        'description': description,
        'assignee_id': assigneeId,
        'due_date': dueDate,
        'priority': priority,
      });
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getTasks(String userId, {String? status}) async {
    try {
      final response = await _dio.get('/calendar/tasks/$userId', queryParameters: {
        if (status != null) 'status': status,
      });
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}

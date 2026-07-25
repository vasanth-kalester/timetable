import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';

final operationsProvider = Provider<OperationsService>((ref) {
  return OperationsService(ref.read(dioClientProvider));
});

class OperationsService {
  final Dio _dio;

  OperationsService(this._dio);

  Future<Map<String, dynamic>> analyzeLeaveImpact(String facultyId, int date) async {
    try {
      final response = await _dio.get('/operations/leave-impact', queryParameters: {
        'facultyId': facultyId,
        'date': date,
      });
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> recommendSubstitutes(String sessionId, int dayOfWeek, int period) async {
    try {
      final response = await _dio.get('/operations/substitutes', queryParameters: {
        'sessionId': sessionId,
        'dayOfWeek': dayOfWeek,
        'period': period,
      });
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> recommendRooms(String roomId, int dayOfWeek, int period, {int duration = 1}) async {
    try {
      final response = await _dio.get('/operations/room-alternatives', queryParameters: {
        'roomId': roomId,
        'dayOfWeek': dayOfWeek,
        'period': period,
        'duration': duration,
      });
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> analyzeEventImpact(int date, int startPeriod, int endPeriod, {String? roomId, String? departmentId}) async {
    try {
      final queryParams = <String, dynamic>{
        'date': date,
        'startPeriod': startPeriod,
        'endPeriod': endPeriod,
      };
      if (roomId != null) queryParams['roomId'] = roomId;
      if (departmentId != null) queryParams['departmentId'] = departmentId;

      final response = await _dio.get('/operations/event-impact', queryParameters: queryParams);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> validateLiveChange(String timetableId, String sessionId, int newDay, int newPeriod, {String? newRoomId, String? newFacultyId}) async {
    try {
      final response = await _dio.post('/operations/validate-change', data: {
        'timetableId': timetableId,
        'sessionId': sessionId,
        'newDay': newDay,
        'newPeriod': newPeriod,
        'newRoomId': newRoomId,
        'newFacultyId': newFacultyId,
      });
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> rollbackVersion(String timetableId, String targetVersionId) async {
    try {
      await _dio.post('/operations/versions/$timetableId/rollback', queryParameters: {
        'target_version_id': targetVersionId,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getNotifications(String userId, {bool unreadOnly = false}) async {
    try {
      final response = await _dio.get('/operations/notifications/$userId', queryParameters: {
        'unread_only': unreadOnly,
      });
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}

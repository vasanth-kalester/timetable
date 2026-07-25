import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';

final sessionProvider = StateNotifierProvider<SessionNotifier, AsyncValue<List<dynamic>>>((ref) {
  return SessionNotifier(ref.read(dioClientProvider));
});

final sessionStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final dio = ref.read(dioClientProvider);
  final response = await dio.get('/sessions/stats');
  return response.data;
});

class SessionNotifier extends StateNotifier<AsyncValue<List<dynamic>>> {
  final Dio _dio;

  SessionNotifier(this._dio) : super(const AsyncValue.data([]));

  Future<void> getSessions({String? departmentId, String? semesterId, String? sessionType, String? status}) async {
    state = const AsyncValue.loading();
    try {
      final queryParams = <String, dynamic>{};
      if (departmentId != null) queryParams['departmentId'] = departmentId;
      if (semesterId != null) queryParams['semesterId'] = semesterId;
      if (sessionType != null) queryParams['sessionType'] = sessionType;
      if (status != null) queryParams['status'] = status;

      final response = await _dio.get('/sessions', queryParameters: queryParams);
      state = AsyncValue.data(response.data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> buildSessions(Map<String, dynamic> assignment) async {
    state = const AsyncValue.loading();
    try {
      await _dio.post('/sessions/build', data: assignment);
      await getSessions(); // Refresh list
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

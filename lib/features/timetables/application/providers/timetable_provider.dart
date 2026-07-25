import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';

final timetableProvider = StateNotifierProvider<TimetableNotifier, AsyncValue<List<dynamic>>>((ref) {
  return TimetableNotifier(ref.read(dioClientProvider));
});

class TimetableNotifier extends StateNotifier<AsyncValue<List<dynamic>>> {
  final Dio _dio;

  TimetableNotifier(this._dio) : super(const AsyncValue.data([]));

  Future<void> getTimetables({String? academicYearId, String? status}) async {
    state = const AsyncValue.loading();
    try {
      final queryParams = <String, dynamic>{};
      if (academicYearId != null) queryParams['academicYearId'] = academicYearId;
      if (status != null) queryParams['status'] = status;

      final response = await _dio.get('/timetables', queryParameters: queryParams);
      state = AsyncValue.data(response.data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<Map<String, dynamic>> generateTimetable(String academicYearId, String name) async {
    try {
      final response = await _dio.post('/timetables/generate', data: {
        'academicYearId': academicYearId,
        'name': name,
      });
      await getTimetables(); // Refresh list
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> validateManualEdit(String timetableId, String entryId, int newDay, int newPeriod, String? newRoom) async {
    try {
      final response = await _dio.post('/timetables/$timetableId/entries/$entryId/validate-edit', data: {
        'newDay': newDay,
        'newPeriod': newPeriod,
        'newRoom': newRoom,
      });
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> applyManualEdit(String timetableId, String entryId, int newDay, int newPeriod, String? newRoom) async {
    try {
      await _dio.put('/timetables/$timetableId/entries/$entryId', data: {
        'newDay': newDay,
        'newPeriod': newPeriod,
        'newRoom': newRoom,
      });
      // In a real app, we'd update the specific timetable in the state or refetch it
    } catch (e) {
      rethrow;
    }
  }
}

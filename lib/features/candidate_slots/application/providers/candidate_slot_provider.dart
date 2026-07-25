import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';

final candidateSlotProvider = StateNotifierProvider<CandidateSlotNotifier, AsyncValue<List<dynamic>>>((ref) {
  return CandidateSlotNotifier(ref.read(dioClientProvider));
});

final candidateSlotStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final dio = ref.read(dioClientProvider);
  final response = await dio.get('/candidate-slots/stats');
  return response.data;
});

class CandidateSlotNotifier extends StateNotifier<AsyncValue<List<dynamic>>> {
  final Dio _dio;

  CandidateSlotNotifier(this._dio) : super(const AsyncValue.data([]));

  Future<void> getCandidateSlots({String? sessionId, String? status}) async {
    state = const AsyncValue.loading();
    try {
      final queryParams = <String, dynamic>{};
      if (sessionId != null) queryParams['sessionId'] = sessionId;
      if (status != null) queryParams['status'] = status;

      final response = await _dio.get('/candidate-slots', queryParameters: queryParams);
      state = AsyncValue.data(response.data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> generateSlots() async {
    state = const AsyncValue.loading();
    try {
      await _dio.post('/candidate-slots/generate');
      await getCandidateSlots(); // Refresh list
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';

final constraintProvider = StateNotifierProvider<ConstraintNotifier, AsyncValue<List<dynamic>>>((ref) {
  return ConstraintNotifier(ref.read(dioClientProvider));
});

class ConstraintNotifier extends StateNotifier<AsyncValue<List<dynamic>>> {
  final Dio _dio;

  ConstraintNotifier(this._dio) : super(const AsyncValue.data([]));

  Future<void> getConstraints() async {
    state = const AsyncValue.loading();
    try {
      final response = await _dio.get('/constraints');
      state = AsyncValue.data(response.data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateConstraint(String id, Map<String, dynamic> updateData) async {
    try {
      await _dio.put('/constraints/$id', data: updateData);
      await getConstraints(); // Refresh list
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

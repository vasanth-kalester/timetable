import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';

final validationProvider = StateNotifierProvider<ValidationNotifier, AsyncValue<Map<String, dynamic>?>>((ref) {
  return ValidationNotifier(ref.read(dioClientProvider));
});

class ValidationNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {
  final Dio _dio;

  ValidationNotifier(this._dio) : super(const AsyncValue.data(null));

  Future<void> runValidation() async {
    state = const AsyncValue.loading();
    try {
      final response = await _dio.post('/validation/run');
      state = AsyncValue.data(response.data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> getLatestReport() async {
    state = const AsyncValue.loading();
    try {
      final response = await _dio.get('/validation/reports/latest');
      state = AsyncValue.data(response.data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

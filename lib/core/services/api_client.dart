import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../utils/app_failure.dart';

final logger = Logger();

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

class ApiClient {
  late final Dio dio;

  ApiClient({String baseUrl = 'https://api.eduflow.campus/v1'}) {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.extra['request_start_time'] = DateTime.now().millisecondsSinceEpoch;
          // Attach JWT bearer token if available
          const token = 'mock_jwt_token';
          options.headers['Authorization'] = 'Bearer $token';
          return handler.next(options);
        },
        onResponse: (response, handler) {
          final startTime = response.requestOptions.extra['request_start_time'] as int?;
          if (startTime != null) {
            final duration = DateTime.now().millisecondsSinceEpoch - startTime;
            if (duration > 150) {
              logger.w('[API Performance Warning] ${response.requestOptions.path} took $duration ms (Target: <150ms)');
            } else {
              logger.d('[API Performance] ${response.requestOptions.path} took $duration ms');
            }
          }
          return handler.next(response);
        },
        onError: (DioException error, handler) {
          logger.e('[API Error] ${error.message}', error: error);
          return handler.next(error);
        },
      ),
    );
  }

  AppFailure mapDioExceptionToFailure(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return const NetworkFailure();
    }
    if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
      return AuthFailure(e.response?.data?['message'] ?? 'Unauthorized access', e.response?.statusCode);
    }
    return ServerFailure(
      e.response?.data?['message'] ?? e.message ?? 'Unknown server error',
      e.response?.statusCode,
      e.response?.data,
    );
  }
}

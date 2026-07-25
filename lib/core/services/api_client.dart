import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../utils/app_failure.dart';
import 'hive_cache_service.dart';

final logger = Logger();

/// Base URL for the Python FastAPI backend.
/// Change this to match your server's IP when testing on a physical device.
const String kApiBaseUrl = 'http://192.168.0.110:8000/api/v1';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

class ApiClient {
  late final Dio dio;

  ApiClient({String? baseUrl}) {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? kApiBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Auth + performance logging interceptor
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.extra['request_start_time'] = DateTime.now().millisecondsSinceEpoch;

          // Attach stored JWT access token (synchronous Hive read)
          final token = HiveCacheService.getCachedData(
            HiveCacheService.userAuthBox,
            'auth_access_token',
          ) as String?;

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          final startTime = response.requestOptions.extra['request_start_time'] as int?;
          if (startTime != null) {
            final duration = DateTime.now().millisecondsSinceEpoch - startTime;
            if (duration > 150) {
              logger.w('[API Slow] ${response.requestOptions.path} = ${duration}ms');
            } else {
              logger.d('[API] ${response.requestOptions.path} → ${response.statusCode} (${duration}ms)');
            }
          }
          return handler.next(response);
        },
        onError: (DioException error, handler) {
          logger.e('[API Error] ${error.requestOptions.path}: ${error.message}');
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
      return AuthFailure(
        e.response?.data?['detail'] ?? 'Unauthorized access',
        e.response?.statusCode,
      );
    }
    return ServerFailure(
      e.response?.data?['detail'] ?? e.message ?? 'Server error',
      e.response?.statusCode,
      e.response?.data,
    );
  }
}

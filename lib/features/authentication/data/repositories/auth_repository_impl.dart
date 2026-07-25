import 'package:dio/dio.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../models/user_model.dart';
import '../../../../core/utils/app_failure.dart';
import '../../../../core/services/api_client.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;
  final ApiClient _apiClient;

  AuthRepositoryImpl({required this.localDataSource})
      : _apiClient = ApiClient();

  @override
  Future<(UserEntity?, AppFailure?)> login({
    required String identifier,
    required String password,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/login',
        data: {'identifier': identifier, 'password': password},
      );

      final data = response.data as Map<String, dynamic>;
      final userJson = data['user'] as Map<String, dynamic>;
      final user = UserModel.fromJson(userJson);
      final accessToken = data['access_token'] as String;
      final refreshToken = data['refresh_token'] as String;

      await localDataSource.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
      await localDataSource.cacheUser(user);

      return (user, null);
    } on DioException catch (e) {
      final failure = _apiClient.mapDioExceptionToFailure(e);
      return (null, failure);
    } catch (e) {
      return (null, ServerFailure(e.toString(), null, null));
    }
  }

  @override
  Future<(UserEntity?, AppFailure?)> autoLogin() async {
    // Check if a token is stored locally
    final token = await localDataSource.getAccessToken();
    if (token == null || token.isEmpty) {
      return (null, const AuthFailure('No active session'));
    }

    // Try to fetch fresh user data from API using stored token
    try {
      final response = await _apiClient.dio.get('/users/me');
      final userJson = response.data as Map<String, dynamic>;
      final user = UserModel.fromJson(userJson);
      await localDataSource.cacheUser(user);
      return (user, null);
    } on DioException catch (e) {
      // If 401, token expired — try token refresh
      if (e.response?.statusCode == 401) {
        return await _tryRefreshToken();
      }
      // If no internet, return cached user
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        final cachedUser = localDataSource.getCachedUser();
        if (cachedUser != null) return (cachedUser, null);
      }
      return (null, _apiClient.mapDioExceptionToFailure(e));
    }
  }

  Future<(UserEntity?, AppFailure?)> _tryRefreshToken() async {
    final refreshToken = await localDataSource.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      await localDataSource.clearTokens();
      return (null, const AuthFailure('Session expired. Please log in again.'));
    }

    try {
      final response = await _apiClient.dio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );
      final data = response.data as Map<String, dynamic>;
      final newAccessToken = data['access_token'] as String;
      final newRefreshToken = data['refresh_token'] as String;
      final userJson = data['user'] as Map<String, dynamic>;
      final user = UserModel.fromJson(userJson);

      await localDataSource.saveTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
      );
      await localDataSource.cacheUser(user);
      return (user, null);
    } on DioException catch (e) {
      await localDataSource.clearTokens();
      await localDataSource.clearCachedUser();
      return (null, _apiClient.mapDioExceptionToFailure(e));
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _apiClient.dio.post('/auth/logout');
    } catch (_) {
      // Ignore errors on logout — always clear local session
    } finally {
      await localDataSource.clearTokens();
      await localDataSource.clearCachedUser();
    }
  }

  @override
  Future<bool> resetPassword({
    required String identifier,
    required String otp,
    required String newPassword,
  }) async {
    try {
      await _apiClient.dio.post(
        '/auth/reset-password',
        data: {
          'email': identifier,
          'otp': otp,
          'new_password': newPassword,
        },
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<UserEntity?> getCachedUser() async {
    return localDataSource.getCachedUser();
  }
}

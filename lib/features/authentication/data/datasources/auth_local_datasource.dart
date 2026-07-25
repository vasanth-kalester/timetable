import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/services/hive_cache_service.dart';
import '../models/user_model.dart';

class AuthLocalDataSource {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  static const String accessTokenKey = 'auth_access_token';
  static const String refreshTokenKey = 'auth_refresh_token';
  static const String cachedUserKey = 'auth_cached_user';
  static const String biometricEnabledKey = 'biometric_enabled';

  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    await HiveCacheService.cacheData(HiveCacheService.userAuthBox, accessTokenKey, accessToken);
    await HiveCacheService.cacheData(HiveCacheService.userAuthBox, refreshTokenKey, refreshToken);
  }

  Future<String?> getAccessToken() async {
    return HiveCacheService.getCachedData(HiveCacheService.userAuthBox, accessTokenKey) as String?;
  }

  Future<String?> getRefreshToken() async {
    return HiveCacheService.getCachedData(HiveCacheService.userAuthBox, refreshTokenKey) as String?;
  }

  Future<void> clearTokens() async {
    await HiveCacheService.cacheData(HiveCacheService.userAuthBox, accessTokenKey, null);
    await HiveCacheService.cacheData(HiveCacheService.userAuthBox, refreshTokenKey, null);
  }

  Future<void> cacheUser(UserModel user) async {
    final userJson = jsonEncode(user.toJson());
    await HiveCacheService.cacheData(HiveCacheService.userAuthBox, cachedUserKey, userJson);
  }

  UserModel? getCachedUser() {
    final userJson = HiveCacheService.getCachedData(HiveCacheService.userAuthBox, cachedUserKey) as String?;
    if (userJson == null) return null;
    return UserModel.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
  }

  Future<void> clearCachedUser() async {
    await HiveCacheService.cacheData(HiveCacheService.userAuthBox, cachedUserKey, null);
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    await _secureStorage.write(key: biometricEnabledKey, value: enabled ? 'true' : 'false');
  }

  Future<bool> isBiometricEnabled() async {
    final val = await _secureStorage.read(key: biometricEnabledKey);
    return val == 'true';
  }
}

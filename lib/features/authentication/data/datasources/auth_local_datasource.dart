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
    await _secureStorage.write(key: accessTokenKey, value: accessToken);
    await _secureStorage.write(key: refreshTokenKey, value: refreshToken);
  }

  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: refreshTokenKey);
  }

  Future<void> clearTokens() async {
    await _secureStorage.delete(key: accessTokenKey);
    await _secureStorage.delete(key: refreshTokenKey);
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

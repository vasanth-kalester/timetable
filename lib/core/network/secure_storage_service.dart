class SecureStorageService {
  // In a real Flutter app, this would wrap flutter_secure_storage
  // For the domain logic, we mock it using an in-memory map.
  final Map<String, String> _storage = {};

  Future<void> write({required String key, required String value}) async {
    _storage[key] = value;
  }

  Future<String?> read({required String key}) async {
    return _storage[key];
  }

  Future<void> delete({required String key}) async {
    _storage.remove(key);
  }

  Future<void> clearAll() async {
    _storage.clear();
  }

  // Common getters/setters
  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    await write(key: 'access_token', value: accessToken);
    await write(key: 'refresh_token', value: refreshToken);
  }

  Future<String?> getAccessToken() => read(key: 'access_token');
  Future<String?> getRefreshToken() => read(key: 'refresh_token');
}

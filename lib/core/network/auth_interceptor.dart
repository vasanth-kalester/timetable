import 'secure_storage_service.dart';

class MockResponse {
  final int statusCode;
  final String body;

  MockResponse(this.statusCode, this.body);
}

class MockRequest {
  final String url;
  final Map<String, String> headers = {};
  
  MockRequest(this.url);
}

class AuthInterceptor {
  final SecureStorageService secureStorage;
  
  // A mock callback to simulate refreshing the token from the server
  final Future<bool> Function(String refreshToken) onRefreshToken;

  AuthInterceptor({
    required this.secureStorage,
    required this.onRefreshToken,
  });

  /// Intercept request to inject token
  Future<MockRequest> onRequest(MockRequest request) async {
    final token = await secureStorage.getAccessToken();
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    return request;
  }

  /// Intercept response to catch 401 and refresh
  Future<MockResponse> onError(MockRequest originalRequest, MockResponse errorResponse) async {
    if (errorResponse.statusCode == 401) {
      // 1. Try to get refresh token
      final refreshToken = await secureStorage.getRefreshToken();
      if (refreshToken != null) {
        
        // 2. Attempt refresh
        bool refreshSuccess = await onRefreshToken(refreshToken);
        
        if (refreshSuccess) {
          // 3. Retry original request with new token
          final newAccessToken = await secureStorage.getAccessToken();
          originalRequest.headers['Authorization'] = 'Bearer $newAccessToken';
          
          // Simulated retry success
          return MockResponse(200, '{"status": "retried_success"}');
        }
      }
    }
    // If not 401, or refresh failed, pass the error down
    return errorResponse;
  }
}

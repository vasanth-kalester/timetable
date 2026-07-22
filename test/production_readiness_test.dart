import 'package:flutter_test/flutter_test.dart';
import 'package:eduflow/core/storage/sync_action.dart';
import 'package:eduflow/core/storage/offline_queue_service.dart';
import 'package:eduflow/core/network/secure_storage_service.dart';
import 'package:eduflow/core/network/auth_interceptor.dart';

void main() {
  group('Production Readiness: Offline Queue', () {
    test('Enqueues actions and sorts them chronologically', () async {
      final queueService = OfflineQueueService();
      
      final action1 = SyncAction(
        endpoint: '/attendance',
        payload: {'status': 'present'},
        actionType: ActionType.post,
        timestamp: DateTime(2026, 7, 22, 10, 0, 0),
      );

      final action2 = SyncAction(
        endpoint: '/leave',
        payload: {'reason': 'sick'},
        actionType: ActionType.post,
        timestamp: DateTime(2026, 7, 22, 9, 0, 0), // Older timestamp!
      );

      queueService.enqueue(action1);
      queueService.enqueue(action2);

      final pending = queueService.getPendingActions();
      
      expect(pending.length, 2);
      expect(pending.first.endpoint, '/leave'); // Should be first because it's older
      
      queueService.incrementRetry(action2.id);
      expect(queueService.getPendingActions().first.retryCount, 1);
    });
  });

  group('Production Readiness: Auth Interceptor & Secure Storage', () {
    test('Injects access token into headers', () async {
      final secureStorage = SecureStorageService();
      await secureStorage.saveTokens(accessToken: 'valid_token_123', refreshToken: 'refresh_123');

      final interceptor = AuthInterceptor(
        secureStorage: secureStorage,
        onRefreshToken: (token) async => false,
      );

      final request = MockRequest('https://api.eduflow.com/user');
      final interceptedReq = await interceptor.onRequest(request);

      expect(interceptedReq.headers['Authorization'], 'Bearer valid_token_123');
    });

    test('Intercepts 401, refreshes token, and replays request', () async {
      final secureStorage = SecureStorageService();
      await secureStorage.saveTokens(accessToken: 'expired_token', refreshToken: 'valid_refresh');

      bool refreshCalled = false;

      final interceptor = AuthInterceptor(
        secureStorage: secureStorage,
        onRefreshToken: (token) async {
          if (token == 'valid_refresh') {
            refreshCalled = true;
            await secureStorage.saveTokens(accessToken: 'new_fresh_token', refreshToken: 'new_refresh');
            return true; // Success
          }
          return false; // Fail
        },
      );

      final originalRequest = MockRequest('https://api.eduflow.com/secure-data');
      final errorResponse = MockResponse(401, 'Unauthorized');

      // The interceptor should catch 401, call refresh, update token, and return a 200 MockResponse
      final finalResponse = await interceptor.onError(originalRequest, errorResponse);

      expect(refreshCalled, true);
      expect(finalResponse.statusCode, 200); // Successfully retried
      expect(originalRequest.headers['Authorization'], 'Bearer new_fresh_token'); // Replayed with new token
    });

    test('Passes error down if 401 refresh fails', () async {
      final secureStorage = SecureStorageService();
      await secureStorage.saveTokens(accessToken: 'expired_token', refreshToken: 'invalid_refresh');

      final interceptor = AuthInterceptor(
        secureStorage: secureStorage,
        onRefreshToken: (token) async {
          return false; // Refresh API failed
        },
      );

      final originalRequest = MockRequest('https://api.eduflow.com/secure-data');
      final errorResponse = MockResponse(401, 'Unauthorized');

      final finalResponse = await interceptor.onError(originalRequest, errorResponse);

      expect(finalResponse.statusCode, 401); // Still unauthorized
    });
  });
}

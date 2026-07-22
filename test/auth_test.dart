import 'package:flutter_test/flutter_test.dart';
import 'package:eduflow/features/authentication/domain/entities/user_entity.dart';
import 'package:eduflow/features/authentication/data/models/user_model.dart';
import 'package:eduflow/features/authentication/data/datasources/auth_local_datasource.dart';
import 'package:eduflow/features/authentication/data/repositories/auth_repository_impl.dart';

class MockLocalDataSource extends AuthLocalDataSource {
  String? _accessToken;
  String? _refreshToken;
  UserModel? _cachedUser;

  @override
  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
  }

  @override
  Future<String?> getAccessToken() async => _accessToken;

  @override
  Future<String?> getRefreshToken() async => _refreshToken;

  @override
  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    _cachedUser = user;
  }

  @override
  UserModel? getCachedUser() => _cachedUser;

  @override
  Future<void> clearCachedUser() async {
    _cachedUser = null;
  }
}

void main() {
  group('EduFlow Authentication & Identity Unit Tests', () {
    late MockLocalDataSource localDataSource;
    late AuthRepositoryImpl authRepository;

    setUp(() {
      localDataSource = MockLocalDataSource();
      authRepository = AuthRepositoryImpl(localDataSource: localDataSource);
    });

    test('Successful Student Login assigns Student role & permissions', () async {
      final (user, failure) = await authRepository.login(
        identifier: '21cs089@student.campus',
        password: 'pass1234',
      );

      expect(failure, isNull);
      expect(user, isNotNull);
      expect(user!.role, equals(UserRole.student));
      expect(user.hasPermission('view_timetable'), isTrue);
      expect(user.hasPermission('take_attendance'), isFalse);
    });

    test('Successful HOD Login assigns HOD role & department permissions', () async {
      final (user, failure) = await authRepository.login(
        identifier: 'hod@eduflow.campus',
        password: 'pass1234',
      );

      expect(failure, isNull);
      expect(user, isNotNull);
      expect(user!.role, equals(UserRole.hod));
      expect(user.hasPermission('take_attendance'), isTrue);
      expect(user.hasPermission('dept_management'), isTrue);
      expect(user.hasPermission('timetable_approval'), isTrue);
    });

    test('Short password returns ValidationFailure', () async {
      final (user, failure) = await authRepository.login(
        identifier: 'student@eduflow.campus',
        password: '123',
      );

      expect(user, isNull);
      expect(failure, isNotNull);
    });

    test('AutoLogin recovers session from cached token & user', () async {
      await authRepository.login(
        identifier: 'faculty@eduflow.campus',
        password: 'pass1234',
      );

      final (recoveredUser, failure) = await authRepository.autoLogin();

      expect(failure, isNull);
      expect(recoveredUser, isNotNull);
      expect(recoveredUser!.role, equals(UserRole.faculty));
    });

    test('Logout clears session tokens and cached user', () async {
      await authRepository.login(
        identifier: 'admin@eduflow.campus',
        password: 'pass1234',
      );

      await authRepository.logout();

      final (recoveredUser, failure) = await authRepository.autoLogin();
      expect(recoveredUser, isNull);
      expect(failure, isNotNull);
    });
  });
}

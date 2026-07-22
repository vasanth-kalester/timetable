import '../entities/user_entity.dart';
import '../../../../core/utils/app_failure.dart';

abstract class AuthRepository {
  Future<(UserEntity?, AppFailure?)> login({
    required String identifier,
    required String password,
  });

  Future<(UserEntity?, AppFailure?)> autoLogin();

  Future<void> logout();

  Future<bool> resetPassword({
    required String identifier,
    required String otp,
    required String newPassword,
  });

  Future<UserEntity?> getCachedUser();
}

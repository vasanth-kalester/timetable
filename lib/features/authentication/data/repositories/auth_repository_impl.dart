import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../models/user_model.dart';
import '../../../../core/utils/app_failure.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({required this.localDataSource});

  @override
  Future<(UserEntity?, AppFailure?)> login({
    required String identifier,
    required String password,
  }) async {
    // Basic verification check
    if (password.length < 4) {
      return (null, const ValidationFailure('Password must be at least 4 characters long.'));
    }

    // Determine mock role automatically from identifier format
    UserRole role = UserRole.student;
    String name = 'Alex Rivera';
    String dept = 'Computer Science & Eng';
    String? roll;
    String? empId;
    String? desig;

    final lowerId = identifier.trim().toLowerCase();
    if (lowerId.contains('admin')) {
      role = UserRole.admin;
      name = 'System Administrator';
      desig = 'Lead Campus Admin';
    } else if (lowerId.contains('principal') || lowerId.contains('head')) {
      role = UserRole.principal;
      name = 'Dr. Margaret Hamilton';
      desig = 'Principal & Dean';
    } else if (lowerId.contains('hod')) {
      role = UserRole.hod;
      name = 'Dr. Alan Turing';
      desig = 'Head of Department';
      empId = 'EMP-CS-101';
    } else if (lowerId.startsWith('emp') || lowerId.contains('faculty') || lowerId.contains('prof')) {
      role = UserRole.faculty;
      name = 'Prof. Grace Hopper';
      desig = 'Associate Professor';
      empId = 'EMP-CS-202';
    } else {
      role = UserRole.student;
      name = 'Alex Rivera';
      roll = '21CS089';
    }

    final user = UserModel(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      identifier: identifier,
      fullName: name,
      email: lowerId.contains('@') ? lowerId : '$lowerId@eduflow.campus',
      role: role,
      department: dept,
      designation: desig,
      rollNumber: roll,
      employeeId: empId,
      phone: '+1 (555) 019-2834',
      semester: role == UserRole.student ? 'Semester 5' : null,
    );

    // Save tokens and cache user locally
    await localDataSource.saveTokens(
      accessToken: 'jwt_access_mock_${user.id}',
      refreshToken: 'jwt_refresh_mock_${user.id}',
    );
    await localDataSource.cacheUser(user);

    return (user, null);
  }

  @override
  Future<(UserEntity?, AppFailure?)> autoLogin() async {
    final token = await localDataSource.getAccessToken();
    if (token == null) {
      return (null, const AuthFailure('No active session token found'));
    }

    final cachedUser = localDataSource.getCachedUser();
    if (cachedUser != null) {
      return (cachedUser, null);
    }

    return (null, const AuthFailure('Session expired or invalid'));
  }

  @override
  Future<void> logout() async {
    await localDataSource.clearTokens();
    await localDataSource.clearCachedUser();
  }

  @override
  Future<bool> resetPassword({
    required String identifier,
    required String otp,
    required String newPassword,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return otp == '123456' || otp.length == 6;
  }

  @override
  Future<UserEntity?> getCachedUser() async {
    return localDataSource.getCachedUser();
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/datasources/auth_local_datasource.dart';

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  return AuthLocalDataSource();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final localDs = ref.watch(authLocalDataSourceProvider);
  return AuthRepositoryImpl(localDataSource: localDs);
});

abstract class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class Authenticated extends AuthState {
  final UserEntity user;
  const Authenticated(this.user);
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthNotifier(repo);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthInitial());

  Future<void> checkSession() async {
    state = const AuthLoading();
    final (user, failure) = await _repository.autoLogin();
    if (user != null) {
      state = Authenticated(user);
    } else {
      state = const Unauthenticated();
    }
  }

  Future<bool> login(String identifier, String password) async {
    state = const AuthLoading();
    final (user, failure) = await _repository.login(identifier: identifier, password: password);
    if (user != null) {
      state = Authenticated(user);
      return true;
    } else {
      state = AuthError(failure?.message ?? 'Login failed');
      return false;
    }
  }

  Future<void> logout() async {
    state = const AuthLoading();
    await _repository.logout();
    state = const Unauthenticated();
  }

  UserEntity? get currentUser {
    if (state is Authenticated) {
      return (state as Authenticated).user;
    }
    return null;
  }
}

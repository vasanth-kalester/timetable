abstract class AppFailure {
  final String message;
  final int? statusCode;
  final dynamic details;

  const AppFailure(this.message, {this.statusCode, this.details});

  @override
  String toString() => 'AppFailure: $message ${statusCode != null ? '(Status: $statusCode)' : ''}';
}

class NetworkFailure extends AppFailure {
  const NetworkFailure([String message = 'Network connection failed. Please check your internet connection.', int? statusCode])
      : super(message, statusCode: statusCode);
}

class ServerFailure extends AppFailure {
  const ServerFailure([String message = 'An unexpected server error occurred.', int? statusCode, dynamic details])
      : super(message, statusCode: statusCode, details: details);
}

class AuthFailure extends AppFailure {
  const AuthFailure([String message = 'Authentication failed or session expired.', int? statusCode])
      : super(message, statusCode: statusCode);
}

class CacheFailure extends AppFailure {
  const CacheFailure([String message = 'Failed to load cached local data.', int? statusCode])
      : super(message, statusCode: statusCode);
}

class ValidationFailure extends AppFailure {
  const ValidationFailure(super.message, {super.statusCode, super.details});
}

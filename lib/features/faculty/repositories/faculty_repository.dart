import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import '../../../core/services/api_client.dart';
import '../../../core/utils/app_failure.dart';
import '../models/faculty.dart';

final facultyRepositoryProvider = Provider<FacultyRepository>((ref) {
  return FacultyRepository(apiClient: ref.read(apiClientProvider));
});

class FacultyRepository {
  final ApiClient _apiClient;

  FacultyRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<Either<AppFailure, List<Faculty>>> getFaculties({String? departmentId, String? status}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (departmentId != null) queryParams['departmentId'] = departmentId;
      if (status != null) queryParams['status'] = status;

      final response = await _apiClient.dio.get('/faculty/', queryParameters: queryParams);
      final List<dynamic> data = response.data;
      return right(data.map((json) => Faculty.fromJson(json)).toList());
    } on DioException catch (e) {
      return left(_apiClient.mapDioExceptionToFailure(e));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  Future<Either<AppFailure, Faculty>> getFaculty(String facultyId) async {
    try {
      final response = await _apiClient.dio.get('/faculty/$facultyId');
      return right(Faculty.fromJson(response.data));
    } on DioException catch (e) {
      return left(_apiClient.mapDioExceptionToFailure(e));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  Future<Either<AppFailure, Faculty>> createFaculty(Map<String, dynamic> facultyData) async {
    try {
      final response = await _apiClient.dio.post('/faculty/', data: facultyData);
      return right(Faculty.fromJson(response.data));
    } on DioException catch (e) {
      return left(_apiClient.mapDioExceptionToFailure(e));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  Future<Either<AppFailure, Faculty>> updateFaculty(String facultyId, Map<String, dynamic> facultyData) async {
    try {
      final response = await _apiClient.dio.put('/faculty/$facultyId', data: facultyData);
      return right(Faculty.fromJson(response.data));
    } on DioException catch (e) {
      return left(_apiClient.mapDioExceptionToFailure(e));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  Future<Either<AppFailure, SchedulingProfile>> getSchedulingProfile(String facultyId) async {
    try {
      final response = await _apiClient.dio.get('/faculty/$facultyId/scheduling-profile');
      return right(SchedulingProfile.fromJson(response.data));
    } on DioException catch (e) {
      return left(_apiClient.mapDioExceptionToFailure(e));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  Future<Either<AppFailure, SchedulingProfile>> createSchedulingProfile(String facultyId, Map<String, dynamic> profileData) async {
    try {
      final response = await _apiClient.dio.post('/faculty/$facultyId/scheduling-profile', data: profileData);
      return right(SchedulingProfile.fromJson(response.data));
    } on DioException catch (e) {
      return left(_apiClient.mapDioExceptionToFailure(e));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  Future<Either<AppFailure, SchedulingProfile>> updateSchedulingProfile(String facultyId, String profileId, Map<String, dynamic> profileData) async {
    try {
      final response = await _apiClient.dio.put('/faculty/$facultyId/scheduling-profile/$profileId', data: profileData);
      return right(SchedulingProfile.fromJson(response.data));
    } on DioException catch (e) {
      return left(_apiClient.mapDioExceptionToFailure(e));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  Future<Either<AppFailure, List<Availability>>> getAvailability(String facultyId) async {
    try {
      final response = await _apiClient.dio.get('/faculty/$facultyId/availability');
      final List<dynamic> data = response.data;
      return right(data.map((json) => Availability.fromJson(json)).toList());
    } on DioException catch (e) {
      return left(_apiClient.mapDioExceptionToFailure(e));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  Future<Either<AppFailure, Availability>> createAvailability(String facultyId, Map<String, dynamic> availabilityData) async {
    try {
      final response = await _apiClient.dio.post('/faculty/$facultyId/availability', data: availabilityData);
      return right(Availability.fromJson(response.data));
    } on DioException catch (e) {
      return left(_apiClient.mapDioExceptionToFailure(e));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  Future<Either<AppFailure, List<Leave>>> getLeaves(String facultyId) async {
    try {
      final response = await _apiClient.dio.get('/faculty/$facultyId/leaves');
      final List<dynamic> data = response.data;
      return right(data.map((json) => Leave.fromJson(json)).toList());
    } on DioException catch (e) {
      return left(_apiClient.mapDioExceptionToFailure(e));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  Future<Either<AppFailure, Leave>> createLeave(String facultyId, Map<String, dynamic> leaveData) async {
    try {
      final response = await _apiClient.dio.post('/faculty/$facultyId/leaves', data: leaveData);
      return right(Leave.fromJson(response.data));
    } on DioException catch (e) {
      return left(_apiClient.mapDioExceptionToFailure(e));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }
}

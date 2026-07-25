import 'package:dio/dio.dart';
import '../../../../core/services/api_client.dart';
import '../../../../core/utils/app_failure.dart';
import '../models/academic_models.dart';

class AcademicRepository {
  final ApiClient _apiClient;

  AcademicRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  // --- Academic Years ---
  Future<(List<AcademicYear>?, AppFailure?)> getAcademicYears() async {
    try {
      final response = await _apiClient.dio.get('/academic/years');
      final data = (response.data as List).map((e) => AcademicYear.fromJson(e)).toList();
      return (data, null);
    } on DioException catch (e) {
      return (null, _apiClient.mapDioExceptionToFailure(e));
    }
  }

  Future<(AcademicYear?, AppFailure?)> createAcademicYear(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.post('/academic/years', data: data);
      return (AcademicYear.fromJson(response.data), null);
    } on DioException catch (e) {
      return (null, _apiClient.mapDioExceptionToFailure(e));
    }
  }

  Future<(AcademicYear?, AppFailure?)> updateAcademicYear(String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.put('/academic/years/$id', data: data);
      return (AcademicYear.fromJson(response.data), null);
    } on DioException catch (e) {
      return (null, _apiClient.mapDioExceptionToFailure(e));
    }
  }

  // --- Departments ---
  Future<(List<Department>?, AppFailure?)> getDepartments() async {
    try {
      final response = await _apiClient.dio.get('/academic/departments');
      final data = (response.data as List).map((e) => Department.fromJson(e)).toList();
      return (data, null);
    } on DioException catch (e) {
      return (null, _apiClient.mapDioExceptionToFailure(e));
    }
  }

  Future<(Department?, AppFailure?)> createDepartment(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.post('/academic/departments', data: data);
      return (Department.fromJson(response.data), null);
    } on DioException catch (e) {
      return (null, _apiClient.mapDioExceptionToFailure(e));
    }
  }

  Future<(Department?, AppFailure?)> updateDepartment(String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.put('/academic/departments/$id', data: data);
      return (Department.fromJson(response.data), null);
    } on DioException catch (e) {
      return (null, _apiClient.mapDioExceptionToFailure(e));
    }
  }

  // --- Programs ---
  Future<(List<Program>?, AppFailure?)> getPrograms({String? departmentId}) async {
    try {
      final query = departmentId != null ? {'departmentId': departmentId} : null;
      final response = await _apiClient.dio.get('/academic/programs', queryParameters: query);
      final data = (response.data as List).map((e) => Program.fromJson(e)).toList();
      return (data, null);
    } on DioException catch (e) {
      return (null, _apiClient.mapDioExceptionToFailure(e));
    }
  }

  Future<(Program?, AppFailure?)> createProgram(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.post('/academic/programs', data: data);
      return (Program.fromJson(response.data), null);
    } on DioException catch (e) {
      return (null, _apiClient.mapDioExceptionToFailure(e));
    }
  }

  Future<(Program?, AppFailure?)> updateProgram(String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.put('/academic/programs/$id', data: data);
      return (Program.fromJson(response.data), null);
    } on DioException catch (e) {
      return (null, _apiClient.mapDioExceptionToFailure(e));
    }
  }

  // --- Semesters ---
  Future<(List<Semester>?, AppFailure?)> getSemesters({String? programId}) async {
    try {
      final query = programId != null ? {'programId': programId} : null;
      final response = await _apiClient.dio.get('/academic/semesters', queryParameters: query);
      final data = (response.data as List).map((e) => Semester.fromJson(e)).toList();
      return (data, null);
    } on DioException catch (e) {
      return (null, _apiClient.mapDioExceptionToFailure(e));
    }
  }

  Future<(Semester?, AppFailure?)> createSemester(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.post('/academic/semesters', data: data);
      return (Semester.fromJson(response.data), null);
    } on DioException catch (e) {
      return (null, _apiClient.mapDioExceptionToFailure(e));
    }
  }

  Future<(Semester?, AppFailure?)> updateSemester(String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.put('/academic/semesters/$id', data: data);
      return (Semester.fromJson(response.data), null);
    } on DioException catch (e) {
      return (null, _apiClient.mapDioExceptionToFailure(e));
    }
  }

  // --- Sections ---
  Future<(List<Section>?, AppFailure?)> getSections({String? semesterId}) async {
    try {
      final query = semesterId != null ? {'semesterId': semesterId} : null;
      final response = await _apiClient.dio.get('/academic/sections', queryParameters: query);
      final data = (response.data as List).map((e) => Section.fromJson(e)).toList();
      return (data, null);
    } on DioException catch (e) {
      return (null, _apiClient.mapDioExceptionToFailure(e));
    }
  }

  Future<(Section?, AppFailure?)> createSection(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.post('/academic/sections', data: data);
      return (Section.fromJson(response.data), null);
    } on DioException catch (e) {
      return (null, _apiClient.mapDioExceptionToFailure(e));
    }
  }

  Future<(Section?, AppFailure?)> updateSection(String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.put('/academic/sections/$id', data: data);
      return (Section.fromJson(response.data), null);
    } on DioException catch (e) {
      return (null, _apiClient.mapDioExceptionToFailure(e));
    }
  }
}

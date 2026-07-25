import 'package:dio/dio.dart';
import '../../../../core/services/api_client.dart';
import '../../../../core/utils/app_failure.dart';
import '../models/infrastructure_models.dart';
import '../models/period_template.dart';

class InfrastructureRepository {
  final ApiClient _apiClient;

  InfrastructureRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  // --- Buildings ---
  Future<(List<Building>?, AppFailure?)> getBuildings() async {
    try {
      final response = await _apiClient.dio.get('/infrastructure/buildings');
      final data = (response.data as List).map((e) => Building.fromJson(e)).toList();
      return (data, null);
    } on DioException catch (e) {
      return (null, _apiClient.mapDioExceptionToFailure(e));
    }
  }

  Future<(Building?, AppFailure?)> createBuilding(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.post('/infrastructure/buildings', data: data);
      return (Building.fromJson(response.data), null);
    } on DioException catch (e) {
      return (null, _apiClient.mapDioExceptionToFailure(e));
    }
  }

  Future<(Building?, AppFailure?)> updateBuilding(String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.put('/infrastructure/buildings/$id', data: data);
      return (Building.fromJson(response.data), null);
    } on DioException catch (e) {
      return (null, _apiClient.mapDioExceptionToFailure(e));
    }
  }

  // --- Classrooms ---
  Future<(List<Classroom>?, AppFailure?)> getClassrooms({String? buildingId}) async {
    try {
      final query = buildingId != null ? {'buildingId': buildingId} : null;
      final response = await _apiClient.dio.get('/infrastructure/classrooms', queryParameters: query);
      final data = (response.data as List).map((e) => Classroom.fromJson(e)).toList();
      return (data, null);
    } on DioException catch (e) {
      return (null, _apiClient.mapDioExceptionToFailure(e));
    }
  }

  Future<(Classroom?, AppFailure?)> createClassroom(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.post('/infrastructure/classrooms', data: data);
      return (Classroom.fromJson(response.data), null);
    } on DioException catch (e) {
      return (null, _apiClient.mapDioExceptionToFailure(e));
    }
  }

  Future<(Classroom?, AppFailure?)> updateClassroom(String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.put('/infrastructure/classrooms/$id', data: data);
      return (Classroom.fromJson(response.data), null);
    } on DioException catch (e) {
      return (null, _apiClient.mapDioExceptionToFailure(e));
    }
  }

  // --- Laboratories ---
  Future<(List<Laboratory>?, AppFailure?)> getLaboratories({String? departmentId}) async {
    try {
      final query = departmentId != null ? {'departmentId': departmentId} : null;
      final response = await _apiClient.dio.get('/infrastructure/laboratories', queryParameters: query);
      final data = (response.data as List).map((e) => Laboratory.fromJson(e)).toList();
      return (data, null);
    } on DioException catch (e) {
      return (null, _apiClient.mapDioExceptionToFailure(e));
    }
  }

  Future<(Laboratory?, AppFailure?)> createLaboratory(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.post('/infrastructure/laboratories', data: data);
      return (Laboratory.fromJson(response.data), null);
    } on DioException catch (e) {
      return (null, _apiClient.mapDioExceptionToFailure(e));
    }
  }

  Future<(Laboratory?, AppFailure?)> updateLaboratory(String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.put('/infrastructure/laboratories/$id', data: data);
      return (Laboratory.fromJson(response.data), null);
    } on DioException catch (e) {
      return (null, _apiClient.mapDioExceptionToFailure(e));
    }
  }

  // --- Working Days ---
  Future<(List<WorkingDay>?, AppFailure?)> getWorkingDays() async {
    try {
      final response = await _apiClient.dio.get('/infrastructure/working-days');
      final data = (response.data as List).map((e) => WorkingDay.fromJson(e)).toList();
      return (data, null);
    } on DioException catch (e) {
      return (null, _apiClient.mapDioExceptionToFailure(e));
    }
  }

  Future<(WorkingDay?, AppFailure?)> updateWorkingDay(String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.put('/infrastructure/working-days/$id', data: data);
      return (WorkingDay.fromJson(response.data), null);
    } on DioException catch (e) {
      return (null, _apiClient.mapDioExceptionToFailure(e));
    }
  }

  // --- Period Configuration ---
  Future<(List<PeriodConfiguration>?, AppFailure?)> getPeriods() async {
    try {
      final response = await _apiClient.dio.get('/infrastructure/periods');
      final data = (response.data as List).map((e) => PeriodConfiguration.fromJson(e)).toList();
      return (data, null);
    } on DioException catch (e) {
      return (null, _apiClient.mapDioExceptionToFailure(e));
    }
  }

  Future<(PeriodConfiguration?, AppFailure?)> createPeriod(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.post('/infrastructure/periods', data: data);
      return (PeriodConfiguration.fromJson(response.data), null);
    } on DioException catch (e) {
      return (null, _apiClient.mapDioExceptionToFailure(e));
    }
  }

  Future<(PeriodConfiguration?, AppFailure?)> updatePeriod(String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.put('/infrastructure/periods/$id', data: data);
      return (PeriodConfiguration.fromJson(response.data), null);
    } on DioException catch (e) {
      return (null, _apiClient.mapDioExceptionToFailure(e));
    }
  }

  // --- Period Templates ---
  Future<(List<PeriodTemplate>?, AppFailure?)> getPeriodTemplates() async {
    try {
      final response = await _apiClient.dio.get('/infrastructure/period-templates');
      final data = (response.data as List).map((e) => PeriodTemplate.fromJson(e)).toList();
      return (data, null);
    } on DioException catch (e) {
      return (null, _apiClient.mapDioExceptionToFailure(e));
    }
  }

  Future<(PeriodTemplate?, AppFailure?)> createPeriodTemplate(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.post('/infrastructure/period-templates', data: data);
      return (PeriodTemplate.fromJson(response.data), null);
    } on DioException catch (e) {
      return (null, _apiClient.mapDioExceptionToFailure(e));
    }
  }

  Future<(PeriodTemplate?, AppFailure?)> updatePeriodTemplate(String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.put('/infrastructure/period-templates/$id', data: data);
      return (PeriodTemplate.fromJson(response.data), null);
    } on DioException catch (e) {
      return (null, _apiClient.mapDioExceptionToFailure(e));
    }
  }

  // --- Institution Policies ---
  Future<(List<InstitutionPolicy>?, AppFailure?)> getPolicies() async {
    try {
      final response = await _apiClient.dio.get('/infrastructure/policies');
      final data = (response.data as List).map((e) => InstitutionPolicy.fromJson(e)).toList();
      return (data, null);
    } on DioException catch (e) {
      return (null, _apiClient.mapDioExceptionToFailure(e));
    }
  }

  Future<(InstitutionPolicy?, AppFailure?)> updatePolicy(String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.put('/infrastructure/policies/$id', data: data);
      return (InstitutionPolicy.fromJson(response.data), null);
    } on DioException catch (e) {
      return (null, _apiClient.mapDioExceptionToFailure(e));
    }
  }
}

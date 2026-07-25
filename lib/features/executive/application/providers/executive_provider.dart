import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';

final executiveProvider = Provider<ExecutiveService>((ref) {
  return ExecutiveService(ref.read(dioClientProvider));
});

class ExecutiveService {
  final Dio _dio;

  ExecutiveService(this._dio);

  Future<Map<String, dynamic>> getInstitutionalKPIs() async {
    try {
      final response = await _dio.get('/executive/kpis');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getDepartmentBenchmarks() async {
    try {
      final response = await _dio.get('/executive/benchmarks');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getTimetableQuality(String timetableId) async {
    try {
      final response = await _dio.get('/executive/quality/$timetableId');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getHistoricalTrends(String metric) async {
    try {
      final response = await _dio.get('/executive/historical/trends', queryParameters: {
        'metric': metric,
      });
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getResourceForecast(String targetYear, double growthRate) async {
    try {
      final response = await _dio.get('/executive/forecast', queryParameters: {
        'target_year': targetYear,
        'growth_rate': growthRate,
      });
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> replaySemester(String academicYearId, String semester) async {
    try {
      final response = await _dio.get('/executive/replay', queryParameters: {
        'academic_year_id': academicYearId,
        'semester': semester,
      });
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getAccreditationMetrics(String bodyName) async {
    try {
      final response = await _dio.get('/executive/accreditation/$bodyName');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> generateCustomReport(Map<String, dynamic> filters, {String format = 'pdf'}) async {
    try {
      final response = await _dio.post('/executive/reports/custom', data: filters, queryParameters: {
        'format': format,
      });
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getActiveAlerts() async {
    try {
      final response = await _dio.get('/executive/alerts');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}

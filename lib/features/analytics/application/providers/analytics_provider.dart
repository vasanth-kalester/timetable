import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';

final analyticsProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService(ref.read(dioClientProvider));
});

class AnalyticsService {
  final Dio _dio;

  AnalyticsService(this._dio);

  Future<List<dynamic>> getRoomUtilization({String? timetableId}) async {
    try {
      final response = await _dio.get('/analytics/rooms/utilization', queryParameters: {
        if (timetableId != null) 'timetableId': timetableId,
      });
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getFacultyUtilization({String? timetableId}) async {
    try {
      final response = await _dio.get('/analytics/faculty/utilization', queryParameters: {
        if (timetableId != null) 'timetableId': timetableId,
      });
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getQualityScore({String? timetableId}) async {
    try {
      final response = await _dio.get('/analytics/quality-score', queryParameters: {
        if (timetableId != null) 'timetableId': timetableId,
      });
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getInfrastructureConflicts({String? timetableId}) async {
    try {
      final response = await _dio.get('/analytics/infrastructure-conflicts', queryParameters: {
        if (timetableId != null) 'timetableId': timetableId,
      });
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> simulateCapacity(int newSections, int studentsPerSection, {int newLabs = 0}) async {
    try {
      final response = await _dio.get('/planning/simulate-capacity', queryParameters: {
        'newSections': newSections,
        'studentsPerSection': studentsPerSection,
        'newLabs': newLabs,
      });
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> forecastDemand({double growthRate = 0.1}) async {
    try {
      final response = await _dio.get('/planning/forecast-demand', queryParameters: {
        'growthRate': growthRate,
      });
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getCampusMap(int dayOfWeek, int period) async {
    try {
      final response = await _dio.get('/digital-twin/campus-map', queryParameters: {
        'dayOfWeek': dayOfWeek,
        'period': period,
      });
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> generateUtilizationReport() async {
    try {
      final response = await _dio.get('/digital-twin/reports/utilization');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}

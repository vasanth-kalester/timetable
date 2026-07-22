import '../models/infrastructure_models.dart';

class UtilizationService {
  /// Calculates a Classroom Health Score (0-100) based on equipment condition
  /// and maintenance frequency.
  static double calculateHealthScore({
    required Room room,
    required List<Equipment> roomEquipment,
    required List<MaintenanceRecord> recentMaintenanceRecords,
  }) {
    double baseScore = 100.0;

    // 1. Deduct for poor equipment conditions
    double equipmentDeduction = 0;
    for (var eq in roomEquipment) {
      if (eq.condition == EquipmentCondition.broken) {
        equipmentDeduction += 15.0;
      } else if (eq.condition == EquipmentCondition.poor) {
        equipmentDeduction += 10.0;
      } else if (eq.condition == EquipmentCondition.fair) {
        equipmentDeduction += 5.0;
      }
    }
    baseScore -= equipmentDeduction;

    // 2. Deduct for high maintenance frequency in the recent period
    double maintenanceDeduction = recentMaintenanceRecords.length * 5.0;
    baseScore -= maintenanceDeduction;

    // Clamp score between 0 and 100
    if (baseScore < 0) return 0.0;
    if (baseScore > 100) return 100.0;

    return baseScore;
  }

  /// Generates a Utilization Heatmap matrix for a specific room over a given week.
  /// Returns a Map of Day (e.g., 1 for Monday) to a Map of Hour (8 to 18) to Occupancy (bool).
  static Map<int, Map<int, bool>> generateHeatmap({
    required Room room,
    required DateTime weekStartDate,
    required List<ResourceBooking> bookings,
    // Typically we would also include Timetable Classes here from the scheduling engine.
  }) {
    Map<int, Map<int, bool>> heatmap = {};

    // Initialize an empty heatmap for Monday(1) to Friday(5), 8 AM to 6 PM (18)
    for (int day = 1; day <= 5; day++) {
      heatmap[day] = {};
      for (int hour = 8; hour <= 17; hour++) {
        heatmap[day]![hour] = false;
      }
    }

    // Populate heatmap with bookings
    for (var booking in bookings) {
      if (booking.roomId != room.id || booking.status == BookingStatus.rejected || booking.status == BookingStatus.cancelled) {
        continue;
      }

      // Check if booking falls within this week (simplified logic for demo)
      // In a real app, you'd match the exact week dates.
      int dayOfWeek = booking.startTime.weekday; // 1=Mon, ..., 7=Sun
      
      if (dayOfWeek >= 1 && dayOfWeek <= 5) { // Only weekday bookings for this demo
        int startHour = booking.startTime.hour;
        int endHour = booking.endTime.hour;

        // If booking ends on the hour (e.g. 10:00), it shouldn't occupy the 10th hour slot
        if (booking.endTime.minute == 0 && endHour > startHour) {
          endHour -= 1;
        }

        for (int h = startHour; h <= endHour; h++) {
          if (h >= 8 && h <= 17) {
            heatmap[dayOfWeek]![h] = true;
          }
        }
      }
    }

    return heatmap;
  }
}

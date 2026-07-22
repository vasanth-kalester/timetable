import '../models/infrastructure_models.dart';

class BookingService {
  /// Checks if a room is available for a given time slot by verifying
  /// against existing bookings and maintenance records.
  static bool isRoomAvailable({
    required Room room,
    required DateTime start,
    required DateTime end,
    required List<ResourceBooking> existingBookings,
    required List<MaintenanceRecord> maintenanceRecords,
  }) {
    // Check against existing bookings
    for (var booking in existingBookings) {
      if (booking.roomId == room.id && booking.status != BookingStatus.rejected && booking.status != BookingStatus.cancelled) {
        if (booking.overlapsWith(start, end)) {
          return false; // Conflict found
        }
      }
    }

    // Check against maintenance records
    for (var record in maintenanceRecords) {
      if (record.entityType == 'ROOM' && record.entityId == room.id && record.status != MaintenanceStatus.cancelled) {
        if (start.isBefore(record.endDate) && end.isAfter(record.startDate)) {
          return false; // Room is under maintenance
        }
      }
    }

    return true; // Room is available
  }

  /// Provides smart suggestions for rooms based on requirements.
  /// Filters by capacity, required features, and availability.
  /// Sorts by best fit (closest capacity match).
  static List<Room> suggestRooms({
    required List<Room> allRooms,
    required int requiredCapacity,
    required List<String> requiredFeatureIds,
    required DateTime start,
    required DateTime end,
    required List<ResourceBooking> existingBookings,
    required List<MaintenanceRecord> maintenanceRecords,
  }) {
    List<Room> validRooms = [];

    for (var room in allRooms) {
      // 1. Check Capacity
      if (room.capacity < requiredCapacity) continue;

      // 2. Check Features
      bool hasAllFeatures = true;
      List<String> roomFeatureIds = room.features.map((e) => e.id).toList();
      for (var reqFeatureId in requiredFeatureIds) {
        if (!roomFeatureIds.contains(reqFeatureId)) {
          hasAllFeatures = false;
          break;
        }
      }
      if (!hasAllFeatures) continue;

      // 3. Check Availability
      if (!isRoomAvailable(
        room: room,
        start: start,
        end: end,
        existingBookings: existingBookings,
        maintenanceRecords: maintenanceRecords,
      )) {
        continue;
      }

      validRooms.add(room);
    }

    // Sort by closest capacity to avoid wasting large rooms for small groups
    validRooms.sort((a, b) => (a.capacity - requiredCapacity).compareTo(b.capacity - requiredCapacity));

    return validRooms;
  }
}

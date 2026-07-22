import 'package:flutter_test/flutter_test.dart';
import 'package:eduflow/features/infrastructure/domain/models/infrastructure_models.dart';
import 'package:eduflow/features/infrastructure/domain/services/booking_service.dart';
import 'package:eduflow/features/infrastructure/domain/services/utilization_service.dart';

void main() {
  group('Infrastructure Domain: BookingService Tests', () {
    final projectorFeature = const RoomFeature(id: 'f1', name: 'Projector', iconCode: 'videocam');
    final acFeature = const RoomFeature(id: 'f2', name: 'Air Conditioning', iconCode: 'ac_unit');

    final room1 = Room(
      id: 'r1',
      floorId: 'fl1',
      roomNumber: 'A-301',
      type: RoomType.classroom,
      capacity: 60,
      currentStatus: ResourceStatus.available,
      features: [projectorFeature, acFeature],
    );

    final room2 = Room(
      id: 'r2',
      floorId: 'fl1',
      roomNumber: 'A-302',
      type: RoomType.seminarHall,
      capacity: 120,
      currentStatus: ResourceStatus.available,
      features: [projectorFeature], // No AC
    );

    final room3 = Room(
      id: 'r3',
      floorId: 'fl2',
      roomNumber: 'B-101',
      type: RoomType.classroom,
      capacity: 40,
      currentStatus: ResourceStatus.available,
      features: [projectorFeature, acFeature],
    );

    final allRooms = [room1, room2, room3];

    test('isRoomAvailable detects overlapping bookings correctly', () {
      final existingBooking = ResourceBooking(
        id: 'b1',
        roomId: 'r1',
        facultyId: 'fac1',
        date: DateTime(2026, 8, 10),
        startTime: DateTime(2026, 8, 10, 10, 0), // 10:00 AM
        endTime: DateTime(2026, 8, 10, 12, 0),   // 12:00 PM
        status: BookingStatus.approved,
        purpose: 'Guest Lecture',
      );

      // Conflict: starts before end, ends after start
      bool isAvailConflict = BookingService.isRoomAvailable(
        room: room1,
        start: DateTime(2026, 8, 10, 11, 0),
        end: DateTime(2026, 8, 10, 13, 0),
        existingBookings: [existingBooking],
        maintenanceRecords: [],
      );
      expect(isAvailConflict, false);

      // No Conflict: starts after existing ends
      bool isAvailNoConflict = BookingService.isRoomAvailable(
        room: room1,
        start: DateTime(2026, 8, 10, 12, 0),
        end: DateTime(2026, 8, 10, 14, 0),
        existingBookings: [existingBooking],
        maintenanceRecords: [],
      );
      expect(isAvailNoConflict, true);
    });

    test('isRoomAvailable detects maintenance conflicts correctly', () {
      final maintenance = MaintenanceRecord(
        id: 'm1',
        entityId: 'r1',
        entityType: 'ROOM',
        startDate: DateTime(2026, 8, 10, 9, 0),
        endDate: DateTime(2026, 8, 10, 18, 0),
        status: MaintenanceStatus.scheduled,
        description: 'AC Repair',
      );

      bool isAvailConflict = BookingService.isRoomAvailable(
        room: room1,
        start: DateTime(2026, 8, 10, 14, 0),
        end: DateTime(2026, 8, 10, 16, 0),
        existingBookings: [],
        maintenanceRecords: [maintenance],
      );
      expect(isAvailConflict, false);
    });

    test('suggestRooms filters by capacity, features, and sorts by closest capacity', () {
      final suggestions = BookingService.suggestRooms(
        allRooms: allRooms,
        requiredCapacity: 50,
        requiredFeatureIds: ['f1', 'f2'], // Needs Projector and AC
        start: DateTime(2026, 8, 10, 10, 0),
        end: DateTime(2026, 8, 10, 12, 0),
        existingBookings: [],
        maintenanceRecords: [],
      );

      // Room 2 has capacity 120, but lacks AC (f2) -> rejected
      // Room 3 has capacity 40, which is < 50 -> rejected
      // Room 1 has capacity 60, has AC and Projector -> accepted
      expect(suggestions.length, 1);
      expect(suggestions.first.id, 'r1');
    });

    test('suggestRooms sorts by closest capacity match', () {
      // Create a 4th room with capacity 55 (closer to 50 than 60)
      final room4 = Room(
        id: 'r4',
        floorId: 'fl1',
        roomNumber: 'A-303',
        type: RoomType.classroom,
        capacity: 55,
        currentStatus: ResourceStatus.available,
        features: [projectorFeature, acFeature],
      );

      final suggestions = BookingService.suggestRooms(
        allRooms: [...allRooms, room4],
        requiredCapacity: 50,
        requiredFeatureIds: [],
        start: DateTime(2026, 8, 10, 10, 0),
        end: DateTime(2026, 8, 10, 12, 0),
        existingBookings: [],
        maintenanceRecords: [],
      );

      // r4 (55), r1 (60), r2 (120) are valid
      // r3 (40) is invalid
      expect(suggestions.length, 3);
      expect(suggestions[0].id, 'r4'); // Closest capacity
      expect(suggestions[1].id, 'r1');
      expect(suggestions[2].id, 'r2');
    });
  });

  group('Infrastructure Domain: UtilizationService Tests', () {
    test('calculateHealthScore deducts points correctly for poor equipment and maintenance', () {
      final room = const Room(
        id: 'r1', floorId: 'f1', roomNumber: '101', type: RoomType.classroom, capacity: 60, currentStatus: ResourceStatus.available
      );

      final eq1 = Equipment(id: 'e1', type: 'Projector', serialNumber: '123', purchaseDate: DateTime.now(), condition: EquipmentCondition.broken);
      final eq2 = Equipment(id: 'e2', type: 'AC', serialNumber: '124', purchaseDate: DateTime.now(), condition: EquipmentCondition.poor);

      final m1 = MaintenanceRecord(id: 'm1', entityId: 'r1', entityType: 'ROOM', startDate: DateTime.now(), endDate: DateTime.now(), status: MaintenanceStatus.completed, description: 'Fix door');
      final m2 = MaintenanceRecord(id: 'm2', entityId: 'r1', entityType: 'ROOM', startDate: DateTime.now(), endDate: DateTime.now(), status: MaintenanceStatus.completed, description: 'Fix light');

      // Base 100
      // eq1 (broken) = -15
      // eq2 (poor) = -10
      // m1, m2 = 2 * 5 = -10
      // Total = 100 - 15 - 10 - 10 = 65

      double score = UtilizationService.calculateHealthScore(
        room: room,
        roomEquipment: [eq1, eq2],
        recentMaintenanceRecords: [m1, m2],
      );

      expect(score, 65.0);
    });

    test('generateHeatmap calculates hour-by-hour occupancy correctly', () {
      final room = const Room(
        id: 'r1', floorId: 'f1', roomNumber: '101', type: RoomType.classroom, capacity: 60, currentStatus: ResourceStatus.available
      );

      // Assuming Monday is Aug 10, 2026 for this test
      final monday = DateTime(2026, 8, 10);
      
      final booking1 = ResourceBooking(
        id: 'b1', roomId: 'r1', facultyId: 'f1', date: monday,
        startTime: DateTime(2026, 8, 10, 9, 0),
        endTime: DateTime(2026, 8, 10, 11, 0),
        status: BookingStatus.approved, purpose: 'Class'
      ); // Occupies 9:00 - 11:00 on Monday (Day 1)

      final booking2 = ResourceBooking(
        id: 'b2', roomId: 'r1', facultyId: 'f1', date: monday.add(const Duration(days: 1)),
        startTime: DateTime(2026, 8, 11, 14, 0),
        endTime: DateTime(2026, 8, 11, 16, 0),
        status: BookingStatus.approved, purpose: 'Lab'
      ); // Occupies 14:00 - 16:00 on Tuesday (Day 2)

      final heatmap = UtilizationService.generateHeatmap(
        room: room,
        weekStartDate: monday,
        bookings: [booking1, booking2],
      );

      // Monday (1) checks
      expect(heatmap[1]![8], false);
      expect(heatmap[1]![9], true);
      expect(heatmap[1]![10], true);
      expect(heatmap[1]![11], false);

      // Tuesday (2) checks
      expect(heatmap[2]![13], false);
      expect(heatmap[2]![14], true);
      expect(heatmap[2]![15], true);
      expect(heatmap[2]![16], false);
      
      // Wednesday (3) checks
      expect(heatmap[3]![10], false);
    });
  });
}

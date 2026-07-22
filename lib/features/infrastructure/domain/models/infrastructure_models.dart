enum RoomType {
  classroom,
  laboratory,
  seminarHall,
  auditorium,
  conferenceRoom,
  facultyCabin,
  computerLab,
  library,
  examinationHall
}

enum ResourceStatus {
  available,
  occupied,
  reserved,
  maintenance,
  cleaning,
  closed
}

enum EquipmentCondition {
  excellent,
  good,
  fair,
  poor,
  broken
}

enum MaintenanceStatus {
  scheduled,
  inProgress,
  completed,
  cancelled
}

enum BookingStatus {
  pending,
  approved,
  rejected,
  cancelled
}

class Campus {
  final String id;
  final String name;
  final String code;
  final String address;
  final double latitude;
  final double longitude;
  final String contact;
  final String workingHours;

  const Campus({
    required this.id,
    required this.name,
    required this.code,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.contact,
    required this.workingHours,
  });
}

class Building {
  final String id;
  final String campusId;
  final String name;
  final String code;
  final int totalFloors;
  final ResourceStatus status;
  final List<String> departmentsLocated;

  const Building({
    required this.id,
    required this.campusId,
    required this.name,
    required this.code,
    required this.totalFloors,
    required this.status,
    required this.departmentsLocated,
  });
}

class Floor {
  final String id;
  final String buildingId;
  final int floorNumber;
  final String name;
  final bool hasEmergencyExit;

  const Floor({
    required this.id,
    required this.buildingId,
    required this.floorNumber,
    required this.name,
    required this.hasEmergencyExit,
  });
}

class RoomFeature {
  final String id;
  final String name;
  final String iconCode;

  const RoomFeature({
    required this.id,
    required this.name,
    required this.iconCode,
  });
}

class Room {
  final String id;
  final String floorId;
  final String roomNumber;
  final RoomType type;
  final int capacity;
  final String? departmentOwnerId;
  final ResourceStatus currentStatus;
  final List<RoomFeature> features;

  const Room({
    required this.id,
    required this.floorId,
    required this.roomNumber,
    required this.type,
    required this.capacity,
    this.departmentOwnerId,
    required this.currentStatus,
    this.features = const [],
  });
}

class LabDetails {
  final String id;
  final String roomId;
  final String labName;
  final List<String> installedSoftware;
  final int systemCount;
  final String? labAssistantName;

  const LabDetails({
    required this.id,
    required this.roomId,
    required this.labName,
    required this.installedSoftware,
    required this.systemCount,
    this.labAssistantName,
  });
}

class Equipment {
  final String id;
  final String type; // e.g., 'Projector', 'Microphone'
  final String serialNumber;
  final String? currentLocationRoomId;
  final DateTime purchaseDate;
  final EquipmentCondition condition;

  const Equipment({
    required this.id,
    required this.type,
    required this.serialNumber,
    this.currentLocationRoomId,
    required this.purchaseDate,
    required this.condition,
  });
}

class MaintenanceRecord {
  final String id;
  final String entityId; // Room ID or Equipment ID
  final String entityType; // 'ROOM' or 'EQUIPMENT'
  final DateTime startDate;
  final DateTime endDate;
  final MaintenanceStatus status;
  final String description;

  const MaintenanceRecord({
    required this.id,
    required this.entityId,
    required this.entityType,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.description,
  });
}

class ResourceBooking {
  final String id;
  final String roomId;
  final String facultyId;
  final DateTime date;
  final DateTime startTime; // Can just use DateTime with same date
  final DateTime endTime;
  final BookingStatus status;
  final String purpose;

  const ResourceBooking({
    required this.id,
    required this.roomId,
    required this.facultyId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.purpose,
  });

  bool overlapsWith(DateTime otherStart, DateTime otherEnd) {
    return startTime.isBefore(otherEnd) && endTime.isAfter(otherStart);
  }
}

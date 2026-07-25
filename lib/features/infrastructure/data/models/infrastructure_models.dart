class Building {
  final String id;
  final String name;
  final String code;
  final String type;

  Building({
    required this.id,
    required this.name,
    required this.code,
    required this.type,
  });

  factory Building.fromJson(Map<String, dynamic> json) {
    return Building(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'type': type,
    };
  }
}

class Classroom {
  final String id;
  final String roomNumber;
  final int capacity;
  final bool isSmart;
  final bool hasProjector;
  final bool hasAC;
  final String buildingId;
  final String status;

  Classroom({
    required this.id,
    required this.roomNumber,
    required this.capacity,
    required this.isSmart,
    required this.hasProjector,
    required this.hasAC,
    required this.buildingId,
    required this.status,
  });

  factory Classroom.fromJson(Map<String, dynamic> json) {
    return Classroom(
      id: json['id'],
      roomNumber: json['roomNumber'],
      capacity: json['capacity'],
      isSmart: json['isSmart'],
      hasProjector: json['hasProjector'],
      hasAC: json['hasAC'],
      buildingId: json['buildingId'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roomNumber': roomNumber,
      'capacity': capacity,
      'isSmart': isSmart,
      'hasProjector': hasProjector,
      'hasAC': hasAC,
      'buildingId': buildingId,
      'status': status,
    };
  }
}

class Laboratory {
  final String id;
  final String name;
  final String code;
  final int capacity;
  final int equipmentCount;
  final String labType;
  final String buildingId;
  final String departmentId;
  final String status;

  Laboratory({
    required this.id,
    required this.name,
    required this.code,
    required this.capacity,
    required this.equipmentCount,
    required this.labType,
    required this.buildingId,
    required this.departmentId,
    required this.status,
  });

  factory Laboratory.fromJson(Map<String, dynamic> json) {
    return Laboratory(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      capacity: json['capacity'],
      equipmentCount: json['equipmentCount'],
      labType: json['labType'],
      buildingId: json['buildingId'],
      departmentId: json['departmentId'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'capacity': capacity,
      'equipmentCount': equipmentCount,
      'labType': labType,
      'buildingId': buildingId,
      'departmentId': departmentId,
      'status': status,
    };
  }
}

class WorkingDay {
  final String id;
  final String dayOfWeek;
  final bool isEnabled;

  WorkingDay({
    required this.id,
    required this.dayOfWeek,
    required this.isEnabled,
  });

  factory WorkingDay.fromJson(Map<String, dynamic> json) {
    return WorkingDay(
      id: json['id'],
      dayOfWeek: json['dayOfWeek'],
      isEnabled: json['isEnabled'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dayOfWeek': dayOfWeek,
      'isEnabled': isEnabled,
    };
  }
}

class PeriodConfiguration {
  final String id;
  final String name;
  final String startTime;
  final String endTime;
  final bool isBreak;
  final String templateId;

  PeriodConfiguration({
    required this.id,
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.isBreak,
    required this.templateId,
  });

  factory PeriodConfiguration.fromJson(Map<String, dynamic> json) {
    return PeriodConfiguration(
      id: json['id'],
      name: json['name'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      isBreak: json['isBreak'],
      templateId: json['templateId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'startTime': startTime,
      'endTime': endTime,
      'isBreak': isBreak,
      'templateId': templateId,
    };
  }
}

class InstitutionPolicy {
  final String id;
  final String key;
  final String value;
  final String? description;

  InstitutionPolicy({
    required this.id,
    required this.key,
    required this.value,
    this.description,
  });

  factory InstitutionPolicy.fromJson(Map<String, dynamic> json) {
    return InstitutionPolicy(
      id: json['id'],
      key: json['key'],
      value: json['value'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'key': key,
      'value': value,
      'description': description,
    };
  }
}

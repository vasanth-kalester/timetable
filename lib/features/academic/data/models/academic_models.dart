class AcademicYear {
  final String id;
  final String name;
  final int startDate;
  final int endDate;
  final String status;

  AcademicYear({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.status,
  });

  factory AcademicYear.fromJson(Map<String, dynamic> json) {
    return AcademicYear(
      id: json['id'],
      name: json['name'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'startDate': startDate,
      'endDate': endDate,
      'status': status,
    };
  }
}

class Department {
  final String id;
  final String name;
  final String code;
  final String? collegeId;
  final String status;
  final String readinessStatus;

  Department({
    required this.id,
    required this.name,
    required this.code,
    this.collegeId,
    required this.status,
    required this.readinessStatus,
  });

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      collegeId: json['collegeId'],
      status: json['status'],
      readinessStatus: json['readinessStatus'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'collegeId': collegeId,
      'status': status,
      'readinessStatus': readinessStatus,
    };
  }
}

class Program {
  final String id;
  final String name;
  final String code;
  final String degree;
  final int durationYears;
  final int totalSemesters;
  final int intakeCapacity;
  final String departmentId;
  final String status;

  Program({
    required this.id,
    required this.name,
    required this.code,
    required this.degree,
    required this.durationYears,
    required this.totalSemesters,
    required this.intakeCapacity,
    required this.departmentId,
    required this.status,
  });

  factory Program.fromJson(Map<String, dynamic> json) {
    return Program(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      degree: json['degree'],
      durationYears: json['durationYears'],
      totalSemesters: json['totalSemesters'],
      intakeCapacity: json['intakeCapacity'],
      departmentId: json['departmentId'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'degree': degree,
      'durationYears': durationYears,
      'totalSemesters': totalSemesters,
      'intakeCapacity': intakeCapacity,
      'departmentId': departmentId,
      'status': status,
    };
  }
}

class Semester {
  final String id;
  final String name;
  final int number;
  final String programId;

  Semester({
    required this.id,
    required this.name,
    required this.number,
    required this.programId,
  });

  factory Semester.fromJson(Map<String, dynamic> json) {
    return Semester(
      id: json['id'],
      name: json['name'],
      number: json['number'],
      programId: json['programId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'number': number,
      'programId': programId,
    };
  }
}

class Section {
  final String id;
  final String name;
  final int intake;
  final String semesterId;
  final String? homeClassroomId;
  final String status;

  Section({
    required this.id,
    required this.name,
    required this.intake,
    required this.semesterId,
    this.homeClassroomId,
    required this.status,
  });

  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(
      id: json['id'],
      name: json['name'],
      intake: json['intake'],
      semesterId: json['semesterId'],
      homeClassroomId: json['homeClassroomId'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'intake': intake,
      'semesterId': semesterId,
      'homeClassroomId': homeClassroomId,
      'status': status,
    };
  }
}

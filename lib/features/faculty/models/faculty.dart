class Faculty {
  final String id;
  final String employeeId;
  final String name;
  final String email;
  final String? phone;
  final String departmentId;
  final String? designation;
  final String? qualification;
  final int? experience;
  final int? joiningDate;
  final String employmentType;
  final String status;
  final String schedulingReadiness;
  final String? skills;
  final String? profilePicture;
  final int createdAt;
  final int updatedAt;

  Faculty({
    required this.id,
    required this.employeeId,
    required this.name,
    required this.email,
    this.phone,
    required this.departmentId,
    this.designation,
    this.qualification,
    this.experience,
    this.joiningDate,
    required this.employmentType,
    required this.status,
    required this.schedulingReadiness,
    this.skills,
    this.profilePicture,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Faculty.fromJson(Map<String, dynamic> json) {
    return Faculty(
      id: json['id'],
      employeeId: json['employeeId'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      departmentId: json['departmentId'],
      designation: json['designation'],
      qualification: json['qualification'],
      experience: json['experience'],
      joiningDate: json['joiningDate'],
      employmentType: json['employmentType'] ?? 'Full Time',
      status: json['status'] ?? 'Active',
      schedulingReadiness: json['schedulingReadiness'] ?? 'Draft',
      skills: json['skills'],
      profilePicture: json['profilePicture'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'name': name,
      'email': email,
      'phone': phone,
      'departmentId': departmentId,
      'designation': designation,
      'qualification': qualification,
      'experience': experience,
      'joiningDate': joiningDate,
      'employmentType': employmentType,
      'status': status,
      'schedulingReadiness': schedulingReadiness,
      'skills': skills,
      'profilePicture': profilePicture,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class SchedulingProfile {
  final String id;
  final String facultyId;
  final int maxPeriodsPerDay;
  final int maxPeriodsPerWeek;
  final int maxConsecutiveClasses;
  final String? preferredFreeDay;
  final bool avoidFirstHour;
  final bool avoidLastHour;
  final bool canHandleTheory;
  final bool canHandleLabs;
  final bool canHandleTutorials;
  final String? preferredBuildings;
  final int createdAt;
  final int updatedAt;

  SchedulingProfile({
    required this.id,
    required this.facultyId,
    required this.maxPeriodsPerDay,
    required this.maxPeriodsPerWeek,
    required this.maxConsecutiveClasses,
    this.preferredFreeDay,
    required this.avoidFirstHour,
    required this.avoidLastHour,
    required this.canHandleTheory,
    required this.canHandleLabs,
    required this.canHandleTutorials,
    this.preferredBuildings,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SchedulingProfile.fromJson(Map<String, dynamic> json) {
    return SchedulingProfile(
      id: json['id'],
      facultyId: json['facultyId'],
      maxPeriodsPerDay: json['maxPeriodsPerDay'] ?? 4,
      maxPeriodsPerWeek: json['maxPeriodsPerWeek'] ?? 18,
      maxConsecutiveClasses: json['maxConsecutiveClasses'] ?? 2,
      preferredFreeDay: json['preferredFreeDay'],
      avoidFirstHour: json['avoidFirstHour'] ?? false,
      avoidLastHour: json['avoidLastHour'] ?? false,
      canHandleTheory: json['canHandleTheory'] ?? true,
      canHandleLabs: json['canHandleLabs'] ?? true,
      canHandleTutorials: json['canHandleTutorials'] ?? true,
      preferredBuildings: json['preferredBuildings'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'facultyId': facultyId,
      'maxPeriodsPerDay': maxPeriodsPerDay,
      'maxPeriodsPerWeek': maxPeriodsPerWeek,
      'maxConsecutiveClasses': maxConsecutiveClasses,
      'preferredFreeDay': preferredFreeDay,
      'avoidFirstHour': avoidFirstHour,
      'avoidLastHour': avoidLastHour,
      'canHandleTheory': canHandleTheory,
      'canHandleLabs': canHandleLabs,
      'canHandleTutorials': canHandleTutorials,
      'preferredBuildings': preferredBuildings,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class Availability {
  final String id;
  final String facultyId;
  final int dayOfWeek;
  final int period;
  final bool isAvailable;
  final String? reason;
  final int createdAt;
  final int updatedAt;

  Availability({
    required this.id,
    required this.facultyId,
    required this.dayOfWeek,
    required this.period,
    required this.isAvailable,
    this.reason,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Availability.fromJson(Map<String, dynamic> json) {
    return Availability(
      id: json['id'],
      facultyId: json['facultyId'],
      dayOfWeek: json['dayOfWeek'],
      period: json['period'],
      isAvailable: json['isAvailable'] ?? true,
      reason: json['reason'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'facultyId': facultyId,
      'dayOfWeek': dayOfWeek,
      'period': period,
      'isAvailable': isAvailable,
      'reason': reason,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class Leave {
  final String id;
  final String facultyId;
  final String leaveType;
  final int startDate;
  final int endDate;
  final String status;
  final String? reason;
  final int createdAt;
  final int updatedAt;

  Leave({
    required this.id,
    required this.facultyId,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.reason,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Leave.fromJson(Map<String, dynamic> json) {
    return Leave(
      id: json['id'],
      facultyId: json['facultyId'],
      leaveType: json['leaveType'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      status: json['status'] ?? 'Pending',
      reason: json['reason'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'facultyId': facultyId,
      'leaveType': leaveType,
      'startDate': startDate,
      'endDate': endDate,
      'status': status,
      'reason': reason,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

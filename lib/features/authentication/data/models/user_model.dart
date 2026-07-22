import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.identifier,
    required super.fullName,
    required super.email,
    required super.role,
    required super.department,
    super.designation,
    super.rollNumber,
    super.employeeId,
    super.avatarUrl,
    super.phone,
    super.semester,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      identifier: json['identifier'] as String? ?? json['email'] as String,
      fullName: json['full_name'] as String,
      email: json['email'] as String,
      role: _parseRole(json['role'] as String?),
      department: json['department'] as String? ?? 'Computer Science',
      designation: json['designation'] as String?,
      rollNumber: json['roll_number'] as String?,
      employeeId: json['employee_id'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      phone: json['phone'] as String?,
      semester: json['semester'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'identifier': identifier,
      'full_name': fullName,
      'email': email,
      'role': role.name,
      'department': department,
      'designation': designation,
      'roll_number': rollNumber,
      'employee_id': employeeId,
      'avatar_url': avatarUrl,
      'phone': phone,
      'semester': semester,
    };
  }

  static UserRole _parseRole(String? roleStr) {
    switch (roleStr?.toLowerCase()) {
      case 'student':
        return UserRole.student;
      case 'faculty':
        return UserRole.faculty;
      case 'hod':
        return UserRole.hod;
      case 'principal':
        return UserRole.principal;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.student;
    }
  }
}

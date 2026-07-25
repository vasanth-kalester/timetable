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
    super.collegeId,
    super.departmentId,
    super.approvalStatus,
    super.permissions,
  });

  /// Parse a UserModel from the FastAPI /auth/login or /users/me response.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    final roleStr = json['role'] as String? ?? 'student';
    final role = _parseRole(roleStr);

    final firstName = json['first_name'] as String? ?? '';
    final lastName = json['last_name'] as String? ?? '';
    final fullName = (json['full_name'] as String?)?.isNotEmpty == true
        ? json['full_name'] as String
        : [firstName, lastName].where((s) => s.isNotEmpty).join(' ');

    final rawPermissions = json['permissions'];
    final permissions = rawPermissions is List
        ? rawPermissions.map((e) => e.toString()).toList()
        : <String>[];

    return UserModel(
      id: json['id'] as String,
      identifier: json['email'] as String,
      fullName: fullName.isNotEmpty ? fullName : json['email'] as String,
      email: json['email'] as String,
      role: role,
      department: json['department_name'] as String? ?? '',
      designation: json['designation'] as String?,
      rollNumber: json['roll_number'] as String?,
      employeeId: json['employee_id'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      phone: json['phone'] as String?,
      semester: json['semester'] as String?,
      collegeId: json['college_id'] as String?,
      departmentId: json['department_id'] as String?,
      approvalStatus: json['approval_status'] as String? ?? 'pending',
      permissions: permissions,
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
      'college_id': collegeId,
      'department_id': departmentId,
      'approval_status': approvalStatus,
      'permissions': permissions,
    };
  }

  static UserRole _parseRole(String roleStr) {
    switch (roleStr.toLowerCase()) {
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

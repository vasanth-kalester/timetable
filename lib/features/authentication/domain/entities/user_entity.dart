enum UserRole { student, faculty, hod, principal, admin }

class UserEntity {
  final String id;
  final String identifier; // Email / Employee ID / Roll Number
  final String fullName;
  final String email;
  final UserRole role;
  final String department;
  final String? designation;
  final String? rollNumber;
  final String? employeeId;
  final String? avatarUrl;
  final String? phone;
  final String? semester;
  final String? collegeId;
  final String? departmentId;
  final String approvalStatus;

  /// API-provided permission list. Used for fine-grained access control.
  final List<String> permissions;

  const UserEntity({
    required this.id,
    required this.identifier,
    required this.fullName,
    required this.email,
    required this.role,
    required this.department,
    this.designation,
    this.rollNumber,
    this.employeeId,
    this.avatarUrl,
    this.phone,
    this.semester,
    this.collegeId,
    this.departmentId,
    this.approvalStatus = 'approved',
    this.permissions = const [],
  });

  /// Check if this user has the given permission key.
  /// For admin role, always returns true. For others, checks the API-provided list.
  bool hasPermission(String permissionKey) {
    if (role == UserRole.admin) return true;
    return permissions.contains(permissionKey);
  }

  /// Convenience: check if user can access a given route based on role.
  bool get isPrincipal => role == UserRole.principal;
  bool get isHod => role == UserRole.hod;
  bool get isFaculty => role == UserRole.faculty;
  bool get isStudent => role == UserRole.student;
  bool get isAdmin => role == UserRole.admin;

  /// Returns the role-appropriate home dashboard route.
  String get dashboardRoute {
    switch (role) {
      case UserRole.principal:
        return '/principal-dashboard';
      case UserRole.hod:
        return '/hod-dashboard';
      case UserRole.faculty:
        return '/faculty-dashboard';
      case UserRole.student:
        return '/student-dashboard';
      case UserRole.admin:
        return '/dashboard';
    }
  }
}

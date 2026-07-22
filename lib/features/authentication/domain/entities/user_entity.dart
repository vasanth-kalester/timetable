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
  });

  bool hasPermission(String permissionKey) {
    if (role == UserRole.admin) return true;

    final Map<UserRole, Set<String>> rolePermissions = {
      UserRole.student: {
        'view_timetable',
        'view_attendance',
        'view_exams',
        'edit_self_profile',
      },
      UserRole.faculty: {
        'view_timetable',
        'view_attendance',
        'take_attendance',
        'view_assigned_timetable',
        'apply_leave',
        'book_classrooms',
        'edit_self_profile',
      },
      UserRole.hod: {
        'view_timetable',
        'view_attendance',
        'take_attendance',
        'view_assigned_timetable',
        'apply_leave',
        'book_classrooms',
        'dept_management',
        'faculty_workload',
        'timetable_approval',
        'approve_leave',
        'edit_self_profile',
      },
      UserRole.principal: {
        'view_timetable',
        'view_attendance',
        'campus_dashboard',
        'campus_analytics',
        'generate_reports',
        'edit_self_profile',
      },
    };

    return rolePermissions[role]?.contains(permissionKey) ?? false;
  }
}

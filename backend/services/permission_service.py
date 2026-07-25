from typing import Dict, List

# Permission map keyed by role name
ROLE_PERMISSIONS: Dict[str, List[str]] = {
    "student": [
        "timetable.view",
        "profile.view",
        "profile.edit_self",
        "attendance.view",
        "exams.view",
        "notifications.view",
    ],
    "faculty": [
        "timetable.view",
        "timetable.view_assigned",
        "profile.view",
        "profile.edit_self",
        "attendance.view",
        "attendance.take",
        "leave.apply",
        "classroom.book",
        "workload.view_self",
    ],
    "hod": [
        "timetable.view",
        "timetable.view_assigned",
        "timetable.approve",
        "profile.view",
        "profile.edit_self",
        "attendance.view",
        "attendance.take",
        "leave.apply",
        "leave.approve",
        "classroom.book",
        "workload.view_self",
        "workload.view_department",
        "faculty.view",
        "faculty.create",
        "faculty.edit",
        "subject.manage",
        "section.manage",
        "department.manage",
    ],
    "principal": [
        "timetable.view",
        "timetable.generate",
        "timetable.publish",
        "timetable.approve",
        "profile.view",
        "profile.edit_self",
        "attendance.view",
        "leave.approve",
        "faculty.view",
        "faculty.create",
        "faculty.edit",
        "faculty.delete",
        "hod.view",
        "hod.create",
        "hod.edit",
        "hod.delete",
        "department.view",
        "department.manage",
        "institution.configure",
        "analytics.view",
        "reports.generate",
        "campus.manage",
    ],
    "admin": [
        "*",  # Super admin has all permissions
    ],
}


def get_permissions_for_role(role: str) -> List[str]:
    """Return the list of permission strings for a given role."""
    return ROLE_PERMISSIONS.get(role, [])


def has_permission(role: str, permission: str) -> bool:
    """Check if a role has a specific permission."""
    permissions = get_permissions_for_role(role)
    return "*" in permissions or permission in permissions

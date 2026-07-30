from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import List, Optional

from core.database import get_db
from core.dependencies import require_role
from models.user import User
from models.faculty import Leave
from schemas.faculty import (
    FacultyCreate, FacultyUpdate, FacultyResponse,
    SchedulingProfileCreate, SchedulingProfileUpdate, SchedulingProfileResponse,
    AvailabilityCreate, AvailabilityUpdate, AvailabilityResponse,
    LeaveCreate, LeaveUpdate, LeaveResponse,
    CrossDepartmentTeachingCreate, CrossDepartmentTeachingResponse
)
from services.faculty_service import FacultyService
from services.audit_service import AuditService

router = APIRouter(prefix="/faculty", tags=["Faculty Management"])

# --- Faculty ---
@router.post("/", response_model=FacultyResponse)
def create_faculty(
    faculty: FacultyCreate, 
    db: Session = Depends(get_db), 
    current_user: User = Depends(require_role("principal", "hod", "admin"))
):
    db_faculty = FacultyService.create_faculty(db, faculty)
    AuditService.log_action(db, current_user, "CREATE", "Faculty", db_faculty.id, new_value=faculty.model_dump())
    return db_faculty

@router.get("/", response_model=List[FacultyResponse])
def get_all_faculty(
    departmentId: Optional[str] = Query(None),
    status: Optional[str] = Query(None),
    db: Session = Depends(get_db),
    _ = Depends(require_role("principal", "hod", "admin"))
):
    return FacultyService.get_all_faculty(db, department_id=departmentId, status=status)

@router.get("/{faculty_id}", response_model=FacultyResponse)
def get_faculty(
    faculty_id: str, 
    db: Session = Depends(get_db),
    _ = Depends(require_role("principal", "hod", "admin"))
):
    return FacultyService.get_faculty(db, faculty_id)

@router.put("/{faculty_id}", response_model=FacultyResponse)
def update_faculty(
    faculty_id: str, 
    faculty: FacultyUpdate, 
    db: Session = Depends(get_db),
    current_user: User = Depends(require_role("principal", "hod", "admin"))
):
    old_faculty = FacultyService.get_faculty(db, faculty_id)
    old_value = {k: getattr(old_faculty, k) for k in faculty.model_dump(exclude_unset=True).keys()}
    
    db_faculty = FacultyService.update_faculty(db, faculty_id, faculty)
    AuditService.log_action(db, current_user, "UPDATE", "Faculty", db_faculty.id, old_value=old_value, new_value=faculty.model_dump(exclude_unset=True))
    return db_faculty

# --- Scheduling Profile ---
@router.post("/{faculty_id}/scheduling-profile", response_model=SchedulingProfileResponse)
def create_scheduling_profile(
    faculty_id: str,
    profile: SchedulingProfileCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_role("principal", "hod", "admin"))
):
    if profile.facultyId != faculty_id:
        raise HTTPException(status_code=400, detail="Faculty ID mismatch")
    db_profile = FacultyService.create_scheduling_profile(db, profile)
    AuditService.log_action(db, current_user, "CREATE", "SchedulingProfile", db_profile.id, new_value=profile.model_dump())
    return db_profile

@router.get("/{faculty_id}/scheduling-profile", response_model=SchedulingProfileResponse)
def get_scheduling_profile(
    faculty_id: str,
    db: Session = Depends(get_db),
    _ = Depends(require_role("principal", "hod", "admin"))
):
    profile = FacultyService.get_scheduling_profile(db, faculty_id)
    if not profile:
        raise HTTPException(status_code=404, detail="Scheduling profile not found")
    return profile

@router.put("/{faculty_id}/scheduling-profile/{profile_id}", response_model=SchedulingProfileResponse)
def update_scheduling_profile(
    faculty_id: str,
    profile_id: str,
    profile: SchedulingProfileUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_role("principal", "hod", "admin"))
):
    db_profile = FacultyService.update_scheduling_profile(db, profile_id, profile)
    AuditService.log_action(db, current_user, "UPDATE", "SchedulingProfile", db_profile.id, new_value=profile.model_dump(exclude_unset=True))
    return db_profile

# --- Availability ---
@router.post("/{faculty_id}/availability", response_model=AvailabilityResponse)
def create_availability(
    faculty_id: str,
    availability: AvailabilityCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_role("principal", "hod", "admin"))
):
    if availability.facultyId != faculty_id:
        raise HTTPException(status_code=400, detail="Faculty ID mismatch")
    db_avail = FacultyService.create_availability(db, availability)
    AuditService.log_action(db, current_user, "CREATE", "Availability", db_avail.id, new_value=availability.model_dump())
    return db_avail

@router.get("/{faculty_id}/availability", response_model=List[AvailabilityResponse])
def get_availability(
    faculty_id: str,
    db: Session = Depends(get_db),
    _ = Depends(require_role("principal", "hod", "admin"))
):
    return FacultyService.get_faculty_availability(db, faculty_id)

# --- Leave ---
@router.post("/{faculty_id}/leaves", response_model=LeaveResponse)
def create_leave(
    faculty_id: str,
    leave: LeaveCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_role("principal", "hod", "admin"))
):
    if leave.facultyId != faculty_id:
        raise HTTPException(status_code=400, detail="Faculty ID mismatch")
    db_leave = FacultyService.create_leave(db, leave)
    AuditService.log_action(db, current_user, "CREATE", "Leave", db_leave.id, new_value=leave.model_dump())
    return db_leave

@router.get("/{faculty_id}/leaves", response_model=List[LeaveResponse])
def get_leaves(
    faculty_id: str,
    db: Session = Depends(get_db),
    _ = Depends(require_role("principal", "hod", "admin"))
):
    return FacultyService.get_faculty_leaves(db, faculty_id)

@router.put("/{faculty_id}/leaves/{leave_id}", response_model=LeaveResponse)
def update_leave(
    faculty_id: str,
    leave_id: str,
    leave: LeaveUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_role("principal", "hod", "admin"))
):
    old_leave = db.query(Leave).filter(Leave.id == leave_id).first()
    if not old_leave:
        raise HTTPException(status_code=404, detail="Leave not found")
    old_value = {k: getattr(old_leave, k) for k in leave.model_dump(exclude_unset=True).keys()}
    
    db_leave = FacultyService.update_leave(db, leave_id, leave)
    AuditService.log_action(db, current_user, "UPDATE", "Leave", db_leave.id, old_value=old_value, new_value=leave.model_dump(exclude_unset=True))
    return db_leave

# --- Cross Department Teaching ---
@router.post("/{faculty_id}/cross-departments", response_model=CrossDepartmentTeachingResponse)
def assign_cross_department(
    faculty_id: str,
    assignment: CrossDepartmentTeachingCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_role("principal", "hod", "admin"))
):
    if assignment.facultyId != faculty_id:
        raise HTTPException(status_code=400, detail="Faculty ID mismatch")
    db_assignment = FacultyService.assign_cross_department(db, assignment)
    AuditService.log_action(db, current_user, "CREATE", "CrossDepartmentTeaching", db_assignment.id, new_value=assignment.model_dump())
    return db_assignment

@router.get("/{faculty_id}/cross-departments", response_model=List[CrossDepartmentTeachingResponse])
def get_cross_departments(
    faculty_id: str,
    db: Session = Depends(get_db),
    _ = Depends(require_role("principal", "hod", "admin"))
):
    return FacultyService.get_cross_departments(db, faculty_id)

@router.delete("/{faculty_id}/cross-departments/{department_id}")
def remove_cross_department(
    faculty_id: str,
    department_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_role("principal", "hod", "admin"))
):
    FacultyService.remove_cross_department(db, faculty_id, department_id)
    AuditService.log_action(db, current_user, "DELETE", "CrossDepartmentTeaching", f"{faculty_id}-{department_id}")
    return {"message": "Cross-department assignment removed successfully"}

from sqlalchemy.orm import Session
from fastapi import HTTPException
import uuid
import time
from models.faculty import Faculty, SchedulingProfile, Availability, Leave, CrossDepartmentTeaching
from schemas.faculty import (
    FacultyCreate, FacultyUpdate,
    SchedulingProfileCreate, SchedulingProfileUpdate,
    AvailabilityCreate, AvailabilityUpdate,
    LeaveCreate, LeaveUpdate,
    CrossDepartmentTeachingCreate
)

def get_current_time():
    return int(time.time() * 1000)

class FacultyService:
    @staticmethod
    def create_faculty(db: Session, faculty_data: FacultyCreate) -> Faculty:
        # Check for duplicate employee ID
        existing = db.query(Faculty).filter(Faculty.employeeId == faculty_data.employeeId).first()
        if existing:
            raise HTTPException(status_code=400, detail="Employee ID already exists")
        
        # Check for duplicate email
        existing_email = db.query(Faculty).filter(Faculty.email == faculty_data.email).first()
        if existing_email:
            raise HTTPException(status_code=400, detail="Email already exists")

        db_faculty = Faculty(
            id=str(uuid.uuid4()),
            **faculty_data.model_dump(),
            createdAt=get_current_time(),
            updatedAt=get_current_time()
        )
        db.add(db_faculty)
        db.commit()
        db.refresh(db_faculty)
        return db_faculty

    @staticmethod
    def update_faculty(db: Session, faculty_id: str, faculty_data: FacultyUpdate) -> Faculty:
        db_faculty = db.query(Faculty).filter(Faculty.id == faculty_id).first()
        if not db_faculty:
            raise HTTPException(status_code=404, detail="Faculty not found")
        
        update_data = faculty_data.model_dump(exclude_unset=True)
        for key, value in update_data.items():
            setattr(db_faculty, key, value)
            
        db_faculty.updatedAt = get_current_time()
        db.commit()
        db.refresh(db_faculty)
        return db_faculty

    @staticmethod
    def get_faculty(db: Session, faculty_id: str) -> Faculty:
        db_faculty = db.query(Faculty).filter(Faculty.id == faculty_id).first()
        if not db_faculty:
            raise HTTPException(status_code=404, detail="Faculty not found")
        return db_faculty

    @staticmethod
    def get_all_faculty(db: Session, department_id: str = None, status: str = None):
        query = db.query(Faculty)
        if department_id:
            query = query.filter(Faculty.departmentId == department_id)
        if status:
            query = query.filter(Faculty.status == status)
        return query.all()

    @staticmethod
    def create_scheduling_profile(db: Session, profile_data: SchedulingProfileCreate) -> SchedulingProfile:
        existing = db.query(SchedulingProfile).filter(SchedulingProfile.facultyId == profile_data.facultyId).first()
        if existing:
            raise HTTPException(status_code=400, detail="Scheduling profile already exists for this faculty")
            
        if profile_data.maxPeriodsPerDay > profile_data.maxPeriodsPerWeek:
            raise HTTPException(status_code=400, detail="Max daily periods cannot exceed max weekly periods")
            
        db_profile = SchedulingProfile(
            id=str(uuid.uuid4()),
            **profile_data.model_dump(),
            createdAt=get_current_time(),
            updatedAt=get_current_time()
        )
        db.add(db_profile)
        db.commit()
        db.refresh(db_profile)
        return db_profile

    @staticmethod
    def update_scheduling_profile(db: Session, profile_id: str, profile_data: SchedulingProfileUpdate) -> SchedulingProfile:
        db_profile = db.query(SchedulingProfile).filter(SchedulingProfile.id == profile_id).first()
        if not db_profile:
            raise HTTPException(status_code=404, detail="Scheduling profile not found")
            
        update_data = profile_data.model_dump(exclude_unset=True)
        
        max_daily = update_data.get("maxPeriodsPerDay", db_profile.maxPeriodsPerDay)
        max_weekly = update_data.get("maxPeriodsPerWeek", db_profile.maxPeriodsPerWeek)
        
        if max_daily > max_weekly:
            raise HTTPException(status_code=400, detail="Max daily periods cannot exceed max weekly periods")
            
        for key, value in update_data.items():
            setattr(db_profile, key, value)
            
        db_profile.updatedAt = get_current_time()
        db.commit()
        db.refresh(db_profile)
        return db_profile

    @staticmethod
    def get_scheduling_profile(db: Session, faculty_id: str) -> SchedulingProfile:
        return db.query(SchedulingProfile).filter(SchedulingProfile.facultyId == faculty_id).first()

    @staticmethod
    def create_availability(db: Session, availability_data: AvailabilityCreate) -> Availability:
        # Check for conflicts
        existing = db.query(Availability).filter(
            Availability.facultyId == availability_data.facultyId,
            Availability.dayOfWeek == availability_data.dayOfWeek,
            Availability.period == availability_data.period
        ).first()
        
        if existing:
            raise HTTPException(status_code=400, detail="Availability record already exists for this day and period")
            
        db_avail = Availability(
            id=str(uuid.uuid4()),
            **availability_data.model_dump(),
            createdAt=get_current_time(),
            updatedAt=get_current_time()
        )
        db.add(db_avail)
        db.commit()
        db.refresh(db_avail)
        return db_avail

    @staticmethod
    def get_faculty_availability(db: Session, faculty_id: str):
        return db.query(Availability).filter(Availability.facultyId == faculty_id).all()

    @staticmethod
    def create_leave(db: Session, leave_data: LeaveCreate) -> Leave:
        db_leave = Leave(
            id=str(uuid.uuid4()),
            **leave_data.model_dump(),
            createdAt=get_current_time(),
            updatedAt=get_current_time()
        )
        db.add(db_leave)
        db.commit()
        db.refresh(db_leave)
        return db_leave

    @staticmethod
    def get_faculty_leaves(db: Session, faculty_id: str):
        return db.query(Leave).filter(Leave.facultyId == faculty_id).all()

    @staticmethod
    def update_leave(db: Session, leave_id: str, leave_data: LeaveUpdate) -> Leave:
        db_leave = db.query(Leave).filter(Leave.id == leave_id).first()
        if not db_leave:
            raise HTTPException(status_code=404, detail="Leave not found")
            
        update_data = leave_data.model_dump(exclude_unset=True)
        for key, value in update_data.items():
            setattr(db_leave, key, value)
            
        db_leave.updatedAt = get_current_time()
        db.commit()
        db.refresh(db_leave)
        return db_leave

    @staticmethod
    def can_receive_assignments(db: Session, faculty_id: str) -> bool:
        faculty = db.query(Faculty).filter(Faculty.id == faculty_id).first()
        if not faculty:
            return False
        return faculty.status == "Active" and faculty.schedulingReadiness == "Ready"

    @staticmethod
    def assign_cross_department(db: Session, assignment_data: CrossDepartmentTeachingCreate) -> CrossDepartmentTeaching:
        existing = db.query(CrossDepartmentTeaching).filter(
            CrossDepartmentTeaching.facultyId == assignment_data.facultyId,
            CrossDepartmentTeaching.departmentId == assignment_data.departmentId
        ).first()
        
        if existing:
            raise HTTPException(status_code=400, detail="Faculty is already assigned to this department")
            
        db_assignment = CrossDepartmentTeaching(
            id=str(uuid.uuid4()),
            **assignment_data.model_dump(),
            createdAt=get_current_time(),
            updatedAt=get_current_time()
        )
        db.add(db_assignment)
        db.commit()
        db.refresh(db_assignment)
        return db_assignment

    @staticmethod
    def remove_cross_department(db: Session, faculty_id: str, department_id: str):
        db_assignment = db.query(CrossDepartmentTeaching).filter(
            CrossDepartmentTeaching.facultyId == faculty_id,
            CrossDepartmentTeaching.departmentId == department_id
        ).first()
        
        if not db_assignment:
            raise HTTPException(status_code=404, detail="Cross-department assignment not found")
            
        db.delete(db_assignment)
        db.commit()
        return True

    @staticmethod
    def get_cross_departments(db: Session, faculty_id: str):
        return db.query(CrossDepartmentTeaching).filter(CrossDepartmentTeaching.facultyId == faculty_id).all()

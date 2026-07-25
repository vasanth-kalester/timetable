from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
import time
import uuid

from core.database import get_db
from core.dependencies import require_role
from models.academic import AcademicYear, Program, Semester, Section
from models.user import Department
from schemas.academic import (
    AcademicYearCreate, AcademicYearUpdate, AcademicYearResponse,
    DepartmentCreate, DepartmentUpdate, DepartmentResponse,
    ProgramCreate, ProgramUpdate, ProgramResponse,
    SemesterCreate, SemesterUpdate, SemesterResponse,
    SectionCreate, SectionUpdate, SectionResponse
)
from services.validation_service import ValidationService
from services.audit_service import AuditService
from models.user import User

router = APIRouter(prefix="/academic", tags=["Academic Structure"])

def get_current_time():
    return int(time.time() * 1000)

# --- Academic Year ---
@router.get("/years", response_model=List[AcademicYearResponse])
def get_academic_years(db: Session = Depends(get_db), _ = Depends(require_role("principal", "hod", "admin"))):
    return db.query(AcademicYear).all()

@router.post("/years", response_model=AcademicYearResponse)
def create_academic_year(year: AcademicYearCreate, db: Session = Depends(get_db), current_user: User = Depends(require_role("principal", "admin"))):
    if year.status == "ready" or year.status == "frozen":
        ValidationService.validate_academic_year_transition(db, None, year.status)
        
    db_year = AcademicYear(
        id=str(uuid.uuid4()),
        **year.model_dump(),
        createdAt=get_current_time(),
        updatedAt=get_current_time()
    )
    db.add(db_year)
    db.commit()
    db.refresh(db_year)
    
    AuditService.log_action(db, current_user, "CREATE", "AcademicYear", db_year.id, new_value=year.model_dump())
    return db_year

@router.put("/years/{year_id}", response_model=AcademicYearResponse)
def update_academic_year(year_id: str, year: AcademicYearUpdate, db: Session = Depends(get_db), current_user: User = Depends(require_role("principal", "admin"))):
    db_year = db.query(AcademicYear).filter(AcademicYear.id == year_id).first()
    if not db_year:
        raise HTTPException(status_code=404, detail="Academic year not found")
        
    if db_year.status == "archived":
        raise HTTPException(status_code=400, detail="Cannot edit an archived academic year")
        
    update_data = year.model_dump(exclude_unset=True)
    
    if "status" in update_data and update_data["status"] != db_year.status:
        ValidationService.validate_academic_year_transition(db, year_id, update_data["status"])
        
    old_value = {k: getattr(db_year, k) for k in update_data.keys()}
        
    for key, value in update_data.items():
        setattr(db_year, key, value)
    
    db_year.updatedAt = get_current_time()
    db.commit()
    db.refresh(db_year)
    
    AuditService.log_action(db, current_user, "UPDATE", "AcademicYear", db_year.id, old_value=old_value, new_value=update_data)
    return db_year

# --- Department ---
@router.get("/departments", response_model=List[DepartmentResponse])
def get_departments(db: Session = Depends(get_db), _ = Depends(require_role("principal", "hod", "admin"))):
    return db.query(Department).filter(Department.status == "active").all()

@router.post("/departments", response_model=DepartmentResponse)
def create_department(dept: DepartmentCreate, db: Session = Depends(get_db), _ = Depends(require_role("principal", "admin"))):
    db_dept = Department(
        id=str(uuid.uuid4()),
        **dept.model_dump(),
        createdAt=get_current_time(),
        updatedAt=get_current_time()
    )
    db.add(db_dept)
    db.commit()
    db.refresh(db_dept)
    return db_dept

@router.put("/departments/{dept_id}", response_model=DepartmentResponse)
def update_department(dept_id: str, dept: DepartmentUpdate, db: Session = Depends(get_db), _ = Depends(require_role("principal", "admin"))):
    db_dept = db.query(Department).filter(Department.id == dept_id).first()
    if not db_dept:
        raise HTTPException(status_code=404, detail="Department not found")
    
    for key, value in dept.model_dump(exclude_unset=True).items():
        setattr(db_dept, key, value)
    
    db_dept.updatedAt = get_current_time()
    db.commit()
    db.refresh(db_dept)
    return db_dept

# --- Program ---
@router.get("/programs", response_model=List[ProgramResponse])
def get_programs(departmentId: str = None, db: Session = Depends(get_db), _ = Depends(require_role("principal", "hod", "admin"))):
    query = db.query(Program).filter(Program.status == "active")
    if departmentId:
        query = query.filter(Program.departmentId == departmentId)
    return query.all()

@router.post("/programs", response_model=ProgramResponse)
def create_program(prog: ProgramCreate, db: Session = Depends(get_db), _ = Depends(require_role("principal", "hod", "admin"))):
    db_prog = Program(
        id=str(uuid.uuid4()),
        **prog.model_dump(),
        createdAt=get_current_time(),
        updatedAt=get_current_time()
    )
    db.add(db_prog)
    db.commit()
    db.refresh(db_prog)
    return db_prog

@router.put("/programs/{prog_id}", response_model=ProgramResponse)
def update_program(prog_id: str, prog: ProgramUpdate, db: Session = Depends(get_db), _ = Depends(require_role("principal", "hod", "admin"))):
    db_prog = db.query(Program).filter(Program.id == prog_id).first()
    if not db_prog:
        raise HTTPException(status_code=404, detail="Program not found")
    
    for key, value in prog.model_dump(exclude_unset=True).items():
        setattr(db_prog, key, value)
    
    db_prog.updatedAt = get_current_time()
    db.commit()
    db.refresh(db_prog)
    return db_prog

# --- Semester ---
@router.get("/semesters", response_model=List[SemesterResponse])
def get_semesters(programId: str = None, db: Session = Depends(get_db), _ = Depends(require_role("principal", "hod", "admin"))):
    query = db.query(Semester)
    if programId:
        query = query.filter(Semester.programId == programId)
    return query.all()

@router.post("/semesters", response_model=SemesterResponse)
def create_semester(sem: SemesterCreate, db: Session = Depends(get_db), _ = Depends(require_role("principal", "hod", "admin"))):
    db_sem = Semester(
        id=str(uuid.uuid4()),
        **sem.model_dump(),
        createdAt=get_current_time(),
        updatedAt=get_current_time()
    )
    db.add(db_sem)
    db.commit()
    db.refresh(db_sem)
    return db_sem

@router.put("/semesters/{sem_id}", response_model=SemesterResponse)
def update_semester(sem_id: str, sem: SemesterUpdate, db: Session = Depends(get_db), _ = Depends(require_role("principal", "hod", "admin"))):
    db_sem = db.query(Semester).filter(Semester.id == sem_id).first()
    if not db_sem:
        raise HTTPException(status_code=404, detail="Semester not found")
    
    for key, value in sem.model_dump(exclude_unset=True).items():
        setattr(db_sem, key, value)
    
    db_sem.updatedAt = get_current_time()
    db.commit()
    db.refresh(db_sem)
    return db_sem

# --- Section ---
@router.get("/sections", response_model=List[SectionResponse])
def get_sections(semesterId: str = None, db: Session = Depends(get_db), _ = Depends(require_role("principal", "hod", "admin"))):
    query = db.query(Section).filter(Section.status == "active")
    if semesterId:
        query = query.filter(Section.semesterId == semesterId)
    return query.all()

@router.post("/sections", response_model=SectionResponse)
def create_section(sec: SectionCreate, db: Session = Depends(get_db), current_user: User = Depends(require_role("principal", "hod", "admin"))):
    ValidationService.validate_section_capacity(db, sec.intake, sec.homeClassroomId)
    ValidationService.validate_home_classroom_uniqueness(db, sec.homeClassroomId)
    
    db_sec = Section(
        id=str(uuid.uuid4()),
        **sec.model_dump(),
        createdAt=get_current_time(),
        updatedAt=get_current_time()
    )
    db.add(db_sec)
    db.commit()
    db.refresh(db_sec)
    
    AuditService.log_action(db, current_user, "CREATE", "Section", db_sec.id, new_value=sec.model_dump())
    return db_sec

@router.put("/sections/{sec_id}", response_model=SectionResponse)
def update_section(sec_id: str, sec: SectionUpdate, db: Session = Depends(get_db), current_user: User = Depends(require_role("principal", "hod", "admin"))):
    db_sec = db.query(Section).filter(Section.id == sec_id).first()
    if not db_sec:
        raise HTTPException(status_code=404, detail="Section not found")
        
    update_data = sec.model_dump(exclude_unset=True)
    
    intake = update_data.get("intake", db_sec.intake)
    room_id = update_data.get("homeClassroomId", db_sec.homeClassroomId)
    
    if "intake" in update_data or "homeClassroomId" in update_data:
        ValidationService.validate_section_capacity(db, intake, room_id)
        
    if "homeClassroomId" in update_data:
        ValidationService.validate_home_classroom_uniqueness(db, room_id, sec_id)
    
    old_value = {k: getattr(db_sec, k) for k in update_data.keys()}
    
    for key, value in update_data.items():
        setattr(db_sec, key, value)
    
    db_sec.updatedAt = get_current_time()
    db.commit()
    db.refresh(db_sec)
    
    AuditService.log_action(db, current_user, "UPDATE", "Section", db_sec.id, old_value=old_value, new_value=update_data)
    return db_sec

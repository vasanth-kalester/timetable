from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
import time
import uuid

from core.database import get_db
from core.dependencies import require_role
from models.infrastructure import (
    Building, Classroom, Laboratory, WorkingDay, PeriodConfiguration, InstitutionPolicy
)
from schemas.infrastructure import (
    BuildingCreate, BuildingUpdate, BuildingResponse,
    ClassroomCreate, ClassroomUpdate, ClassroomResponse,
    LaboratoryCreate, LaboratoryUpdate, LaboratoryResponse,
    WorkingDayCreate, WorkingDayUpdate, WorkingDayResponse,
    PeriodConfigurationCreate, PeriodConfigurationUpdate, PeriodConfigurationResponse,
    InstitutionPolicyCreate, InstitutionPolicyUpdate, InstitutionPolicyResponse
)
from services.audit_service import AuditService
from models.user import User

router = APIRouter(prefix="/infrastructure", tags=["Infrastructure"])

def get_current_time():
    return int(time.time() * 1000)

# --- Building ---
@router.get("/buildings", response_model=List[BuildingResponse])
def get_buildings(db: Session = Depends(get_db), _ = Depends(require_role("principal", "hod", "admin"))):
    return db.query(Building).all()

@router.post("/buildings", response_model=BuildingResponse)
def create_building(bldg: BuildingCreate, db: Session = Depends(get_db), current_user: User = Depends(require_role("principal", "admin"))):
    db_bldg = Building(
        id=str(uuid.uuid4()),
        **bldg.model_dump(),
        createdAt=get_current_time(),
        updatedAt=get_current_time()
    )
    db.add(db_bldg)
    db.commit()
    db.refresh(db_bldg)
    
    AuditService.log_action(db, current_user, "CREATE", "Building", db_bldg.id, new_value=bldg.model_dump())
    return db_bldg

@router.put("/buildings/{bldg_id}", response_model=BuildingResponse)
def update_building(bldg_id: str, bldg: BuildingUpdate, db: Session = Depends(get_db), current_user: User = Depends(require_role("principal", "admin"))):
    db_bldg = db.query(Building).filter(Building.id == bldg_id).first()
    if not db_bldg:
        raise HTTPException(status_code=404, detail="Building not found")
        
    update_data = bldg.model_dump(exclude_unset=True)
    old_value = {k: getattr(db_bldg, k) for k in update_data.keys()}
    
    for key, value in update_data.items():
        setattr(db_bldg, key, value)
    
    db_bldg.updatedAt = get_current_time()
    db.commit()
    db.refresh(db_bldg)
    
    AuditService.log_action(db, current_user, "UPDATE", "Building", db_bldg.id, old_value=old_value, new_value=update_data)
    return db_bldg

# --- Classroom ---
@router.get("/classrooms", response_model=List[ClassroomResponse])
def get_classrooms(buildingId: str = None, db: Session = Depends(get_db), _ = Depends(require_role("principal", "hod", "admin"))):
    query = db.query(Classroom).filter(Classroom.status == "active")
    if buildingId:
        query = query.filter(Classroom.buildingId == buildingId)
    return query.all()

@router.post("/classrooms", response_model=ClassroomResponse)
def create_classroom(room: ClassroomCreate, db: Session = Depends(get_db), _ = Depends(require_role("principal", "admin"))):
    db_room = Classroom(
        id=str(uuid.uuid4()),
        **room.model_dump(),
        createdAt=get_current_time(),
        updatedAt=get_current_time()
    )
    db.add(db_room)
    db.commit()
    db.refresh(db_room)
    return db_room

@router.put("/classrooms/{room_id}", response_model=ClassroomResponse)
def update_classroom(room_id: str, room: ClassroomUpdate, db: Session = Depends(get_db), _ = Depends(require_role("principal", "admin"))):
    db_room = db.query(Classroom).filter(Classroom.id == room_id).first()
    if not db_room:
        raise HTTPException(status_code=404, detail="Classroom not found")
    
    for key, value in room.model_dump(exclude_unset=True).items():
        setattr(db_room, key, value)
    
    db_room.updatedAt = get_current_time()
    db.commit()
    db.refresh(db_room)
    return db_room

# --- Laboratory ---
@router.get("/laboratories", response_model=List[LaboratoryResponse])
def get_laboratories(departmentId: str = None, db: Session = Depends(get_db), _ = Depends(require_role("principal", "hod", "admin"))):
    query = db.query(Laboratory).filter(Laboratory.status == "active")
    if departmentId:
        query = query.filter(Laboratory.departmentId == departmentId)
    return query.all()

@router.post("/laboratories", response_model=LaboratoryResponse)
def create_laboratory(lab: LaboratoryCreate, db: Session = Depends(get_db), _ = Depends(require_role("principal", "hod", "admin"))):
    db_lab = Laboratory(
        id=str(uuid.uuid4()),
        **lab.model_dump(),
        createdAt=get_current_time(),
        updatedAt=get_current_time()
    )
    db.add(db_lab)
    db.commit()
    db.refresh(db_lab)
    return db_lab

@router.put("/laboratories/{lab_id}", response_model=LaboratoryResponse)
def update_laboratory(lab_id: str, lab: LaboratoryUpdate, db: Session = Depends(get_db), _ = Depends(require_role("principal", "hod", "admin"))):
    db_lab = db.query(Laboratory).filter(Laboratory.id == lab_id).first()
    if not db_lab:
        raise HTTPException(status_code=404, detail="Laboratory not found")
    
    for key, value in lab.model_dump(exclude_unset=True).items():
        setattr(db_lab, key, value)
    
    db_lab.updatedAt = get_current_time()
    db.commit()
    db.refresh(db_lab)
    return db_lab

# --- WorkingDay ---
@router.get("/working-days", response_model=List[WorkingDayResponse])
def get_working_days(db: Session = Depends(get_db), _ = Depends(require_role("principal", "hod", "admin"))):
    return db.query(WorkingDay).all()

@router.post("/working-days", response_model=WorkingDayResponse)
def create_working_day(wd: WorkingDayCreate, db: Session = Depends(get_db), _ = Depends(require_role("principal", "admin"))):
    db_wd = WorkingDay(
        id=str(uuid.uuid4()),
        **wd.model_dump(),
        createdAt=get_current_time(),
        updatedAt=get_current_time()
    )
    db.add(db_wd)
    db.commit()
    db.refresh(db_wd)
    return db_wd

@router.put("/working-days/{wd_id}", response_model=WorkingDayResponse)
def update_working_day(wd_id: str, wd: WorkingDayUpdate, db: Session = Depends(get_db), _ = Depends(require_role("principal", "admin"))):
    db_wd = db.query(WorkingDay).filter(WorkingDay.id == wd_id).first()
    if not db_wd:
        raise HTTPException(status_code=404, detail="Working day not found")
    
    for key, value in wd.model_dump(exclude_unset=True).items():
        setattr(db_wd, key, value)
    
    db_wd.updatedAt = get_current_time()
    db.commit()
    db.refresh(db_wd)
    return db_wd

# --- PeriodConfiguration ---
@router.get("/periods", response_model=List[PeriodConfigurationResponse])
def get_periods(db: Session = Depends(get_db), _ = Depends(require_role("principal", "hod", "admin"))):
    # Sort by start time
    return db.query(PeriodConfiguration).order_by(PeriodConfiguration.startTime).all()

@router.post("/periods", response_model=PeriodConfigurationResponse)
def create_period(period: PeriodConfigurationCreate, db: Session = Depends(get_db), _ = Depends(require_role("principal", "admin"))):
    db_period = PeriodConfiguration(
        id=str(uuid.uuid4()),
        **period.model_dump(),
        createdAt=get_current_time(),
        updatedAt=get_current_time()
    )
    db.add(db_period)
    db.commit()
    db.refresh(db_period)
    return db_period

@router.put("/periods/{period_id}", response_model=PeriodConfigurationResponse)
def update_period(period_id: str, period: PeriodConfigurationUpdate, db: Session = Depends(get_db), _ = Depends(require_role("principal", "admin"))):
    db_period = db.query(PeriodConfiguration).filter(PeriodConfiguration.id == period_id).first()
    if not db_period:
        raise HTTPException(status_code=404, detail="Period not found")
    
    for key, value in period.model_dump(exclude_unset=True).items():
        setattr(db_period, key, value)
    
    db_period.updatedAt = get_current_time()
    db.commit()
    db.refresh(db_period)
    return db_period

# --- InstitutionPolicy ---
@router.get("/policies", response_model=List[InstitutionPolicyResponse])
def get_policies(db: Session = Depends(get_db), _ = Depends(require_role("principal", "hod", "admin"))):
    return db.query(InstitutionPolicy).all()

@router.post("/policies", response_model=InstitutionPolicyResponse)
def create_policy(policy: InstitutionPolicyCreate, db: Session = Depends(get_db), _ = Depends(require_role("principal", "admin"))):
    db_policy = InstitutionPolicy(
        id=str(uuid.uuid4()),
        **policy.model_dump(),
        createdAt=get_current_time(),
        updatedAt=get_current_time()
    )
    db.add(db_policy)
    db.commit()
    db.refresh(db_policy)
    return db_policy

@router.put("/policies/{policy_id}", response_model=InstitutionPolicyResponse)
def update_policy(policy_id: str, policy: InstitutionPolicyUpdate, db: Session = Depends(get_db), _ = Depends(require_role("principal", "admin"))):
    db_policy = db.query(InstitutionPolicy).filter(InstitutionPolicy.id == policy_id).first()
    if not db_policy:
        raise HTTPException(status_code=404, detail="Policy not found")
    
    for key, value in policy.model_dump(exclude_unset=True).items():
        setattr(db_policy, key, value)
    
    db_policy.updatedAt = get_current_time()
    db.commit()
    db.refresh(db_policy)
    return db_policy

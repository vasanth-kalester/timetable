from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session as DBSession
from typing import List, Optional
from pydantic import BaseModel

from core.database import get_db
from models.timetable import Timetable, TimetableEntry
from schemas.timetable import TimetableResponse, TimetableUpdate, TimetableEntryResponse
from services.timetable_manager import TimetableManager

router = APIRouter(
    prefix="/api/v1/timetables",
    tags=["Timetables"]
)

class GenerateRequest(BaseModel):
    academicYearId: str
    name: str

class ManualEditRequest(BaseModel):
    newDay: int
    newPeriod: int
    newRoom: Optional[str] = None

@router.post("/generate", response_model=TimetableResponse)
def generate_timetable(request: GenerateRequest, db: DBSession = Depends(get_db)):
    """
    Generate a new timetable for the given academic year.
    """
    manager = TimetableManager(db)
    timetable = manager.generate_timetable(request.academicYearId, request.name)
    return timetable

@router.get("/", response_model=List[TimetableResponse])
def get_timetables(
    academic_year_id: Optional[str] = Query(None, alias="academicYearId"),
    status: Optional[str] = None,
    db: DBSession = Depends(get_db)
):
    """
    Get all timetables, optionally filtered by academic year and status.
    """
    query = db.query(Timetable)
    if academic_year_id:
        query = query.filter(Timetable.academicYearId == academic_year_id)
    if status:
        query = query.filter(Timetable.status == status)
        
    return query.all()

@router.get("/{timetable_id}", response_model=TimetableResponse)
def get_timetable(timetable_id: str, db: DBSession = Depends(get_db)):
    """
    Get a specific timetable by ID, including its entries.
    """
    timetable = db.query(Timetable).filter(Timetable.id == timetable_id).first()
    if not timetable:
        raise HTTPException(status_code=404, detail="Timetable not found")
    return timetable

@router.put("/{timetable_id}", response_model=TimetableResponse)
def update_timetable(timetable_id: str, update_data: TimetableUpdate, db: DBSession = Depends(get_db)):
    """
    Update a timetable's status or other metadata.
    """
    timetable = db.query(Timetable).filter(Timetable.id == timetable_id).first()
    if not timetable:
        raise HTTPException(status_code=404, detail="Timetable not found")
        
    update_dict = update_data.model_dump(exclude_unset=True)
    for key, value in update_dict.items():
        setattr(timetable, key, value)
        
    db.commit()
    db.refresh(timetable)
    return timetable

@router.post("/{timetable_id}/entries/{entry_id}/validate-edit")
def validate_manual_edit(timetable_id: str, entry_id: str, request: ManualEditRequest, db: DBSession = Depends(get_db)):
    """
    Validate a proposed manual edit (drag-and-drop).
    """
    manager = TimetableManager(db)
    result = manager.validate_manual_edit(timetable_id, entry_id, request.newDay, request.newPeriod, request.newRoom)
    return result

@router.put("/{timetable_id}/entries/{entry_id}", response_model=TimetableEntryResponse)
def apply_manual_edit(timetable_id: str, entry_id: str, request: ManualEditRequest, db: DBSession = Depends(get_db)):
    """
    Apply a manual edit to a timetable entry.
    """
    entry = db.query(TimetableEntry).filter(TimetableEntry.id == entry_id, TimetableEntry.timetableId == timetable_id).first()
    if not entry:
        raise HTTPException(status_code=404, detail="Entry not found")
        
    entry.dayOfWeek = request.newDay
    entry.period = request.newPeriod
    entry.roomId = request.newRoom
    entry.isManualEdit = True
    
    db.commit()
    db.refresh(entry)
    return entry

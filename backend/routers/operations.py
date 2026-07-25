from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session as DBSession
from typing import List, Optional
from pydantic import BaseModel

from core.database import get_db
from services.operations.leave_impact import LeaveImpactAnalyzer
from services.operations.substitution_engine import SubstitutionEngine
from services.operations.room_reallocation import RoomReallocationEngine
from services.operations.event_manager import EventManager
from services.operations.version_manager import VersionManager
from services.operations.conflict_validator import LiveConflictValidator
from services.operations.notification_service import NotificationService

router = APIRouter(
    prefix="/api/v1/operations",
    tags=["Operations"]
)

@router.get("/leave-impact")
def analyze_leave_impact(facultyId: str, date: int, db: DBSession = Depends(get_db)):
    analyzer = LeaveImpactAnalyzer(db)
    return analyzer.analyze_impact(facultyId, date)

@router.get("/substitutes")
def recommend_substitutes(sessionId: str, dayOfWeek: int, period: int, db: DBSession = Depends(get_db)):
    engine = SubstitutionEngine(db)
    return engine.recommend_substitutes(sessionId, dayOfWeek, period)

@router.get("/room-alternatives")
def recommend_rooms(roomId: str, dayOfWeek: int, period: int, duration: int = 1, db: DBSession = Depends(get_db)):
    engine = RoomReallocationEngine(db)
    return engine.recommend_alternative_rooms(roomId, dayOfWeek, period, duration)

@router.get("/event-impact")
def analyze_event_impact(date: int, startPeriod: int, endPeriod: int, roomId: Optional[str] = None, departmentId: Optional[str] = None, db: DBSession = Depends(get_db)):
    manager = EventManager(db)
    return manager.analyze_event_impact(date, startPeriod, endPeriod, roomId, departmentId)

class LiveChangeRequest(BaseModel):
    timetableId: str
    sessionId: str
    newDay: int
    newPeriod: int
    newRoomId: Optional[str] = None
    newFacultyId: Optional[str] = None

@router.post("/validate-change")
def validate_live_change(request: LiveChangeRequest, db: DBSession = Depends(get_db)):
    validator = LiveConflictValidator(db)
    return validator.validate_change(
        request.timetableId, request.sessionId, request.newDay, request.newPeriod, request.newRoomId, request.newFacultyId
    )

@router.post("/versions/{timetable_id}/rollback")
def rollback_version(timetable_id: str, target_version_id: str, db: DBSession = Depends(get_db)):
    manager = VersionManager(db)
    success = manager.rollback_to_version(timetable_id, target_version_id)
    if not success:
        raise HTTPException(status_code=400, detail="Rollback failed")
    return {"status": "success"}

@router.get("/notifications/{user_id}")
def get_notifications(user_id: str, unread_only: bool = False, db: DBSession = Depends(get_db)):
    service = NotificationService(db)
    # We need to serialize the SQLAlchemy models to dicts for FastAPI to return them properly if we don't have a response_model
    notifications = service.get_user_notifications(user_id, unread_only)
    return [{"id": n.id, "title": n.title, "message": n.message, "type": n.type, "isRead": n.isRead, "createdAt": n.createdAt} for n in notifications]

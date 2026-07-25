from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session as DBSession
from sqlalchemy import func
from typing import List, Optional

from core.database import get_db
from models.session import Session
from schemas.session import SessionResponse, TeachingAssignment
from services.session_builder import SessionBuilder

router = APIRouter(
    prefix="/api/v1/sessions",
    tags=["Sessions"]
)

@router.post("/build", response_model=List[SessionResponse])
def build_sessions(assignment: TeachingAssignment, db: DBSession = Depends(get_db)):
    """
    Convert a teaching assignment into schedulable session objects.
    """
    builder = SessionBuilder(db)
    sessions = builder.build_sessions(assignment)
    return sessions

@router.get("/", response_model=List[SessionResponse])
def get_sessions(
    department_id: Optional[str] = Query(None, alias="departmentId"),
    semester_id: Optional[str] = Query(None, alias="semesterId"),
    session_type: Optional[str] = Query(None, alias="sessionType"),
    status: Optional[str] = None,
    skip: int = 0,
    limit: int = 100,
    db: DBSession = Depends(get_db)
):
    """
    Get sessions with filtering and pagination.
    """
    query = db.query(Session)
    
    if department_id:
        query = query.filter(Session.departmentId == department_id)
    if semester_id:
        query = query.filter(Session.semesterId == semester_id)
    if session_type:
        query = query.filter(Session.sessionType == session_type)
    if status:
        query = query.filter(Session.status == status)
        
    sessions = query.order_by(Session.schedulingPriority.desc()).offset(skip).limit(limit).all()
    return sessions

@router.get("/stats")
def get_session_stats(db: DBSession = Depends(get_db)):
    """
    Get statistics about sessions for the dashboard.
    """
    total_sessions = db.query(Session).count()
    
    type_stats = db.query(Session.sessionType, func.count(Session.id)).group_by(Session.sessionType).all()
    type_counts = {t[0]: t[1] for t in type_stats}
    
    status_stats = db.query(Session.status, func.count(Session.id)).group_by(Session.status).all()
    status_counts = {s[0]: s[1] for s in status_stats}
    
    # Calculate readiness score (percentage of sessions ready for scheduling)
    ready_sessions = status_counts.get("ready", 0)
    readiness_score = (ready_sessions / total_sessions * 100) if total_sessions > 0 else 0
    
    return {
        "totalSessions": total_sessions,
        "byType": type_counts,
        "byStatus": status_counts,
        "readinessScore": round(readiness_score, 2)
    }

@router.get("/{session_id}", response_model=SessionResponse)
def get_session(session_id: str, db: DBSession = Depends(get_db)):
    """
    Get a specific session by ID.
    """
    session = db.query(Session).filter(Session.id == session_id).first()
    if not session:
        raise HTTPException(status_code=404, detail="Session not found")
    return session

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session as DBSession
from sqlalchemy import func
from typing import List, Optional

from core.database import get_db
from models.candidate_slot import CandidateSlot
from schemas.candidate_slot import CandidateSlotResponse
from services.candidate_slot_generator import CandidateSlotGenerator

router = APIRouter(
    prefix="/api/v1/candidate-slots",
    tags=["Candidate Slots"]
)

@router.post("/generate")
def generate_candidate_slots(db: DBSession = Depends(get_db)):
    """
    Generate candidate slots for all ready sessions.
    """
    generator = CandidateSlotGenerator(db)
    
    # In a real scenario, this context would be built by querying the DB for availability, etc.
    context = {
        'working_days': [1, 2, 3, 4, 5],
        'valid_periods': [1, 2, 3, 4, 5, 6, 7, 8],
        'break_periods': [5],
        'available_rooms': [None, 'room1', 'room2'],
        'existing_slots': [], # Would fetch already scheduled slots
        'faculty_availability': {},
        'faculty_preferences': {},
        'room_buildings': {}
    }
    
    total_generated = generator.generate_all(context)
    return {"message": f"Successfully generated {total_generated} candidate slots"}

@router.get("/", response_model=List[CandidateSlotResponse])
def get_candidate_slots(
    session_id: Optional[str] = Query(None, alias="sessionId"),
    status: Optional[str] = None,
    skip: int = 0,
    limit: int = 100,
    db: DBSession = Depends(get_db)
):
    """
    Get candidate slots with filtering and pagination.
    """
    query = db.query(CandidateSlot)
    
    if session_id:
        query = query.filter(CandidateSlot.sessionId == session_id)
    if status:
        query = query.filter(CandidateSlot.status == status)
        
    slots = query.order_by(CandidateSlot.priority.asc()).offset(skip).limit(limit).all()
    return slots

@router.get("/stats")
def get_candidate_slot_stats(db: DBSession = Depends(get_db)):
    """
    Get statistics about candidate slots for the dashboard.
    """
    total_slots = db.query(CandidateSlot).count()
    
    status_stats = db.query(CandidateSlot.status, func.count(CandidateSlot.id)).group_by(CandidateSlot.status).all()
    status_counts = {s[0]: s[1] for s in status_stats}
    
    # Calculate average candidates per session
    from models.session import Session
    total_sessions = db.query(Session).filter(Session.status == "ready").count()
    avg_candidates = (total_slots / total_sessions) if total_sessions > 0 else 0
    
    return {
        "totalSlots": total_slots,
        "byStatus": status_counts,
        "averageCandidatesPerSession": round(avg_candidates, 2)
    }

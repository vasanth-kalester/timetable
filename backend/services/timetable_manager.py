from sqlalchemy.orm import Session as DBSession
from typing import List, Dict, Any, Optional
import uuid

from models.timetable import Timetable, TimetableEntry
from models.session import Session
from models.candidate_slot import CandidateSlot
from services.optimization.engine import OptimizationEngine
from services.optimization.conflict_resolver import ConflictResolver

class TimetableManager:
    def __init__(self, db: DBSession):
        self.db = db
        self.engine = OptimizationEngine(db)
        
    def generate_timetable(self, academic_year_id: str, name: str) -> Timetable:
        # Fetch all ready sessions
        sessions = self.db.query(Session).filter(Session.status == "ready").all()
        
        # Fetch all candidate slots and group by session
        all_candidates = self.db.query(CandidateSlot).filter(CandidateSlot.status == "valid").all()
        candidates_map = {}
        for c in all_candidates:
            if c.sessionId not in candidates_map:
                candidates_map[c.sessionId] = []
            candidates_map[c.sessionId].append(c)
            
        # Run optimization engine
        success, assignments = self.engine.generate_timetable(sessions, candidates_map)
        
        # Create Timetable record
        timetable = Timetable(
            id=str(uuid.uuid4()),
            academicYearId=academic_year_id,
            name=name,
            status="draft"
        )
        self.db.add(timetable)
        
        # Create TimetableEntry records
        entries_data = []
        for session_id, slot in assignments.items():
            entry = TimetableEntry(
                id=str(uuid.uuid4()),
                timetableId=timetable.id,
                sessionId=session_id,
                dayOfWeek=slot.dayOfWeek,
                period=slot.period,
                roomId=slot.roomId,
                facultyId=slot.facultyId,
                sectionId=slot.sectionId
            )
            self.db.add(entry)
            entries_data.append({
                'dayOfWeek': slot.dayOfWeek,
                'period': slot.period,
                'facultyId': slot.facultyId,
                'roomId': slot.roomId,
                'sectionId': slot.sectionId,
                'duration': next((s.duration for s in sessions if s.id == session_id), 1)
            })
            
        # Calculate quality score and conflicts
        conflicts = ConflictResolver.detect_conflicts(entries_data)
        timetable.conflicts = len(conflicts)
        
        # Simple scoring logic for now
        total_sessions = len(sessions)
        placed_sessions = len(assignments)
        placement_ratio = placed_sessions / total_sessions if total_sessions > 0 else 0
        
        timetable.optimizationScore = placement_ratio * 100.0
        if timetable.conflicts == 0 and success:
            timetable.optimizationScore = min(100.0, timetable.optimizationScore + 5.0)
            
        self.db.commit()
        self.db.refresh(timetable)
        return timetable

    def validate_manual_edit(self, timetable_id: str, entry_id: str, new_day: int, new_period: int, new_room: Optional[str]) -> Dict[str, Any]:
        """
        Validates a manual drag-and-drop edit.
        """
        # Fetch all entries for this timetable
        entries = self.db.query(TimetableEntry).filter(TimetableEntry.timetableId == timetable_id).all()
        
        target_entry = next((e for e in entries if e.id == entry_id), None)
        if not target_entry:
            return {"valid": False, "message": "Entry not found"}
            
        # Create a simulated entries list with the proposed change
        simulated_entries = []
        for e in entries:
            if e.id == entry_id:
                simulated_entries.append({
                    'dayOfWeek': new_day,
                    'period': new_period,
                    'roomId': new_room,
                    'facultyId': e.facultyId,
                    'sectionId': e.sectionId,
                    'duration': e.session.duration if hasattr(e, 'session') else 1 # In real app, join session
                })
            else:
                simulated_entries.append({
                    'dayOfWeek': e.dayOfWeek,
                    'period': e.period,
                    'roomId': e.roomId,
                    'facultyId': e.facultyId,
                    'sectionId': e.sectionId,
                    'duration': e.session.duration if hasattr(e, 'session') else 1
                })
                
        conflicts = ConflictResolver.detect_conflicts(simulated_entries)
        
        if conflicts:
            # Auto-repair suggestion logic could go here
            return {
                "valid": False,
                "conflicts": conflicts,
                "suggestions": [] # e.g., alternative slots
            }
            
        return {"valid": True}

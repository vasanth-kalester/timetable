from sqlalchemy.orm import Session as DBSession
from typing import List, Dict, Any

from models.timetable import TimetableEntry, Timetable
from services.optimization.conflict_resolver import ConflictResolver

class LiveConflictValidator:
    def __init__(self, db: DBSession):
        self.db = db
        
    def validate_change(self, timetable_id: str, session_id: str, new_day: int, new_period: int, new_room_id: str = None, new_faculty_id: str = None) -> Dict[str, Any]:
        """
        Validates a live change against the current timetable.
        """
        # Fetch all entries for this timetable
        entries = self.db.query(TimetableEntry).filter(TimetableEntry.timetableId == timetable_id).all()
        
        # Create a simulated entries list with the proposed change
        simulated_entries = []
        for e in entries:
            if e.sessionId == session_id:
                simulated_entries.append({
                    'dayOfWeek': new_day,
                    'period': new_period,
                    'roomId': new_room_id if new_room_id else e.roomId,
                    'facultyId': new_faculty_id if new_faculty_id else e.facultyId,
                    'sectionId': e.sectionId,
                    'duration': e.session.duration if hasattr(e, 'session') else 1
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
            return {
                "valid": False,
                "conflicts": conflicts
            }
            
        return {"valid": True}

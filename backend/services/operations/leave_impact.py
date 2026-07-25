from sqlalchemy.orm import Session as DBSession
from typing import List, Dict, Any
from datetime import datetime

from models.timetable import Timetable, TimetableEntry
from models.session import Session
from models.faculty import Leave

class LeaveImpactAnalyzer:
    def __init__(self, db: DBSession):
        self.db = db
        
    def analyze_impact(self, faculty_id: str, leave_date: int) -> Dict[str, Any]:
        """
        Analyzes the impact of a faculty leave on the active timetable.
        """
        # Find the active timetable
        active_timetable = self.db.query(Timetable).filter(Timetable.status == "published").first()
        if not active_timetable:
            # If no published, try approved, then draft
            active_timetable = self.db.query(Timetable).filter(Timetable.status == "approved").first()
            if not active_timetable:
                active_timetable = self.db.query(Timetable).filter(Timetable.status == "draft").first()
                
        if not active_timetable:
            return {"affected_sessions": [], "message": "No active timetable found."}
            
        # Convert leave_date timestamp to day of week (1-7, Monday is 1)
        # Assuming leave_date is a unix timestamp in milliseconds
        dt = datetime.fromtimestamp(leave_date / 1000.0)
        day_of_week = dt.isoweekday()
        
        # Find all entries for this faculty on this day
        entries = self.db.query(TimetableEntry).filter(
            TimetableEntry.timetableId == active_timetable.id,
            TimetableEntry.facultyId == faculty_id,
            TimetableEntry.dayOfWeek == day_of_week
        ).all()
        
        affected_sessions = []
        freed_rooms = []
        
        for entry in entries:
            session = self.db.query(Session).filter(Session.id == entry.sessionId).first()
            affected_sessions.append({
                "entryId": entry.id,
                "sessionId": entry.sessionId,
                "sessionCode": session.code if session else "Unknown",
                "period": entry.period,
                "roomId": entry.roomId,
                "sectionId": entry.sectionId
            })
            if entry.roomId and entry.roomId not in freed_rooms:
                freed_rooms.append(entry.roomId)
                
        return {
            "facultyId": faculty_id,
            "date": leave_date,
            "dayOfWeek": day_of_week,
            "affected_sessions": affected_sessions,
            "freed_rooms": freed_rooms,
            "total_affected": len(affected_sessions)
        }

from sqlalchemy.orm import Session as DBSession
from typing import List, Dict, Any
from datetime import datetime

from models.operations import Event
from models.timetable import TimetableEntry, Timetable
from models.session import Session

class EventManager:
    def __init__(self, db: DBSession):
        self.db = db
        
    def analyze_event_impact(self, event_date: int, start_period: int, end_period: int, room_id: str = None, department_id: str = None) -> Dict[str, Any]:
        """
        Analyzes the impact of a special event on the regular timetable.
        """
        active_timetable = self.db.query(Timetable).filter(Timetable.status == "published").first()
        if not active_timetable:
            active_timetable = self.db.query(Timetable).filter(Timetable.status == "draft").first()
            
        if not active_timetable:
            return {"affected_sessions": []}
            
        dt = datetime.fromtimestamp(event_date / 1000.0)
        day_of_week = dt.isoweekday()
        
        query = self.db.query(TimetableEntry).filter(
            TimetableEntry.timetableId == active_timetable.id,
            TimetableEntry.dayOfWeek == day_of_week,
            TimetableEntry.period >= start_period,
            TimetableEntry.period <= end_period
        )
        
        if room_id:
            query = query.filter(TimetableEntry.roomId == room_id)
            
        # If department_id is provided, we need to join with Session to filter by department
        if department_id:
            query = query.join(Session).filter(Session.departmentId == department_id)
            
        entries = query.all()
        
        affected_sessions = []
        for entry in entries:
            session = self.db.query(Session).filter(Session.id == entry.sessionId).first()
            affected_sessions.append({
                "entryId": entry.id,
                "sessionId": entry.sessionId,
                "sessionCode": session.code if session else "Unknown",
                "period": entry.period,
                "roomId": entry.roomId,
                "facultyId": entry.facultyId,
                "sectionId": entry.sectionId
            })
            
        return {
            "date": event_date,
            "dayOfWeek": day_of_week,
            "startPeriod": start_period,
            "endPeriod": end_period,
            "affected_sessions": affected_sessions,
            "total_affected": len(affected_sessions)
        }

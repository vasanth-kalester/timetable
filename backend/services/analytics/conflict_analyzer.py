from sqlalchemy.orm import Session as DBSession
from typing import List, Dict, Any
from collections import defaultdict

from models.infrastructure import Classroom
from models.timetable import TimetableEntry, Timetable

class InfrastructureConflictAnalyzer:
    def __init__(self, db: DBSession):
        self.db = db
        
    def detect_infrastructure_issues(self, timetable_id: str = None) -> List[Dict[str, Any]]:
        """
        Detects recurring infrastructure issues like overloaded rooms.
        """
        if not timetable_id:
            active_timetable = self.db.query(Timetable).filter(Timetable.status == "published").first()
            if not active_timetable:
                active_timetable = self.db.query(Timetable).filter(Timetable.status == "draft").first()
            if not active_timetable:
                return []
            timetable_id = active_timetable.id
            
        rooms = self.db.query(Classroom).all()
        entries = self.db.query(TimetableEntry).filter(TimetableEntry.timetableId == timetable_id).all()
        
        room_usage = defaultdict(list)
        for entry in entries:
            if entry.roomId:
                room_usage[entry.roomId].append(entry)
                
        TOTAL_PERIODS = 40
        issues = []
        
        for room in rooms:
            usage = room_usage.get(room.id, [])
            used_periods = len(usage)
            utilization = (used_periods / TOTAL_PERIODS) * 100 if TOTAL_PERIODS > 0 else 0
            
            if utilization > 90:
                issues.append({
                    "roomId": room.id,
                    "roomName": room.name,
                    "issueType": "Overloaded",
                    "severity": "High",
                    "description": f"Room is utilized {utilization:.1f}%, leaving almost no buffer for maintenance or events."
                })
            elif utilization < 20:
                issues.append({
                    "roomId": room.id,
                    "roomName": room.name,
                    "issueType": "Underutilized",
                    "severity": "Low",
                    "description": f"Room is only utilized {utilization:.1f}%. Consider reallocating classes here to free up other rooms."
                })
                
        return issues

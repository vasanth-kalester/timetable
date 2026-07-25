from sqlalchemy.orm import Session as DBSession
from typing import List, Dict, Any
from datetime import datetime

from models.faculty import Faculty
from models.timetable import TimetableEntry, Timetable
from models.session import Session

class SubstitutionEngine:
    def __init__(self, db: DBSession):
        self.db = db
        
    def recommend_substitutes(self, session_id: str, day_of_week: int, period: int) -> List[Dict[str, Any]]:
        """
        Recommends substitute faculty for a given session.
        """
        session = self.db.query(Session).filter(Session.id == session_id).first()
        if not session:
            return []
            
        # Find active timetable
        active_timetable = self.db.query(Timetable).filter(Timetable.status == "published").first()
        if not active_timetable:
            active_timetable = self.db.query(Timetable).filter(Timetable.status == "draft").first()
            
        if not active_timetable:
            return []
            
        # Get all faculty in the same department
        department_faculty = self.db.query(Faculty).filter(
            Faculty.departmentId == session.departmentId,
            Faculty.id != session.facultyId
        ).all()
        
        # Find faculty who are busy during this period
        busy_entries = self.db.query(TimetableEntry).filter(
            TimetableEntry.timetableId == active_timetable.id,
            TimetableEntry.dayOfWeek == day_of_week,
            TimetableEntry.period == period
        ).all()
        busy_faculty_ids = [e.facultyId for e in busy_entries]
        
        recommendations = []
        for fac in department_faculty:
            if fac.id in busy_faculty_ids:
                continue # Faculty is busy
                
            # Calculate a score based on various factors
            score = 50 # Base score for being available and in the same department
            
            # TODO: Add more sophisticated scoring (e.g., subject expertise, workload)
            # For now, we'll just use a random-ish score for demonstration
            # In a real system, we'd check if fac.id is in a list of qualified faculty for session.subjectId
            
            # Simple workload check (fewer classes = higher score)
            fac_entries = self.db.query(TimetableEntry).filter(
                TimetableEntry.timetableId == active_timetable.id,
                TimetableEntry.facultyId == fac.id
            ).count()
            
            score += max(0, 50 - (fac_entries * 2))
            
            recommendations.append({
                "facultyId": fac.id,
                "name": f"{fac.firstName} {fac.lastName}",
                "score": min(100, score)
            })
            
        # Sort by score descending
        recommendations.sort(key=lambda x: x["score"], reverse=True)
        return recommendations
